import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';  
import 'package:sumberkerto_smart_village/app/common/text_fields.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/utils/snackbar_utils.dart';
import '../controllers/pemetaan_controller.dart';

class AddJalanRusakForm extends StatefulWidget {
  final PemetaanController controller;

  const AddJalanRusakForm({super.key, required this.controller});

  @override
  State<AddJalanRusakForm> createState() => _AddJalanRusakFormState();
}

class _AddJalanRusakFormState extends State<AddJalanRusakForm> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DragHandle(),
            TSpaces.v20(),

            /// ===== TITLE =====
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: TColorsConst.errorMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill),
                    color: TColorsConst.errorMain,
                    size: 26.sp,
                  ),
                ),
                TSpaces.h12(),
                Text(
                  'Tambah Jalan Rusak',
                  style: TGoogleTextStyleConst.inter18Bold,
                ),
              ],
            ),

            TSpaces.v20(),

            /// ===== INFO POINT =====
            Obx(
              () => Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: TColorsConst.neutral50,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: TColorsConst.neutral300),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                      color: TColorsConst.blue500,
                    ),
                    TSpaces.h12(),
                    Expanded(
                      child: Text(
                        'Jumlah titik jalan: ${widget.controller.tempRoadPoints.length}',
                        style: TGoogleTextStyleConst.inter14SemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            TSpaces.v20(),

            /// ===== INPUT NAMA =====
            Text('Nama Jalan *', style: TGoogleTextStyleConst.inter14SemiBold),
            TSpaces.v8(),
            TTextFields.buildStandard(
              controller: namaController,
              hintText: 'Contoh: Jalan Dusun Krajan',
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
            ),

            TSpaces.v16(),

            /// ===== INPUT DESKRIPSI =====
            Text(
              'Deskripsi (Opsional)',
              style: TGoogleTextStyleConst.inter14SemiBold,
            ),
            TSpaces.v8(),
            TTextFields.buildStandard(
              controller: deskripsiController,
              hintText: 'Keterangan kondisi jalan',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),

            TSpaces.v24(),

            /// ===== BUTTON =====
            TButtons.primary(
              onPressed: _isSubmitting ? null : _handleSubmit,
              text: _isSubmitting ? 'Menyimpan...' : 'Simpan Jalan Rusak',
              height: 54.h,
              backgroundColor: TColorsConst.blue500,
              textColor: Colors.white,
              textStyle: TGoogleTextStyleConst.inter16Bold.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (namaController.text.trim().isEmpty) {
      context.showWarningSnackBar('Nama jalan harus diisi');
      return;
    }

    if (widget.controller.tempRoadPoints.length < 2) {
      context.showWarningSnackBar(
        'Minimal 2 titik diperlukan untuk membuat jalan',
      );
      return;
    }

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save
      await widget.controller.saveJalanRusak(
        namaController.text.trim(),
        deskripsiController.text.trim(),
      );

      // Close bottom sheet
      if (mounted) {
        Get.back();

        // Show success
        context.showSuccessSnackBar('Jalan rusak berhasil ditambahkan');
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        context.showErrorSnackBar('Gagal menyimpan jalan rusak');
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _DragHandle extends StatelessWidget {
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
