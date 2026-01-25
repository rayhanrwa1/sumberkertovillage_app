import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import 'dart:io';
import '../controllers/pemetaan_controller.dart';

class PemetaanView extends GetView<PemetaanController> {
  const PemetaanView({super.key});

  static const LatLng centerSumberkerto = LatLng(-8.2759891, 112.5334492);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Pemetaan Desa Sumberkerto',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.info()),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(), color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Informasi Peta'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Desa: Sumberkerto\n'
                        'Kecamatan: Pagak\n'
                        'Kabupaten: Malang\n'
                        'Total Marker: ${controller.markers.length}',
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Cara Penggunaan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '- Klik pointer di tengah peta untuk menambah marker\n'
                        '- Klik marker untuk melihat detail\n'
                        '- Pilih icon sesuai kategori lokasi\n'
                        '- Upload foto maksimal 4 gambar',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
          Obx(
            () => controller.markers.isNotEmpty
                ? IconButton(
                    icon: Icon(PhosphorIcons.trash()),
                    tooltip: 'Hapus semua marker',
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Hapus Semua Marker?'),
                          content: Text(
                            'Semua ${controller.markers.length} marker akan dihapus.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                controller.clearAllMarkers();
                                Get.back();
                                context.showSuccessSnackBar(
                                  'Semua marker telah dihapus',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat peta Sumberkerto...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: centerSumberkerto,
                        zoom: 15.5,
                      ),
                      mapType: MapType.normal,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: controller.hasLocationPermission.value,
                      markers: controller.markers.toSet(),
                      onMapCreated: (GoogleMapController gmController) {
                        controller.mapController = gmController;
                      },
                      onCameraMove: (CameraPosition position) {
                        controller.currentMapCenter.value = position.target;
                      },
                    ),
            ),
          ),

          Obx(() {
            final markerData = controller.selectedMarkerData.value;
            if (markerData == null) return const SizedBox.shrink();

            return _buildMarkerDetailCard(context, markerData);
          }),

          Positioned(
            top: 16,
            right: 16,
            child: Obx(
              () => controller.markers.isNotEmpty
                  ? Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.mapPin(),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${controller.markers.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          IgnorePointer(
            ignoring: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      final center = controller.currentMapCenter.value;
                      _showBottomSheet(context, center);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        TAssetsConst.pointer,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerDetailCard(
    BuildContext context,
    Map<String, dynamic> markerData,
  ) {
    final iconType = markerData['icon_type'] ?? '';
    final iconUrl = controller.iconMap[iconType] ?? '';
    final photos = markerData['photos'] ?? [];

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (iconUrl.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        iconUrl,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            PhosphorIcons.mapPin(),
                            size: 32,
                            color: Colors.blue,
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        PhosphorIcons.mapPin(),
                        size: 32,
                        color: Colors.blue,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          markerData['nama_lokasi'] ?? 'Tanpa Nama',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getIconLabel(iconType),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: () => controller.closeMarkerDetail(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (markerData['note'] != null &&
                  markerData['note'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIcons.note(), size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          markerData['note'],
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.navigationArrow(),
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Koordinat',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${markerData['latitude']}\nLng: ${markerData['longitude']}',
                      style: const TextStyle(fontSize: 10, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (photos is List && photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photos[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(
                                  PhosphorIcons.image(),
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, LatLng position) {
    final namaController = TextEditingController();
    final catatanController = TextEditingController();
    final selectedIconType = ''.obs;
    final selectedPhotos = <File>[].obs;
    final ImagePicker picker = ImagePicker();

    controller.selectedAddress.value = 'Memuat alamat...';
    _getAddress(position);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(PhosphorIcons.mapPinPlus(), color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Marker Lokasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.navigationArrow(),
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Koordinat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${position.latitude.toStringAsFixed(6)}\n'
                      'Lng: ${position.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.mapPin(),
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Alamat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.selectedAddress.value,
                        style: const TextStyle(fontSize: 11, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    PhosphorIcons.imageSquare(),
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pilih Icon Marker',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (controller.iconMap.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.iconMap.length,
                  itemBuilder: (context, index) {
                    final iconEntry = controller.iconMap.entries
                        .toList()[index];
                    final iconType = iconEntry.key;
                    final iconUrl = iconEntry.value;

                    return Obx(
                      () => GestureDetector(
                        onTap: () {
                          selectedIconType.value = iconType;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedIconType.value == iconType
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color: selectedIconType.value == iconType
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: selectedIconType.value == iconType ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                iconUrl,
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    PhosphorIcons.imageSquare(),
                                    size: 32,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getIconLabel(iconType),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),

              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lokasi',
                  hintText: 'Masukkan nama lokasi',
                  prefixIcon: Icon(PhosphorIcons.textT()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Keterangan tambahan (opsional)',
                  prefixIcon: Icon(PhosphorIcons.note()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(PhosphorIcons.image(), size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload Foto (Maks 4)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      if (selectedPhotos.length >= 4) {
                        context.showWarningSnackBar('Maksimal 4 foto');
                        return;
                      }

                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );

                      if (image != null) {
                        selectedPhotos.add(File(image.path));
                      }
                    },
                    icon: Icon(PhosphorIcons.plus()),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Obx(() {
                if (selectedPhotos.isEmpty) {
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.image(),
                            size: 32,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Belum ada foto',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedPhotos[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  selectedPhotos.removeAt(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    PhosphorIcons.x(),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (namaController.text.trim().isEmpty) {
                      context.showWarningSnackBar('Nama lokasi harus diisi');
                      return;
                    }

                    if (selectedIconType.value.isEmpty) {
                      context.showWarningSnackBar(
                        'Pilih icon marker terlebih dahulu',
                      );
                      return;
                    }

                    Get.back();

                    Get.dialog(
                      const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Menyimpan data...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    await controller.addMarkerWithIcon(
                      position,
                      namaController.text,
                      catatanController.text,
                      selectedIconType.value,
                      selectedPhotos,
                    );

                    Get.back();

                    context.showSuccessSnackBar(
                      'Marker "${namaController.text}" berhasil ditambahkan',
                    );
                  },
                  icon: Icon(PhosphorIcons.floppyDisk()),
                  label: const Text(
                    'Simpan Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        controller.selectedAddress.value = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      } else {
        controller.selectedAddress.value =
            'Lat: ${position.latitude}, Lng: ${position.longitude}';
      }
    } catch (_) {
      controller.selectedAddress.value =
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
    }
  }

  String _getIconLabel(String iconType) {
    final labels = {
      'home': 'Rumah',
      'jalan_rusak': 'Jln Rusak',
      'penunjuk_arah': 'Penunjuk',
      'perempatan': 'Perempatan',
      'pertanian': 'Pertanian',
      'pertigaan': 'Pertigaan',
      'peternakan': 'Peternakan',
      'pointer': 'Pointer',
      'pom_bensin': 'SPBU',
      'titik_kumpul': 'Titik Kumpul',
      'warung_caffe': 'Warung',
    };
    return labels[iconType] ?? iconType;
  }
}
