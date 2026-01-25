import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class PemetaanController extends GetxController {
  final markers = <Marker>[].obs;
  final selectedAddress = ''.obs;
  final desaPolygon = <LatLng>[].obs;
  final isLoading = false.obs;
  final hasLocationPermission = false.obs;
  final iconMap = <String, String>{}.obs;
  final selectedMarkerData = Rxn<Map<String, dynamic>>();
  final markerDataMap = <String, Map<String, dynamic>>{}.obs;

  GoogleMapController? mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final currentMapCenter = const LatLng(-8.2759891, 112.5334492).obs;
  static const String googleApiKey = 'AIzaSy...';

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
    try {
      final snapshot = await _database.child('icon_maps').get();

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is Map) {
          iconMap.value = Map<String, String>.from(
            data.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
        } else if (data is String) {
          try {
            final parsed = json.decode(data);
            if (parsed is Map) {
              iconMap.value = Map<String, String>.from(
                parsed.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              );
            }
          } catch (e) {
            print('Error parsing icon maps JSON: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading icon maps: $e');
    }
  }

  Future<void> loadMarkersFromFirebase() async {
    try {
      final snapshot = await _database.child('maps/data_rumah').get();

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is! Map) {
          return;
        }

        final mapData = Map<String, dynamic>.from(data as Map);
        markers.clear();
        markerDataMap.clear();

        for (var entry in mapData.entries) {
          try {
            final markerData = Map<String, dynamic>.from(entry.value);

            final lat = double.parse(markerData['latitude'].toString());
            final lng = double.parse(markerData['longitude'].toString());
            final nama = markerData['nama_lokasi'] ?? '';
            final note = markerData['note'] ?? '';

            markerDataMap[entry.key] = markerData;

            final marker = Marker(
              markerId: MarkerId(entry.key),
              position: LatLng(lat, lng),
              onTap: () => onMarkerTapped(entry.key),
              icon: BitmapDescriptor.defaultMarker,
            );

            markers.add(marker);
          } catch (e) {
            print('Error loading marker ${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  void onMarkerTapped(String markerId) {
    selectedMarkerData.value = markerDataMap[markerId];
  }

  void closeMarkerDetail() {
    selectedMarkerData.value = null;
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> uploadedUrls = [];

    try {
      for (var image in images) {
        final fileName =
            'foto_${DateTime.now().millisecondsSinceEpoch}_${uploadedUrls.length}.jpg';
        final ref = _storage.ref().child('maps/$fileName');

        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);
      }
    } catch (e) {
      print('Error uploading images: $e');
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
    if (!isInsidePolygon(position)) {
      Get.snackbar(
        'Di luar wilayah',
        'Marker hanya boleh di dalam Desa Sumberkerto',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

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
      selectedAddress.value =
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
    }

    List<String> photoUrls = [];
    if (photos.isNotEmpty) {
      photoUrls = await uploadImages(photos);
    }

    final markerKey = _database.child('maps/data_rumah').push().key;

    final markerData = {
      'nama_lokasi': nama,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'note': catatan,
      'icon_type': iconType,
      'photos': photoUrls,
      'created_at': ServerValue.timestamp,
    };

    try {
      await _database.child('maps/data_rumah/$markerKey').set(markerData);

      markerDataMap[markerKey!] = markerData;

      final marker = Marker(
        markerId: MarkerId(markerKey),
        position: position,
        onTap: () => onMarkerTapped(markerKey),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers.add(marker);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
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
    } catch (_) {
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
        } else {
          await loadBoundaryFromOSM();
        }
      }
    } catch (_) {
      await loadBoundaryFromOSM();
    }
  }

  Future<void> loadBoundaryFromOSM() async {
    try {
      final query = '''
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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
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
            return;
          }
        }
      }

      _loadManualBoundary();
    } catch (_) {
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
      LatLng(-8.2662, 112.5356),
      LatLng(-8.2675, 112.5380),
      LatLng(-8.2690, 112.5405),
      LatLng(-8.2701, 112.5420),
      LatLng(-8.2720, 112.5435),
      LatLng(-8.2750, 112.5441),
      LatLng(-8.2780, 112.5443),
      LatLng(-8.2794, 112.5441),
      LatLng(-8.2815, 112.5430),
      LatLng(-8.2840, 112.5410),
      LatLng(-8.2860, 112.5395),
      LatLng(-8.2876, 112.5388),
      LatLng(-8.2885, 112.5360),
      LatLng(-8.2891, 112.5310),
      LatLng(-8.2885, 112.5280),
      LatLng(-8.2870, 112.5250),
      LatLng(-8.2850, 112.5235),
      LatLng(-8.2840, 112.5231),
      LatLng(-8.2825, 112.5210),
      LatLng(-8.2812, 112.5174),
      LatLng(-8.2790, 112.5175),
      LatLng(-8.2760, 112.5180),
      LatLng(-8.2730, 112.5190),
      LatLng(-8.2701, 112.5201),
      LatLng(-8.2689, 112.5230),
      LatLng(-8.2680, 112.5250),
      LatLng(-8.2675, 112.5280),
      LatLng(-8.2670, 112.5310),
      LatLng(-8.2665, 112.5330),
      LatLng(-8.2662, 112.5356),
    ];
  }

  bool isInsidePolygon(LatLng point) {
    if (desaPolygon.isEmpty) return true;

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
  }

  @override
  void onClose() {
    markers.clear();
    markerDataMap.clear();
    super.onClose();
  }
}
