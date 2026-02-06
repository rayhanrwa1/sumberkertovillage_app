import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/utils/loaders.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import 'dart:io';
import '../controllers/pemetaan_controller.dart';

class AddMarkerForm extends StatefulWidget {
  final LatLng position;
  final PemetaanController controller;

  const AddMarkerForm({
    super.key,
    required this.position,
    required this.controller,
  });

  @override
  State<AddMarkerForm> createState() => _AddMarkerFormState();
}

class _AddMarkerFormState extends State<AddMarkerForm> {
  late final TextEditingController namaController;
  late final TextEditingController catatanController;
  late final RxString selectedIconType;
  late final RxList<File> selectedPhotos;
  late final ImagePicker picker;
  late final RxBool isOutsideVillage;

  @override
  void initState() {
    super.initState();

    isOutsideVillage = false.obs;
    namaController = TextEditingController();
    catatanController = TextEditingController();
    selectedIconType = ''.obs;
    selectedPhotos = <File>[].obs;
    picker = ImagePicker();

    final inside = widget.controller.isInsidePolygon(widget.position);
    isOutsideVillage.value = !inside;
    widget.controller.selectedAddress.value = 'Memuat alamat...';
    _getAddress(widget.position);
  }

  @override
  void dispose() {
    namaController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        widget.controller.selectedAddress.value = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      } else {
        widget.controller.selectedAddress.value = 'Alamat tidak ditemukan';
      }
    } catch (_) {
      widget.controller.selectedAddress.value = 'Alamat tidak ditemukan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TSpaces.v12(),
            // Drag handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: TColorsConst.neutral300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            TSpaces.v20(),

            // Alamat saja
            _AddressCard(controller: widget.controller),
            TSpaces.v24(),

            // Pilih Icon
            _SectionLabel(
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
              title: 'Pilih Icon Marker',
              required: true,
            ),
            TSpaces.v12(),
            _IconSelectionSection(
              controller: widget.controller,
              selectedIconType: selectedIconType,
            ),
            TSpaces.v24(),

            // Nama Lokasi
            _SectionLabel(
              icon: PhosphorIcons.textT(PhosphorIconsStyle.bold),
              title: 'Nama Lokasi',
              required: true,
            ),
            TSpaces.v8(),
            _SoftTextField(
              controller: namaController,
              hint: 'Masukkan nama lokasi',
            ),
            TSpaces.v20(),

            // Deskripsi
            _SectionLabel(
              icon: PhosphorIcons.note(PhosphorIconsStyle.fill),
              title: 'Deskripsi',
              suffix: 'Opsional',
            ),
            TSpaces.v8(),
            _SoftTextField(
              controller: catatanController,
              hint: 'Keterangan tambahan',
              maxLines: 3,
            ),
            TSpaces.v20(),

            // Foto
            _SectionLabel(
              icon: PhosphorIcons.image(PhosphorIconsStyle.fill),
              title: 'Upload Foto',
              suffix: 'Maks 4',
            ),
            TSpaces.v8(),
            _PhotoUploadSection(selectedPhotos: selectedPhotos, picker: picker),
            TSpaces.v24(),

            // Warning luar desa
            Obx(() {
              if (!isOutsideVillage.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: TColorsConst.errorMain.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: TColorsConst.errorMain.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIcons.warning(PhosphorIconsStyle.fill),
                      color: TColorsConst.errorMain,
                      size: 18.sp,
                    ),
                    TSpaces.h8(),
                    Expanded(
                      child: Text(
                        'Lokasi ini berada di luar wilayah Desa Sumberkerto. '
                        'Marker tidak dapat disimpan.',
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.errorMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Tombol Simpan
            _SubmitButton(
              isOutsideVillage: isOutsideVillage,
              namaController: namaController,
              catatanController: catatanController,
              selectedIconType: selectedIconType,
              selectedPhotos: selectedPhotos,
              position: widget.position,
              controller: widget.controller,
            ),
            TSpaces.v16(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Label section
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool required;
  final String? suffix;

  const _SectionLabel({
    required this.icon,
    required this.title,
    this.required = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18.sp, color: TColorsConst.blue500),
        TSpaces.h8(),
        Text(title, style: TGoogleTextStyleConst.inter14Bold),
        if (required) ...[
          TSpaces.h4(),
          Text('*', style: TextStyle(color: TColorsConst.errorMain)),
        ],
        if (suffix != null) ...[
          TSpaces.h8(),
          Text(
            suffix!,
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: TColorsConst.neutral500,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Soft text field
// ─────────────────────────────────────────────
class _SoftTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _SoftTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TGoogleTextStyleConst.inter14Regular.copyWith(
        color: TColorsConst.neutral800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
          color: TColorsConst.neutral400,
        ),
        filled: true,
        fillColor: TColorsConst.neutral50,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: TColorsConst.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: TColorsConst.blue500, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Alamat saja (tanpa latlong)
// ─────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final PemetaanController controller;

  const _AddressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TColorsConst.neutral50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
            size: 16.sp,
            color: TColorsConst.blue500,
          ),
          TSpaces.h8(),
          Expanded(
            child: Obx(
              () => Text(
                controller.selectedAddress.value,
                style: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: TColorsConst.neutral600,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Icon selection – pisah per kategori
// ─────────────────────────────────────────────
class _IconSelectionSection extends StatelessWidget {
  final PemetaanController controller;
  final RxString selectedIconType;

  const _IconSelectionSection({
    required this.controller,
    required this.selectedIconType,
  });

  @override
  Widget build(BuildContext context) {
    final iconsTempat = controller.iconMapTempat.entries.toList();

    final iconsJalan = [
      ...controller.iconMapJalan.entries,
      ...controller.iconMap.entries.where(
        (e) =>
            e.key.contains('jalan') ||
            e.key.contains('pertigaan') ||
            e.key.contains('longsor'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tempat',
          style: TGoogleTextStyleConst.inter12Regular.copyWith(
            color: TColorsConst.neutral500,
          ),
        ),
        TSpaces.v8(),
        _buildIconGrid(iconsTempat),
        TSpaces.v16(),
        Text(
          'Jalan & Fasilitas',
          style: TGoogleTextStyleConst.inter12Regular.copyWith(
            color: TColorsConst.neutral500,
          ),
        ),
        TSpaces.v8(),
        _buildIconGrid(iconsJalan),
      ],
    );
  }

  Widget _buildIconGrid(List<MapEntry<String, String>> icons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 0.85,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return _IconItem(
          iconType: icons[index].key,
          iconUrl: icons[index].value,
          selectedIconType: selectedIconType,
        );
      },
    );
  }
}

class _IconItem extends StatelessWidget {
  final String iconType;
  final String iconUrl;
  final RxString selectedIconType;

  const _IconItem({
    required this.iconType,
    required this.iconUrl,
    required this.selectedIconType,
  });

  static const Map<String, String> _labels = {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool selected = selectedIconType.value == iconType;

      return GestureDetector(
        onTap: () => selectedIconType.value = iconType,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? TColorsConst.blue500.withOpacity(0.08)
                : TColorsConst.neutral50,
            border: Border.all(
              color: selected ? TColorsConst.blue500 : TColorsConst.neutral200,
              width: selected ? 1.8 : 1,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                iconUrl,
                width: 30.w,
                height: 30.h,
                errorBuilder: (_, __, ___) => Icon(
                  PhosphorIcons.imageSquare(PhosphorIconsStyle.light),
                  size: 28.sp,
                  color: TColorsConst.neutral400,
                ),
              ),
              TSpaces.v4(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  _labels[iconType] ?? iconType,
                  style: TGoogleTextStyleConst.inter10Regular.copyWith(
                    color: selected
                        ? TColorsConst.blue500
                        : TColorsConst.neutral600,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Foto upload – placeholder besar saat kosong,
// horizontal list + tombol tambah saat ada foto
// ─────────────────────────────────────────────
class _PhotoUploadSection extends StatelessWidget {
  final RxList<File> selectedPhotos;
  final ImagePicker picker;

  const _PhotoUploadSection({
    required this.selectedPhotos,
    required this.picker,
  });

  void _showImageSourcePicker(BuildContext context) {
    if (selectedPhotos.length >= 4) {
      context.showWarningSnackBar('Maksimal 4 foto');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill)),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (img != null) selectedPhotos.add(File(img.path));
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.image(PhosphorIconsStyle.fill)),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (img != null) selectedPhotos.add(File(img.path));
              },
            ),
            TSpaces.v8(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Kosong → placeholder besar
      if (selectedPhotos.isEmpty) {
        return GestureDetector(
          onTap: () => _showImageSourcePicker(context),
          child: Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              color: TColorsConst.neutral50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: TColorsConst.neutral200, width: 1.5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.image(PhosphorIconsStyle.light),
                    size: 36.sp,
                    color: TColorsConst.neutral400,
                  ),
                  TSpaces.v8(),
                  Text(
                    'Ketuk untuk tambah foto',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Ada foto → list horizontal + tombol +
      return SizedBox(
        height: 120.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              selectedPhotos.length + (selectedPhotos.length < 4 ? 1 : 0),
          itemBuilder: (context, index) {
            // Terakhir = tombol tambah
            if (index == selectedPhotos.length) {
              return GestureDetector(
                onTap: () => _showImageSourcePicker(context),
                child: Container(
                  width: 90.w,
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: TColorsConst.neutral50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: TColorsConst.neutral200,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.plus(PhosphorIconsStyle.bold),
                      size: 22.sp,
                      color: TColorsConst.neutral400,
                    ),
                  ),
                ),
              );
            }

            return _PhotoItem(
              photo: selectedPhotos[index],
              onRemove: () => selectedPhotos.removeAt(index),
            );
          },
        ),
      );
    });
  }
}

class _PhotoItem extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;

  const _PhotoItem({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(
              photo,
              width: 100.w,
              height: 120.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.x(PhosphorIconsStyle.bold),
                  color: TColorsConst.white,
                  size: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tombol simpan
// ─────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final RxBool isOutsideVillage;
  final TextEditingController namaController;
  final TextEditingController catatanController;
  final RxString selectedIconType;
  final RxList<File> selectedPhotos;
  final LatLng position;
  final PemetaanController controller;

  const _SubmitButton({
    required this.isOutsideVillage,
    required this.namaController,
    required this.catatanController,
    required this.selectedIconType,
    required this.selectedPhotos,
    required this.position,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final disabled = isOutsideVillage.value;
      return SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: disabled
                ? TColorsConst.neutral300
                : TColorsConst.blue500,
            foregroundColor: TColorsConst.white,
            disabledBackgroundColor: TColorsConst.neutral300,
            disabledForegroundColor: TColorsConst.neutral500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          onPressed: disabled ? null : () => _handleSubmit(context),
          icon: Icon(
            PhosphorIcons.floppyDisk(PhosphorIconsStyle.fill),
            size: 18.sp,
          ),
          label: Text(
            'Simpan Marker',
            style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
              color: TColorsConst.white,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (namaController.text.trim().isEmpty) {
      context.showWarningSnackBar('Nama lokasi harus diisi');
      return;
    }

    if (selectedIconType.value.isEmpty) {
      context.showWarningSnackBar('Pilih icon marker terlebih dahulu');
      return;
    }

    final markerName = namaController.text.trim();

    TLoaders.openLoadingDialogWithMessage('Menyimpan data...');

    try {
      await controller.addMarkerWithIcon(
        position,
        markerName,
        catatanController.text.trim(),
        selectedIconType.value,
        selectedPhotos,
      );

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Marker "$markerName" berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      context.showErrorSnackBar('Gagal menyimpan marker');
    } finally {
      TLoaders.stopLoading();
    }
  }
}
