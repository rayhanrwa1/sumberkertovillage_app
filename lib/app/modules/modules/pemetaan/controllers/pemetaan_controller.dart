import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PemetaanController extends GetxController {
  final markers = <Marker>[].obs;
  final selectedAddress = ''.obs;

  // Polygon kasar batas Desa Sumberkerto (contoh, bisa refine dari SHP BPN nanti)
  final List<LatLng> desaPolygon = const [
    LatLng(-8.3000, 112.5000),
    LatLng(-8.3000, 112.5600),
    LatLng(-8.2500, 112.5600),
    LatLng(-8.2500, 112.5000),
  ];

  bool isInsidePolygon(LatLng point) {
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

  Future<void> addMarker(LatLng position) async {
    if (!isInsidePolygon(position)) {
      Get.snackbar(
        'Di luar wilayah',
        'Marker hanya boleh di dalam Desa Sumberkerto',
      );
      return;
    }

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;
    final address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}';

    selectedAddress.value = address;

    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(title: 'Rumah Warga', snippet: address),
      ),
    );
  }
}
