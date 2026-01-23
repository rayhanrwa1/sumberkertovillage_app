import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/pemetaan_controller.dart';

class PemetaanView extends GetView<PemetaanController> {
  const PemetaanView({super.key});

  static const LatLng centerSumberkerto = LatLng(-8.2765, 112.5302);

  static final LatLngBounds boundsSumberkerto = LatLngBounds(
    southwest: const LatLng(-8.3000, 112.5000),
    northeast: const LatLng(-8.2500, 112.5600),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemetaan Desa Sumberkerto - Pagak'),
        centerTitle: true,
      ),
      body: Obx(
        () => GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: centerSumberkerto,
            zoom: 15.5,
          ),
          cameraTargetBounds: CameraTargetBounds(boundsSumberkerto),
          minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
          zoomControlsEnabled: true,
          compassEnabled: true,
          polygons: {
            Polygon(
              polygonId: const PolygonId('desa_sumberkerto'),
              points: controller.desaPolygon,
              fillColor: Colors.green.withOpacity(0.15),
              strokeColor: Colors.green,
              strokeWidth: 2,
            ),
          },
          markers: controller.markers.toSet(),
          onLongPress: (latLng) {
            controller.addMarker(latLng);
            _showBottomSheet(context);
          },
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Rumah Warga',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Alamat otomatis:\n${controller.selectedAddress.value}'),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Nama Pemilik'),
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // nanti: simpan ke Firebase + upload foto
                    Get.back();
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
