import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:intl/intl.dart';
import '../models/road_model.dart';
import '../controllers/pemetaan_controller.dart';

class RoadDetailCard extends StatelessWidget {
  final RoadData roadData;
  final PemetaanController controller;

  const RoadDetailCard({
    super.key,
    required this.roadData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== HEADER =====
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: roadData.condition.color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(_getIcon(), color: Colors.white, size: 24.sp),
                    ),
                    TSpaces.h12(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roadData.condition.label,
                            style: TGoogleTextStyleConst.inter12SemiBold
                                .copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          TSpaces.v4(),
                          Text(
                            roadData.nama,
                            style: TGoogleTextStyleConst.inter16Bold.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TSpaces.h8(),
                    GestureDetector(
                      onTap: () => controller.clearSelectedRoad(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          PhosphorIcons.x(PhosphorIconsStyle.bold),
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ===== CONTENT =====
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Deskripsi
                    if (roadData.deskripsi != null &&
                        roadData.deskripsi!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            PhosphorIcons.textAlignLeft(
                              PhosphorIconsStyle.bold,
                            ),
                            color: TColorsConst.neutral600,
                            size: 18.sp,
                          ),
                          TSpaces.h8(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: TGoogleTextStyleConst.inter12SemiBold
                                      .copyWith(color: TColorsConst.neutral500),
                                ),
                                TSpaces.v4(),
                                Text(
                                  roadData.deskripsi!,
                                  style: TGoogleTextStyleConst.inter14Medium
                                      .copyWith(color: TColorsConst.neutral900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      TSpaces.v16(),
                    ],

                    /// Info Grid
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: TColorsConst.neutral50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: TColorsConst.neutral200),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                            label: 'Jumlah Titik',
                            value: '${roadData.points.length} titik',
                          ),
                          if (roadData.createdAt != null) ...[
                            TSpaces.v8(),
                            Divider(height: 1, color: TColorsConst.neutral200),
                            TSpaces.v8(),
                            _buildInfoRow(
                              icon: PhosphorIcons.calendar(
                                PhosphorIconsStyle.fill,
                              ),
                              label: 'Ditambahkan',
                              value: DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(roadData.createdAt!),
                            ),
                          ],
                        ],
                      ),
                    ),

                    TSpaces.v16(),

                    /// Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: TColorsConst.errorMain,
                              side: BorderSide(color: TColorsConst.errorMain),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(
                              PhosphorIcons.trash(PhosphorIconsStyle.bold),
                              size: 18.sp,
                            ),
                            label: Text(
                              'Hapus',
                              style: TGoogleTextStyleConst.inter14SemiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: TColorsConst.blue500, size: 18.sp),
        TSpaces.h12(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TGoogleTextStyleConst.inter12Medium.copyWith(
                  color: TColorsConst.neutral500,
                ),
              ),
              TSpaces.v4(),
              Text(
                value,
                style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                  color: TColorsConst.neutral900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (roadData.condition) {
      case RoadCondition.rusak:
        return PhosphorIcons.warning(PhosphorIconsStyle.fill);
      case RoadCondition.gelap:
        return PhosphorIcons.lightbulb(PhosphorIconsStyle.fill);
      case RoadCondition.kabupaten:
        return PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill);
    }
  }

  void _showEditDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white, // ✅ Background putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
              color: TColorsConst.blue500,
            ),
            TSpaces.h12(),
            Text('Edit Jalan', style: TGoogleTextStyleConst.inter18Bold),
          ],
        ),
        content: Text(
          'Fitur edit jalan akan segera tersedia.\n\nSaat ini Anda dapat menghapus jalan lama dan membuat yang baru.',
          style: TGoogleTextStyleConst.inter14Medium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColorsConst.blue500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Mengerti',
              style: TGoogleTextStyleConst.inter14Bold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white, // ✅ Background putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: TColorsConst.errorMain,
              size: 24.sp,
            ),
            TSpaces.h12(),
            Expanded(
              child: Text(
                'Hapus Jalan?',
                style: TGoogleTextStyleConst.inter18Bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${roadData.nama}"?\n\nTindakan ini tidak dapat dibatalkan.',
          style: TGoogleTextStyleConst.inter14Medium,
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColorsConst.neutral600,
                    side: BorderSide(color: TColorsConst.neutral300),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TGoogleTextStyleConst.inter14SemiBold,
                  ),
                ),
              ),
              TSpaces.h12(),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.deleteRoad(roadData.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorsConst.errorMain,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Hapus',
                    style: TGoogleTextStyleConst.inter14Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
