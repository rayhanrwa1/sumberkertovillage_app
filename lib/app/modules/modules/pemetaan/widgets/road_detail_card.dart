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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== HEADER — subtle top strip + info =====
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Colored icon badge
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: roadData.condition.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _getIcon(),
                      color: roadData.condition.color,
                      size: 20.sp,
                    ),
                  ),
                  TSpaces.h12(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roadData.nama,
                          style: TGoogleTextStyleConst.inter16Bold.copyWith(
                            color: TColorsConst.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        TSpaces.v4(),

                        /// Condition chip
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: roadData.condition.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              roadData.condition.label,
                              style: TGoogleTextStyleConst.inter12SemiBold
                                  .copyWith(color: roadData.condition.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Close button
                  GestureDetector(
                    onTap: () => controller.clearSelectedRoad(),
                    child: Icon(
                      PhosphorIcons.x(PhosphorIconsStyle.regular),
                      color: TColorsConst.neutral400,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            TSpaces.v12(),

            /// ===== DIVIDER =====
            Divider(height: 1, color: TColorsConst.neutral100),

            /// ===== CONTENT =====
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Deskripsi
                  if (roadData.deskripsi != null &&
                      roadData.deskripsi!.isNotEmpty) ...[
                    Text(
                      roadData.deskripsi!,
                      style: TGoogleTextStyleConst.inter14Medium.copyWith(
                        color: TColorsConst.neutral600,
                      ),
                    ),
                    TSpaces.v12(),
                  ],

                  /// Info rows — clean & minimal
                  _buildInfoRow(
                    icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                    label: 'Jumlah Titik',
                    value: '${roadData.points.length} titik',
                  ),
                  if (roadData.createdAt != null) ...[
                    TSpaces.v10(),
                    _buildInfoRow(
                      icon: PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                      label: 'Ditambahkan',
                      value: DateFormat(
                        'dd MMM yyyy',
                        'id_ID',
                      ).format(roadData.createdAt!),
                    ),
                  ],

                  TSpaces.v16(),

                  /// Delete button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColorsConst.errorMain,
                        side: BorderSide(
                          color: TColorsConst.errorMain.withOpacity(0.4),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: Icon(
                        PhosphorIcons.trash(PhosphorIconsStyle.regular),
                        size: 17.sp,
                      ),
                      label: Text(
                        'Hapus',
                        style: TGoogleTextStyleConst.inter14SemiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        Icon(icon, color: TColorsConst.neutral400, size: 16.sp),
        TSpaces.h8(),
        Text(
          label,
          style: TGoogleTextStyleConst.inter14Medium.copyWith(
            color: TColorsConst.neutral500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: TColorsConst.neutral900,
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

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Hapus Jalan?', style: TGoogleTextStyleConst.inter16Bold),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${roadData.nama}"? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: TGoogleTextStyleConst.inter14Medium.copyWith(
            color: TColorsConst.neutral600,
          ),
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
                    side: BorderSide(color: TColorsConst.neutral200),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
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
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
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
