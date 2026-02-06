import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumberkerto_smart_village/app/core/logger/app_logger.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:sumberkerto_smart_village/app/modules/modules/pemetaan/services/directions_service.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pemetaan/models/road_model.dart';

class PemetaanController extends GetxController {
  final markers = <Marker>[].obs;
  final selectedAddress = ''.obs;
  final desaPolygon = <LatLng>[].obs;
  final isLoading = false.obs;
  final hasLocationPermission = false.obs;
  final iconMap = <String, String>{}.obs;
  final selectedMarkerData = Rxn<Map<String, dynamic>>();
  final markerDataMap = <String, Map<String, dynamic>>{}.obs;
  final searchQuery = ''.obs;
  final filteredMarkers = <Map<String, dynamic>>[].obs;
  static PemetaanController get to => Get.find<PemetaanController>();
  final iconMapTempat = <String, String>{}.obs;
  final iconMapJalan = <String, String>{}.obs;
  final RxList<RoadData> roads = <RoadData>[].obs;
  final Rx<RoadData?> selectedRoadData = Rx<RoadData?>(null);
  final Map<String, String> _polylineToRoadMap = {};

  // Enhanced road drawing
  RxBool isDrawingRoad = false.obs;
  RxList<LatLng> tempRoadPoints = <LatLng>[].obs;
  Rx<RoadCondition?> selectedRoadCondition = Rx<RoadCondition?>(null);
  RxBool isLoadingRoute = false.obs;
  Rx<LatLng?> currentPointerPosition = Rx<LatLng?>(null);

  RxList<LatLng> roadPoints = <LatLng>[].obs;
  LatLng? startPoint;

  final DirectionsService _directionsService = DirectionsService();

  GoogleMapController? mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _logger = AppLogger.instance;

  final currentMapCenter = const LatLng(-8.2759891, 112.5334492).obs;
  static const String googleApiKey = 'AIzaSyCkymj5pLqGSbraogMIjOmgXMuqR583uUs';

  final Map<String, BitmapDescriptor> _iconCache = {};

  // ---------------------------------------------------------------------------
  // Helper: show snackbar dari controller menggunakan Get.context
  // ---------------------------------------------------------------------------
  void _showSnackbar(String message, TSnackbarType type) {
    final context = Get.context;
    if (context != null) {
      TSnackbar.show(context, message: message, type: type);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
    loadBoundaryFromGoogleAPI();
    loadIconMaps();
    loadMarkersFromFirebase();
    loadJalanRusakFromFirebase();
    loadRoads();
  }

  // ---------------------------------------------------------------------------
  // POLYLINES
  // ---------------------------------------------------------------------------
  Set<Polyline> get polylines {
    final Set<Polyline> allPolylines = {};

    for (final road in roads) {
      final polyline = Polyline(
        polylineId: PolylineId(road.id),
        points: road.points,
        color: road.condition.color,
        width: 6,
        consumeTapEvents: true,
        onTap: () {
          onPolylineTapped(road.id);
        },
      );
      allPolylines.add(polyline);
      _polylineToRoadMap[road.id] = road.id;
    }

    if (isDrawingRoad.value && tempRoadPoints.length > 1) {
      allPolylines.add(
        Polyline(
          polylineId: const PolylineId('temp_road'),
          points: tempRoadPoints,
          color: selectedRoadCondition.value?.color ?? Colors.red,
          width: 6,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    return allPolylines;
  }

  void onPolylineTapped(String polylineId) {
    _logger.i('ROAD', 'Polyline tapped: $polylineId');

    final roadData = roads.firstWhereOrNull((road) => road.id == polylineId);

    if (roadData != null) {
      selectedMarkerData.value = null;
      selectedRoadData.value = roadData;

      if (roadData.points.isNotEmpty) {
        final bounds = _calculateBounds(roadData.points);
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      }
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ---------------------------------------------------------------------------
  // PERMISSION
  // ---------------------------------------------------------------------------
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    hasLocationPermission.value = status.isGranted;
  }

  // ---------------------------------------------------------------------------
  // LOAD ROADS
  // ---------------------------------------------------------------------------
  Future<void> loadRoads() async {
    try {
      final snapshot = await _database.child('maps/jalan_rusak').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        roads.clear();

        for (var entry in data.entries) {
          final roadData = Map<String, dynamic>.from(entry.value);
          final points = (roadData['points'] as List)
              .map((e) => LatLng(e['lat'], e['lng']))
              .toList();

          final condition = RoadCondition.values.firstWhere(
            (e) => e.name == roadData['condition'],
            orElse: () => RoadCondition.rusak,
          );

          roads.add(
            RoadData(
              id: entry.key,
              nama: roadData['nama'] ?? '',
              deskripsi: roadData['deskripsi'] ?? '',
              points: points,
              condition: condition,
            ),
          );
        }

        _logger.i('ROAD', 'Loaded ${roads.length} roads from Firebase');
      }
    } catch (e) {
      _logger.e('ROAD', 'Error loading roads', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // ICON MAPS
  // ---------------------------------------------------------------------------
  Future<void> loadIconMaps() async {
    final tempatSnap = await _database.child('icon_maps').get();
    final jalanSnap = await _database.child('icon_jalan').get();

    if (tempatSnap.exists) {
      iconMapTempat.value = Map<String, String>.from(tempatSnap.value as Map);
    }

    if (jalanSnap.exists) {
      iconMapJalan.value = Map<String, String>.from(jalanSnap.value as Map);
    }

    iconMap.value = {...iconMapTempat, ...iconMapJalan};
  }

  Future<BitmapDescriptor> _getMarkerIcon(
    String iconUrl,
    String iconType,
  ) async {
    if (_iconCache.containsKey(iconType)) {
      return _iconCache[iconType]!;
    }

    try {
      final response = await http.get(Uri.parse(iconUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        final ui.Codec codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: 120,
          targetHeight: 120,
        );
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ByteData? byteData = await frameInfo.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final Uint8List resizedBytes = byteData.buffer.asUint8List();
          final BitmapDescriptor icon = BitmapDescriptor.fromBytes(
            resizedBytes,
          );

          _iconCache[iconType] = icon;
          return icon;
        }
      }
    } catch (e) {
      _logger.e('MARKER_ICON', 'Error loading custom marker icon', error: e);
    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  // ---------------------------------------------------------------------------
  // LOAD MARKERS
  // ---------------------------------------------------------------------------
  Future<void> loadMarkersFromFirebase() async {
    try {
      isLoading.value = true;
      _logger.i('MARKER', 'Loading markers from Firebase...');

      final snapshot = await _database.child('maps/data_rumah').get();

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is! Map) {
          _logger.w('MARKER', 'No valid marker data found');
          return;
        }

        final mapData = Map<String, dynamic>.from(data as Map);
        markers.clear();
        markerDataMap.clear();

        _logger.i('MARKER', 'Found ${mapData.length} markers in database');

        for (var entry in mapData.entries) {
          try {
            final markerData = Map<String, dynamic>.from(entry.value);

            final lat = double.parse(markerData['latitude'].toString());
            final lng = double.parse(markerData['longitude'].toString());
            final iconType = markerData['icon_type'] ?? '';
            final iconUrl = iconMap[iconType] ?? '';

            markerDataMap[entry.key] = markerData;

            BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
            if (iconUrl.isNotEmpty) {
              markerIcon = await _getMarkerIcon(iconUrl, iconType);
            }

            final marker = Marker(
              markerId: MarkerId(entry.key),
              position: LatLng(lat, lng),
              onTap: () => onMarkerTapped(entry.key),
              icon: markerIcon,
              infoWindow: InfoWindow(title: markerData['nama_lokasi'] ?? ''),
            );

            markers.add(marker);
          } catch (e) {
            _logger.e('MARKER', 'Error loading marker ${entry.key}', error: e);
          }
        }

        updateFilteredMarkers();
        _logger.i('MARKER', 'Successfully loaded ${markers.length} markers');
      } else {
        _logger.w('MARKER', 'No markers found in database');
      }
    } catch (e) {
      _logger.e('MARKER', 'Error loading markers', error: e);
      _showSnackbar('Gagal memuat markers', TSnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // FILTER & SEARCH MARKERS
  // ---------------------------------------------------------------------------
  void updateFilteredMarkers() {
    if (searchQuery.value.isEmpty) {
      filteredMarkers.value = markerDataMap.entries.map((e) {
        return {'id': e.key, ...e.value};
      }).toList();
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredMarkers.value = markerDataMap.entries
          .where((e) {
            final nama = (e.value['nama_lokasi'] ?? '')
                .toString()
                .toLowerCase();
            final note = (e.value['note'] ?? '').toString().toLowerCase();
            final iconType = (e.value['icon_type'] ?? '')
                .toString()
                .toLowerCase();

            return nama.contains(query) ||
                note.contains(query) ||
                iconType.contains(query);
          })
          .map((e) {
            return {'id': e.key, ...e.value};
          })
          .toList();
    }
  }

  void searchMarkers(String query) {
    searchQuery.value = query;
    updateFilteredMarkers();
  }

  // ---------------------------------------------------------------------------
  // MARKER TAP & DELETE
  // ---------------------------------------------------------------------------
  void onMarkerTapped(String markerId) {
    selectedMarkerData.value = markerDataMap[markerId];

    if (mapController != null && markerDataMap.containsKey(markerId)) {
      final markerData = markerDataMap[markerId]!;
      final lat = double.parse(markerData['latitude'].toString());
      final lng = double.parse(markerData['longitude'].toString());

      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
      );
    }
  }

  void closeMarkerDetail() {
    selectedMarkerData.value = null;
  }

  Future<void> deleteMarker(String markerId) async {
    try {
      _logger.i('MARKER', 'Deleting marker: $markerId');

      await _database.child('maps/data_rumah/$markerId').remove();

      markers.removeWhere((marker) => marker.markerId.value == markerId);
      markerDataMap.remove(markerId);

      if (selectedMarkerData.value != null &&
          markerDataMap[markerId] == selectedMarkerData.value) {
        selectedMarkerData.value = null;
      }

      updateFilteredMarkers();

      _logger.i('MARKER', 'Marker deleted successfully');
      _showSnackbar('Marker berhasil dihapus', TSnackbarType.success);
    } catch (e) {
      _logger.e('MARKER', 'Error deleting marker', error: e);
      _showSnackbar('Gagal menghapus marker', TSnackbarType.error);
    }
  }

  // ---------------------------------------------------------------------------
  // ROAD DRAWING
  // ---------------------------------------------------------------------------
  void startDrawingRoad(RoadCondition condition) {
    selectedRoadCondition.value = condition;
    isDrawingRoad.value = true;
    tempRoadPoints.clear();
    updateTempPolyline();
  }

  /// Cek apakah ada titik di tempRoadPoints yang di luar polygon desa
  bool get hasPointOutsidePolygon {
    if (desaPolygon.isEmpty) return false;
    return tempRoadPoints.any((point) => !isInsidePolygon(point));
  }

  Future<void> addRoadPointWithRoute(LatLng point) async {
    // Validasi polygon — tolak titik kalau di luar desa
    if (desaPolygon.isNotEmpty && !isInsidePolygon(point)) {
      _showSnackbar(
        'Titik harus berada di dalam wilayah Desa Sumberkerto',
        TSnackbarType.warning,
      );
      return;
    }

    if (tempRoadPoints.isEmpty) {
      tempRoadPoints.add(point);
      updateTempPolyline();
      return;
    }

    try {
      isLoadingRoute.value = true;
      final lastPoint = tempRoadPoints.last;

      final routePoints = await _directionsService.getRoute(lastPoint, point);

      if (routePoints.isNotEmpty) {
        tempRoadPoints.addAll(routePoints.skip(1));
      } else {
        tempRoadPoints.add(point);
      }

      updateTempPolyline();
    } catch (e) {
      _logger.e('ROAD', 'Error getting route', error: e);
      tempRoadPoints.add(point);
      updateTempPolyline();
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void updateTempPolyline() {
    polylines.removeWhere((p) => p.polylineId.value == 'temp_road');

    if (tempRoadPoints.length < 2) return;

    final condition = selectedRoadCondition.value ?? RoadCondition.rusak;

    polylines.add(
      Polyline(
        polylineId: const PolylineId('temp_road'),
        points: List.from(tempRoadPoints),
        color: condition.color,
        width: 6,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  void clearSelectedRoad() {
    selectedRoadData.value = null;
  }

  Future<void> deleteRoad(String roadId) async {
    try {
      await _database.child('maps/jalan_rusak/$roadId').remove();

      roads.removeWhere((road) => road.id == roadId);

      if (selectedRoadData.value?.id == roadId) {
        selectedRoadData.value = null;
      }

      _logger.i('ROAD', 'Road deleted: $roadId');
      _showSnackbar('Jalan berhasil dihapus', TSnackbarType.success);
    } catch (e) {
      _logger.e('ROAD', 'Error deleting road', error: e);
      _showSnackbar('Gagal menghapus jalan', TSnackbarType.error);
    }
  }

  Future<void> saveJalanRusak(String nama, String deskripsi) async {
    if (tempRoadPoints.length < 2) {
      _showSnackbar('Minimal 2 titik diperlukan', TSnackbarType.warning);
      return;
    }

    if (selectedRoadCondition.value == null) {
      _showSnackbar(
        'Pilih kondisi jalan terlebih dahulu',
        TSnackbarType.warning,
      );
      return;
    }

    if (hasPointOutsidePolygon) {
      _showSnackbar(
        'Semua titik harus berada di dalam wilayah Desa Sumberkerto',
        TSnackbarType.warning,
      );
      return;
    }

    try {
      final condition = selectedRoadCondition.value!;
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final jalanData = {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'points': tempRoadPoints
            .map((e) => {'lat': e.latitude, 'lng': e.longitude})
            .toList(),
        'condition': condition.name,
        'created_at': ServerValue.timestamp,
      };

      await _database.child('maps/jalan_rusak/$id').set(jalanData);

      roads.add(
        RoadData(
          id: id,
          nama: nama,
          deskripsi: deskripsi,
          points: List.from(tempRoadPoints),
          condition: condition,
          createdAt: DateTime.now(),
        ),
      );

      // Clear temp data
      tempRoadPoints.clear();
      isDrawingRoad.value = false;
      selectedRoadCondition.value = null;

      _logger.i('ROAD', 'Road saved successfully: $id');
      _showSnackbar('Jalan berhasil ditambahkan', TSnackbarType.success);
    } catch (e) {
      _logger.e('ROAD', 'Error saving road', error: e);
      _showSnackbar('Gagal menyimpan jalan', TSnackbarType.error);
    }
  }

  void cancelDrawingRoad() {
    tempRoadPoints.clear();
    isDrawingRoad.value = false;
    selectedRoadCondition.value = null;
    polylines.removeWhere((p) => p.polylineId.value == 'temp_road');
  }

  // ---------------------------------------------------------------------------
  // LOAD JALAN RUSAK (legacy polylines)
  // ---------------------------------------------------------------------------
  Future<void> loadJalanRusakFromFirebase() async {
    try {
      final snapshot = await _database.child('maps/jalan_rusak').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        for (var entry in data.entries) {
          final roadData = Map<String, dynamic>.from(entry.value);
          final points = (roadData['points'] as List)
              .map((e) => LatLng(e['lat'], e['lng']))
              .toList();

          final condition = RoadCondition.values.firstWhere(
            (e) => e.name == roadData['condition'],
            orElse: () => RoadCondition.rusak,
          );

          polylines.add(
            Polyline(
              polylineId: PolylineId(entry.key),
              points: points,
              color: condition.color,
              width: 6,
              onTap: () => _showRoadDetail(entry.key, roadData),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('ROAD', 'Error loading roads', error: e);
    }
  }

  void _showRoadDetail(String id, Map<String, dynamic> data) {
    final condition = RoadCondition.values.firstWhere(
      (e) => e.name == data['condition'],
      orElse: () => RoadCondition.rusak,
    );

    Get.dialog(
      AlertDialog(
        title: Text(data['nama']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kondisi: ${condition.label}'),
            if (data['deskripsi'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Deskripsi: ${data['deskripsi']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _database.child('maps/jalan_rusak/$id').remove();
              polylines.removeWhere((p) => p.polylineId.value == id);
              _showSnackbar('Jalan berhasil dihapus', TSnackbarType.success);
            },
            child: const Text('Hapus'),
          ),
          TextButton(onPressed: Get.back, child: const Text('Tutup')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UPLOAD IMAGES
  // ---------------------------------------------------------------------------
  Future<List<String>> uploadImages(List<File> images) async {
    List<String> uploadedUrls = [];

    try {
      _logger.i('UPLOAD', 'Uploading ${images.length} images...');

      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final fileName = 'foto_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref().child('maps/$fileName');

        _logger.d('UPLOAD', 'Uploading image ${i + 1}/${images.length}...');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);
        _logger.d('UPLOAD', 'Image ${i + 1} uploaded successfully');
      }

      _logger.i('UPLOAD', 'All images uploaded successfully');
    } catch (e) {
      _logger.e('UPLOAD', 'Error uploading images', error: e);
      _showSnackbar('Gagal upload foto', TSnackbarType.error);
    }

    return uploadedUrls;
  }

  // ---------------------------------------------------------------------------
  // ADD MARKER
  // ---------------------------------------------------------------------------
  Future<void> addMarkerWithIcon(
    LatLng position,
    String nama,
    String catatan,
    String iconType,
    List<File> photos,
  ) async {
    if (nama.trim().isEmpty) {
      _logger.w('VALIDATION', 'Nama lokasi kosong');
      _showSnackbar('Nama lokasi harus diisi', TSnackbarType.warning);
      return;
    }

    if (iconType.isEmpty) {
      _logger.w('VALIDATION', 'Icon type tidak dipilih');
      _showSnackbar('Pilih icon marker terlebih dahulu', TSnackbarType.warning);
      return;
    }

    final isJalanIcon = iconType.toLowerCase().startsWith('jalan');

    if (isJalanIcon) {
      _logger.i(
        'VALIDATION',
        'Jalan icon detected, skipping polygon validation',
      );
    } else {
      if (desaPolygon.isEmpty) {
        _logger.w(
          'VALIDATION',
          'Polygon belum dimuat, melewati validasi polygon',
        );
      } else if (!isInsidePolygon(position)) {
        _logger.w('VALIDATION', 'Posisi di luar polygon');
        _showSnackbar(
          'Marker hanya boleh di dalam Desa Sumberkerto',
          TSnackbarType.warning,
        );
        return;
      }
    }

    try {
      _logger.i('MARKER', 'Adding new marker');
      _logger.d('MARKER', 'Name: $nama');
      _logger.d(
        'MARKER',
        'Position: ${position.latitude}, ${position.longitude}',
      );
      _logger.d('MARKER', 'Icon: $iconType');
      _logger.d('MARKER', 'Photos: ${photos.length}');

      // Get address
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          selectedAddress.value = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
          ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
        } else {
          selectedAddress.value =
              'Lat: ${position.latitude}, Lng: ${position.longitude}';
        }
      } catch (e) {
        _logger.w('ADDRESS', 'Failed to get address');
        selectedAddress.value =
            'Lat: ${position.latitude}, Lng: ${position.longitude}';
      }

      // Upload photos
      List<String> photoUrls = [];
      if (photos.isNotEmpty) {
        photoUrls = await uploadImages(photos);
        if (photoUrls.length != photos.length) {
          _logger.w('UPLOAD', 'Some photos failed to upload');
        }
      }

      // Generate key
      final markerKey = _database.child('maps/data_rumah').push().key;

      if (markerKey == null) {
        throw Exception('Failed to generate marker key');
      }

      _logger.d('MARKER', 'Generated marker key: $markerKey');

      // Prepare data
      final markerData = {
        'nama_lokasi': nama.trim(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'note': catatan.trim(),
        'icon_type': iconType,
        'photos': photoUrls,
        'created_at': ServerValue.timestamp,
      };

      _logger.d('MARKER', 'Saving marker to Firebase');

      await _database.child('maps/data_rumah/$markerKey').set(markerData);

      _logger.i('MARKER', 'Marker saved to Firebase successfully');

      // Update local data
      markerDataMap[markerKey] = markerData;

      // Get custom icon
      final iconUrl = iconMap[iconType] ?? '';
      BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
      if (iconUrl.isNotEmpty) {
        markerIcon = await _getMarkerIcon(iconUrl, iconType);
      }

      final marker = Marker(
        markerId: MarkerId(markerKey),
        position: position,
        onTap: () => onMarkerTapped(markerKey),
        icon: markerIcon,
        infoWindow: InfoWindow(title: nama),
      );

      markers.add(marker);
      updateFilteredMarkers();

      _logger.d('MARKER', 'Marker added to local state');

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
      }

      _logger.i('MARKER', 'Marker added successfully');
      _showSnackbar('Marker berhasil ditambahkan', TSnackbarType.success);
    } catch (e, stackTrace) {
      _logger.e(
        'MARKER',
        'Error adding marker',
        error: e,
        stackTrace: stackTrace,
      );
      _showSnackbar('Gagal menyimpan marker', TSnackbarType.error);
    }
  }

  // ---------------------------------------------------------------------------
  // BOUNDARY
  // ---------------------------------------------------------------------------
  Future<void> loadBoundaryFromGoogleAPI() async {
    isLoading.value = true;
    try {
      final searchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?'
        'query=Sumberkerto+Pagak+Malang+Jawa+Timur&key=$googleApiKey',
      );

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        if (searchData['results'] != null && searchData['results'].isNotEmpty) {
          final placeId = searchData['results'][0]['place_id'];
          await _getPlaceDetails(placeId);
        } else {
          await loadBoundaryFromOSM();
        }
      } else {
        await loadBoundaryFromOSM();
      }
    } catch (e) {
      _logger.e('BOUNDARY', 'Error loading boundary from Google API', error: e);
      await loadBoundaryFromOSM();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      final detailsUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId&fields=geometry&key=$googleApiKey',
      );

      final response = await http.get(detailsUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result']?['geometry']?['viewport'] != null) {
          final viewport = data['result']['geometry']['viewport'];
          final ne = viewport['northeast'];
          final sw = viewport['southwest'];

          desaPolygon.value = [
            LatLng(ne['lat'], sw['lng']),
            LatLng(ne['lat'], ne['lng']),
            LatLng(sw['lat'], ne['lng']),
            LatLng(sw['lat'], sw['lng']),
            LatLng(ne['lat'], sw['lng']),
          ];
          _logger.i('BOUNDARY', 'Loaded boundary from Google Places API');
        } else {
          await loadBoundaryFromOSM();
        }
      }
    } catch (e) {
      _logger.e('BOUNDARY', 'Error getting place details', error: e);
      await loadBoundaryFromOSM();
    }
  }

  Future<void> loadBoundaryFromOSM() async {
    try {
      const query = '''
[out:json][timeout:25];
(
  relation["name"="Sumberkerto"]["admin_level"="8"]["boundary"="administrative"];
  relation["name"="Sumberkerto"]["place"="village"];
);
out geom;
''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(
        url,
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: const {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['elements'] != null && data['elements'].isNotEmpty) {
          List<LatLng> coordinates = [];

          for (var element in data['elements']) {
            if (element['members'] != null) {
              for (var member in element['members']) {
                if (member['geometry'] != null) {
                  for (var point in member['geometry']) {
                    coordinates.add(LatLng(point['lat'], point['lon']));
                  }
                }
              }
            } else if (element['geometry'] != null) {
              for (var point in element['geometry']) {
                coordinates.add(LatLng(point['lat'], point['lon']));
              }
            }
          }

          if (coordinates.isNotEmpty) {
            desaPolygon.value = _cleanCoordinates(coordinates);
            _logger.i('BOUNDARY', 'Loaded boundary from OSM');
            return;
          }
        }
      }

      _loadManualBoundary();
    } catch (e) {
      _logger.e('BOUNDARY', 'Error loading boundary from OSM', error: e);
      _loadManualBoundary();
    }
  }

  List<LatLng> _cleanCoordinates(List<LatLng> coords) {
    if (coords.isEmpty) return [];

    List<LatLng> cleaned = [coords.first];
    for (int i = 1; i < coords.length; i++) {
      if (coords[i].latitude != cleaned.last.latitude ||
          coords[i].longitude != cleaned.last.longitude) {
        cleaned.add(coords[i]);
      }
    }

    if (cleaned.first.latitude != cleaned.last.latitude ||
        cleaned.first.longitude != cleaned.last.longitude) {
      cleaned.add(cleaned.first);
    }

    return cleaned;
  }

  void _loadManualBoundary() {
    desaPolygon.value = [
      const LatLng(-8.2662, 112.5356),
      const LatLng(-8.2675, 112.5380),
      const LatLng(-8.2690, 112.5405),
      const LatLng(-8.2701, 112.5420),
      const LatLng(-8.2720, 112.5435),
      const LatLng(-8.2750, 112.5441),
      const LatLng(-8.2780, 112.5443),
      const LatLng(-8.2794, 112.5441),
      const LatLng(-8.2815, 112.5430),
      const LatLng(-8.2840, 112.5410),
      const LatLng(-8.2860, 112.5395),
      const LatLng(-8.2876, 112.5388),
      const LatLng(-8.2885, 112.5360),
      const LatLng(-8.2891, 112.5310),
      const LatLng(-8.2885, 112.5280),
      const LatLng(-8.2870, 112.5250),
      const LatLng(-8.2850, 112.5235),
      const LatLng(-8.2840, 112.5231),
      const LatLng(-8.2825, 112.5210),
      const LatLng(-8.2812, 112.5174),
      const LatLng(-8.2790, 112.5175),
      const LatLng(-8.2760, 112.5180),
      const LatLng(-8.2730, 112.5190),
      const LatLng(-8.2701, 112.5201),
      const LatLng(-8.2689, 112.5230),
      const LatLng(-8.2680, 112.5250),
      const LatLng(-8.2675, 112.5280),
      const LatLng(-8.2670, 112.5310),
      const LatLng(-8.2665, 112.5330),
      const LatLng(-8.2662, 112.5356),
    ];
    _logger.i('BOUNDARY', 'Loaded manual boundary');
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;

      return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
    } catch (e) {
      return "Alamat tidak ditemukan";
    }
  }

  bool isInsidePolygon(LatLng point) {
    if (desaPolygon.isEmpty) {
      _logger.w('POLYGON', 'Polygon empty, skipping validation');
      return true;
    }

    int intersectCount = 0;
    for (int j = 0; j < desaPolygon.length - 1; j++) {
      final a = desaPolygon[j];
      final b = desaPolygon[j + 1];

      if (((a.latitude > point.latitude) != (b.latitude > point.latitude)) &&
          (point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  void clearAllMarkers() {
    markers.clear();
    markerDataMap.clear();
    filteredMarkers.clear();
    selectedMarkerData.value = null;
  }

  @override
  void onClose() {
    markers.clear();
    markerDataMap.clear();
    filteredMarkers.clear();
    _iconCache.clear();
    mapController?.dispose();
    super.onClose();
  }
}
