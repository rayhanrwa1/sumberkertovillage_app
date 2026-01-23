import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PemetaanController extends GetxController {
  final markers = <Marker>[].obs;
  final selectedAddress = ''.obs;

  void addMarker(LatLng position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;
    final address = '${place.street}, ${place.subLocality}, ${place.locality}';

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
