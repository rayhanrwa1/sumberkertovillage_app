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
        widget.controller.selectedAddress.value =
            'Lat: ${position.latitude}, Lng: ${position.longitude}';
      }
    } catch (_) {
      widget.controller.selectedAddress.value =
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DragHandle(),
            TSpaces.v20(),
            _LocationInfoCard(position: widget.position),
            TSpaces.v16(),
            _AddressInfoCard(controller: widget.controller),
            TSpaces.v24(),
            _IconSelectionSection(
              controller: widget.controller,
              selectedIconType: selectedIconType,
            ),
            TSpaces.v24(),
            _NameInputField(controller: namaController),
            TSpaces.v20(),
            _NotesInputField(controller: catatanController),
            TSpaces.v20(),
            _PhotoUploadSection(selectedPhotos: selectedPhotos, picker: picker),
            TSpaces.v24(),
            Obx(() {
              if (!isOutsideVillage.value) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: TColorsConst.errorMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: TColorsConst.errorMain),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.warning(PhosphorIconsStyle.fill),
                      color: TColorsConst.errorMain,
                    ),
                    TSpaces.h8(),
                    Expanded(
                      child: Text(
                        'Lokasi ini berada di luar wilayah Desa Sumberkerto. Marker tidak dapat disimpan.',
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.errorMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            _SubmitButton(
              isOutsideVillage: isOutsideVillage,
              namaController: namaController,
              catatanController: catatanController,
              selectedIconType: selectedIconType,
              selectedPhotos: selectedPhotos,
              position: widget.position,
              controller: widget.controller,
            ),
          ],
        ),
      ),
    );
  }
}

// ============= WIDGET COMPONENTS =============

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: TColorsConst.neutral300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  final LatLng position;

  const _LocationInfoCard({required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColorsConst.blue500.withOpacity(0.05),
            TColorsConst.blue600.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TColorsConst.blue500.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                size: 18.sp,
                color: TColorsConst.blue500,
              ),
              TSpaces.h8(),
              Text('Koordinat', style: TGoogleTextStyleConst.inter14Bold),
            ],
          ),
          TSpaces.v8(),
          Text(
            'Lat: ${position.latitude.toStringAsFixed(6)}\n'
            'Lng: ${position.longitude.toStringAsFixed(6)}',
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: TColorsConst.neutral700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressInfoCard extends StatelessWidget {
  final PemetaanController controller;

  const _AddressInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColorsConst.blue500.withOpacity(0.05),
              TColorsConst.blue600.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: TColorsConst.blue500.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  size: 18.sp,
                  color: TColorsConst.blue500,
                ),
                TSpaces.h8(),
                Text('Alamat', style: TGoogleTextStyleConst.inter14Bold),
              ],
            ),
            TSpaces.v8(),
            Text(
              controller.selectedAddress.value,
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: TColorsConst.neutral700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSelectionSection extends StatelessWidget {
  final PemetaanController controller;
  final RxString selectedIconType;

  const _IconSelectionSection({
    required this.controller,
    required this.selectedIconType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.imageSquare(PhosphorIconsStyle.fill),
              size: 22.sp,
              color: TColorsConst.blue500,
            ),
            TSpaces.h8(),
            Text('Pilih Icon Marker', style: TGoogleTextStyleConst.inter16Bold),
            TSpaces.h8(),
            Text('*', style: TextStyle(color: TColorsConst.errorMain)),
          ],
        ),
        TSpaces.v16(),

        /// ===== ICON TEMPAT =====
        Text('Ikon Tempat', style: TGoogleTextStyleConst.inter14Bold),
        TSpaces.v8(),
        _buildIconGrid(controller.iconMapTempat.entries.toList()),

        TSpaces.v24(),

        /// ===== ICON JALAN & FASILITAS =====
        Text(
          'Ikon Jalan & Fasilitas',
          style: TGoogleTextStyleConst.inter14Bold,
        ),
        TSpaces.v8(),
        _buildIconGrid(controller.iconMapJalan.entries.toList()),

        TSpaces.v8(),
        _buildIconGrid(
          controller.iconMap.entries
              .where(
                (e) =>
                    e.key.contains('jalan') ||
                    e.key.contains('pertigaan') ||
                    e.key.contains('longsor'),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildIconGrid(List<MapEntry<String, String>> icons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.9,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconType = icons[index].key;
        final iconUrl = icons[index].value;

        return _IconGridItem(
          iconType: iconType,
          iconUrl: iconUrl,
          selectedIconType: selectedIconType,
        );
      },
    );
  }
}

class _IconGridItem extends StatelessWidget {
  final String iconType;
  final String iconUrl;
  final RxString selectedIconType;

  const _IconGridItem({
    required this.iconType,
    required this.iconUrl,
    required this.selectedIconType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          selectedIconType.value = iconType;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selectedIconType.value == iconType
                ? TColorsConst.blue500.withOpacity(0.1)
                : TColorsConst.white,
            border: Border.all(
              color: selectedIconType.value == iconType
                  ? TColorsConst.blue500
                  : TColorsConst.neutral300,
              width: selectedIconType.value == iconType ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: selectedIconType.value == iconType
                ? [
                    BoxShadow(
                      color: TColorsConst.blue500.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                iconUrl,
                width: 36.w,
                height: 36.h,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    PhosphorIcons.imageSquare(PhosphorIconsStyle.fill),
                    size: 36.sp,
                    color: TColorsConst.neutral400,
                  );
                },
              ),
              TSpaces.v4(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  _getIconLabel(iconType),
                  style: TGoogleTextStyleConst.inter10Regular.copyWith(
                    fontWeight: selectedIconType.value == iconType
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedIconType.value == iconType
                        ? TColorsConst.blue500
                        : TColorsConst.neutral800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIconLabel(String iconType) {
    const labels = {
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

class _NameInputField extends StatelessWidget {
  final TextEditingController controller;

  const _NameInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.textT(PhosphorIconsStyle.bold),
              size: 22.sp,
              color: TColorsConst.blue500,
            ),
            TSpaces.h8(),
            Text('Nama Lokasi', style: TGoogleTextStyleConst.inter16Bold),
            TSpaces.h8(),
            Text(
              '*',
              style: TGoogleTextStyleConst.inter16Regular.copyWith(
                color: TColorsConst.errorMain,
              ),
            ),
          ],
        ),
        TSpaces.v12(),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan nama lokasi',
            hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral400,
            ),
            filled: true,
            fillColor: TColorsConst.neutral50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: TColorsConst.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: TColorsConst.blue500,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesInputField extends StatelessWidget {
  final TextEditingController controller;

  const _NotesInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.note(PhosphorIconsStyle.fill),
              size: 22.sp,
              color: TColorsConst.blue500,
            ),
            TSpaces.h8(),
            Text('Deskripsi', style: TGoogleTextStyleConst.inter16Bold),
            TSpaces.h8(),
            Text(
              '(Opsional)',
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
          ],
        ),
        TSpaces.v12(),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Keterangan tambahan (opsional)',
            hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral400,
            ),
            filled: true,
            fillColor: TColorsConst.neutral50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: TColorsConst.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: TColorsConst.blue500,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoUploadSection extends StatelessWidget {
  final RxList<File> selectedPhotos;
  final ImagePicker picker;

  const _PhotoUploadSection({
    required this.selectedPhotos,
    required this.picker,
  });

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill)),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    selectedPhotos.add(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.image(PhosphorIconsStyle.fill)),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    selectedPhotos.add(File(image.path));
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.image(PhosphorIconsStyle.fill),
              size: 22.sp,
              color: TColorsConst.blue500,
            ),
            TSpaces.h8(),
            Text('Upload Foto', style: TGoogleTextStyleConst.inter16Bold),
            TSpaces.h8(),
            Text(
              '(Maks 4)',
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
            const Spacer(),
            // ElevatedButton.icon(
            //   onPressed: () async {
            //     if (selectedPhotos.length >= 4) {
            //       context.showWarningSnackBar('Maksimal 4 foto');
            //       return;
            //     }

            //     final XFile? image = await picker.pickImage(
            //       source: ImageSource.gallery,
            //       imageQuality: 80,
            //     );

            //     if (image != null) {
            //       selectedPhotos.add(File(image.path));
            //     }
            //   },
            //   icon: Icon(
            //     PhosphorIcons.plus(PhosphorIconsStyle.bold),
            //     size: 18.sp,
            //   ),
            //   label: Text(
            //     'Tambah',
            //     style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            //       color: TColorsConst.white,
            //     ),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: TColorsConst.blue500,
            //     foregroundColor: TColorsConst.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10.r),
            //     ),
            //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            //   ),
            // ),
          ],
        ),
        TSpaces.v12(),
        Obx(() {
          if (selectedPhotos.isEmpty) {
            return GestureDetector(
              onTap: () => _showImageSourcePicker(context),
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: TColorsConst.neutral50,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: TColorsConst.neutral300, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.image(PhosphorIconsStyle.light),
                        size: 40.sp,
                        color: TColorsConst.neutral400,
                      ),
                      TSpaces.v8(),
                      Text(
                        'Ketuk untuk tambah foto',
                        style: TGoogleTextStyleConst.inter14Regular.copyWith(
                          color: TColorsConst.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedPhotos.length,
              itemBuilder: (context, index) {
                return _PhotoItem(
                  photo: selectedPhotos[index],
                  onRemove: () => selectedPhotos.removeAt(index),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;

  const _PhotoItem({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.file(
              photo,
              width: 120.w,
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
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TColorsConst.red500, TColorsConst.red600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TColorsConst.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.x(PhosphorIconsStyle.bold),
                  color: TColorsConst.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColorsConst.blue500,
          foregroundColor: TColorsConst.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 4,
        ),
        onPressed: isOutsideVillage.value ? null : () => _handleSubmit(context),
        icon: Icon(
          PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
          size: 22.sp,
        ),
        label: Text(
          'Simpan Marker',
          style: TGoogleTextStyleConst.inter18Bold.copyWith(
            color: TColorsConst.white,
          ),
        ),
      ),
    );
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

    // Tampilkan loading dulu
    TLoaders.openLoadingDialogWithMessage('Menyimpan data...');

    try {
      await controller.addMarkerWithIcon(
        position,
        markerName,
        catatanController.text.trim(),
        selectedIconType.value,
        selectedPhotos,
      );

      // Tutup form setelah sukses simpan
      Get.back(); // tutup bottomsheet

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
      // Pastikan loading selalu ditutup
      TLoaders.stopLoading();
    }
  }
}
