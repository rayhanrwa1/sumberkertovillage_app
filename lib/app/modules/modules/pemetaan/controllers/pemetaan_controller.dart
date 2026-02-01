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
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

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

  GoogleMapController? mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _logger = AppLogger.instance;

  final currentMapCenter = const LatLng(-8.2759891, 112.5334492).obs;
  static const String googleApiKey = 'AIzaSyCkymj5pLqGSbraogMIjOmgXMuqR583uUs';

  final Map<String, BitmapDescriptor> _iconCache = {};

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
    loadBoundaryFromGoogleAPI();
    loadIconMaps();
    loadMarkersFromFirebase();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    hasLocationPermission.value = status.isGranted;
  }

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
    // Check cache first
    if (_iconCache.containsKey(iconType)) {
      return _iconCache[iconType]!;
    }

    try {
      final response = await http.get(Uri.parse(iconUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        // Resize and create custom marker
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

          // Cache the icon
          _iconCache[iconType] = icon;
          return icon;
        }
      }
    } catch (e) {
      _logger.e('MARKER_ICON', 'Error loading custom marker icon', error: e);
    }

    // Fallback to default marker
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

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

            // Get custom icon
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
      Get.snackbar(
        'Error',
        'Gagal memuat markers: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

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

  void onMarkerTapped(String markerId) {
    selectedMarkerData.value = markerDataMap[markerId];

    // Animate camera to marker
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

      Get.snackbar(
        'Berhasil',
        'Marker berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _logger.e('MARKER', 'Error deleting marker', error: e);
      Get.snackbar(
        'Error',
        'Gagal menghapus marker: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

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
      Get.snackbar(
        'Error',
        'Gagal upload foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }

    return uploadedUrls;
  }

  Future<void> addMarkerWithIcon(
    LatLng position,
    String nama,
    String catatan,
    String iconType,
    List<File> photos,
  ) async {
    // Validasi input
    if (nama.trim().isEmpty) {
      _logger.w('VALIDATION', 'Nama lokasi kosong');
      Get.snackbar(
        'Peringatan',
        'Nama lokasi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (iconType.isEmpty) {
      _logger.w('VALIDATION', 'Icon type tidak dipilih');
      Get.snackbar(
        'Peringatan',
        'Pilih icon marker terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Check if icon_type starts with "jalan" - if yes, skip polygon validation
    final isJalanIcon = iconType.toLowerCase().startsWith('jalan');

    if (isJalanIcon) {
      _logger.i(
        'VALIDATION',
        'Jalan icon detected, skipping polygon validation',
      );
    } else {
      // Regular validation for non-jalan icons
      if (desaPolygon.isEmpty) {
        _logger.w(
          'VALIDATION',
          'Polygon belum dimuat, melewati validasi polygon',
        );
      } else if (!isInsidePolygon(position)) {
        _logger.w('VALIDATION', 'Posisi di luar polygon');
        Get.snackbar(
          'Di luar wilayah',
          'Marker hanya boleh di dalam Desa Sumberkerto',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
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

      // Save to Firebase
      await _database.child('maps/data_rumah/$markerKey').set(markerData);

      _logger.i('MARKER', 'Marker saved to Firebase successfully');

      // Update local data
      markerDataMap[markerKey] = markerData;

      // Get custom icon for new marker
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

      // Animate to new marker
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
      }

      _logger.i('MARKER', 'Marker added successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'MARKER',
        'Error adding marker',
        error: e,
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Error',
        'Gagal menyimpan marker: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

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
