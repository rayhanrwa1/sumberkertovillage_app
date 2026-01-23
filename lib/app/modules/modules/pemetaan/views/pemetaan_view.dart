import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/pemetaan_controller.dart';

class PemetaanView extends GetView<PemetaanController> {
  const PemetaanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemetaan Wilayah Desa'),
        centerTitle: true,
      ),
      body: Obx(
        () => GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-8.112, 112.234), 
            zoom: 15,
          ),
          markers: controller.markers.toSet(),
          onLongPress: (latLng) {
            controller.addMarker(latLng);
            _showBottomSheet(context, latLng);
          },
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, LatLng latLng) {
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
              Text('Alamat otomatis: ${controller.selectedAddress.value}'),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Nama Pemilik'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // nanti kita simpan ke Firebase + upload foto
                  Get.back();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
