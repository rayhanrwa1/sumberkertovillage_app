import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag handle
            const _DragHandle(),
            TSpaces.v20(),

            /// ===== TITLE =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: TColorsConst.blue500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill),
                    color: TColorsConst.blue500,
                    size: 20.sp,
                  ),
                ),
                TSpaces.h12(),
                Text(
                  'Tambah Jalan',
                  style: TGoogleTextStyleConst.inter16Bold.copyWith(
                    color: TColorsConst.neutral900,
                  ),
                ),
              ],
            ),

            TSpaces.v20(),

            /// ===== INFO POINT + WARNING =====
            Obx(() {
              final int count = widget.controller.tempRoadPoints.length;
              final bool hasOutside = widget.controller.hasPointOutsidePolygon;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Jumlah titik
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                        color: TColorsConst.blue500,
                        size: 16.sp,
                      ),
                      TSpaces.h8(),
                      Text(
                        '$count titik ditandai',
                        style: TGoogleTextStyleConst.inter14Medium.copyWith(
                          color: TColorsConst.neutral500,
                        ),
                      ),
                    ],
                  ),

                  /// Warning: ada titik di luar desa
                  if (hasOutside) ...[
                    TSpaces.v10(),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: TColorsConst.errorMain.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: TColorsConst.errorMain.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            PhosphorIcons.warning(PhosphorIconsStyle.fill),
                            color: TColorsConst.errorMain,
                            size: 16.sp,
                          ),
                          TSpaces.h8(),
                          Expanded(
                            child: Text(
                              'Beberapa titik berada di luar wilayah Desa Sumberkerto. '
                              'Hapus titik yang di luar untuk dapat menyimpan jalan.',
                              style: TGoogleTextStyleConst.inter12Medium
                                  .copyWith(color: TColorsConst.errorMain),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),

            TSpaces.v20(),

            /// ===== INPUT NAMA =====
            Text(
              'Nama Jalan',
              style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
            TSpaces.v8(),
            TTextFields.buildStandard(
              controller: namaController,
              hintText: 'Contoh: Jalan Dusun Krajan',
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
            ),

            TSpaces.v12(),

            /// ===== INPUT DESKRIPSI =====
            Text(
              'Deskripsi',
              style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                color: TColorsConst.neutral600,
              ),
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
            Obx(() {
              final bool hasOutside = widget.controller.hasPointOutsidePolygon;
              final bool isDisabled = _isSubmitting || hasOutside;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDisabled ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorsConst.blue500,
                    disabledBackgroundColor: TColorsConst.blue500.withOpacity(
                      0.3,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan',
                    style: TGoogleTextStyleConst.inter14Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.controller.saveJalanRusak(
        namaController.text.trim(),
        deskripsiController.text.trim(),
      );

      // Tutup bottom sheet — snackbar sukses/error sudah di controller
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: TColorsConst.neutral300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
