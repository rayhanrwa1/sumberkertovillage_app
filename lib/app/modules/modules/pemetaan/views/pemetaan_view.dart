import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/pemetaan_controller.dart';
import '../widgets/add_marker_form.dart';
import '../widgets/add_jalan_rusak_form.dart';
import '../widgets/marker_detail_card.dart';
import '../widgets/marker_list_bottom_sheet.dart';
import '../widgets/road_detail_card.dart';
import '../models/road_model.dart';

class PemetaanView extends GetView<PemetaanController> {
  const PemetaanView({super.key});

  static const LatLng centerSumberkerto = LatLng(-8.2759891, 112.5334492);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.neutral50,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildGoogleMaps(),

          /// ===== BANNER MODE GAMBAR JALAN =====
          Obx(() {
            if (!controller.isDrawingRoad.value) {
              return const SizedBox.shrink();
            }

            final condition = controller.selectedRoadCondition.value;
            final pointCount = controller.tempRoadPoints.length;

            return Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: IgnorePointer(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: (condition?.color ?? TColorsConst.errorMain)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: (condition?.color ?? TColorsConst.errorMain)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill),
                          color: condition?.color ?? TColorsConst.errorMain,
                          size: 16.sp,
                        ),
                      ),
                      TSpaces.h12(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              condition?.label ?? '',
                              style: TGoogleTextStyleConst.inter14SemiBold
                                  .copyWith(color: TColorsConst.neutral900),
                            ),
                            TSpaces.v4(),
                            Text(
                              '$pointCount titik | Tap pointer untuk menambah',
                              style: TGoogleTextStyleConst.inter12Medium
                                  .copyWith(color: TColorsConst.neutral500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          /// ===== DETAIL MARKER =====
          Obx(() {
            final markerData = controller.selectedMarkerData.value;
            if (markerData == null) return const SizedBox.shrink();
            return MarkerDetailCard(
              markerData: markerData,
              controller: controller,
            );
          }),

          /// ===== DETAIL ROAD =====
          Obx(() {
            final roadData = controller.selectedRoadData.value;
            if (roadData == null) return const SizedBox.shrink();
            return RoadDetailCard(roadData: roadData, controller: controller);
          }),

          /// ===== CENTER POINTER =====
          _buildCenterPointer(context),

          /// ===== LOADING ROUTE =====
          Obx(() {
            if (!controller.isLoadingRoute.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 100.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            TColorsConst.blue500,
                          ),
                        ),
                      ),
                      TSpaces.h12(),
                      Text(
                        'Mencari rute...',
                        style: TGoogleTextStyleConst.inter14Medium.copyWith(
                          color: TColorsConst.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          /// ===== FAB =====
          _buildFloatingActionButtons(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Desa Sumberkerto',
        style: TGoogleTextStyleConst.inter16Bold.copyWith(
          color: TColorsConst.neutral900,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: TColorsConst.neutral600),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: IconButton(
            icon: Icon(
              PhosphorIcons.list(PhosphorIconsStyle.regular),
              size: 20.sp,
            ),
            onPressed: () => _showMarkerListBottomSheet(context),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // GOOGLE MAPS
  // ---------------------------------------------------------------------------
  Widget _buildGoogleMaps() {
    return Obx(
      () => GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: centerSumberkerto,
          zoom: 15.5,
        ),
        markers: controller.markers.toSet(),
        polylines: controller.polylines,
        myLocationEnabled: controller.hasLocationPermission.value,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        compassEnabled: true,
        onMapCreated: (c) => controller.mapController = c,
        onCameraMove: (pos) => controller.currentMapCenter.value = pos.target,
        onTap: (position) {
          controller.selectedMarkerData.value = null;
          controller.selectedRoadData.value = null;
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CENTER POINTER
  // ---------------------------------------------------------------------------
  Widget _buildCenterPointer(BuildContext context) {
    return Obx(() {
      final isDrawing = controller.isDrawingRoad.value;
      final isLoading = controller.isLoadingRoute.value;
      final hasMarkerDetail = controller.selectedMarkerData.value != null;
      final hasRoadDetail = controller.selectedRoadData.value != null;

      if (isLoading || hasMarkerDetail || hasRoadDetail) {
        return const SizedBox.shrink();
      }

      return Center(
        child: GestureDetector(
          onTap: () async {
            final center = controller.currentMapCenter.value;
            if (isDrawing) {
              await controller.addRoadPointWithRoute(center);
            } else {
              _showAddMarkerBottomSheet(context, center);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                TAssetsConst.pointer,
                width: isDrawing ? 52.w : 44.w,
                height: isDrawing ? 52.h : 44.h,
                color: isDrawing
                    ? controller.selectedRoadCondition.value?.color
                    : null,
              ),
              if (isDrawing) ...[
                TSpaces.v8(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'TAP DISINI',
                    style: TGoogleTextStyleConst.inter10Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // FLOATING ACTION BUTTONS
  // ---------------------------------------------------------------------------
  Widget _buildFloatingActionButtons(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      right: 16.w,
      child: Obx(() {
        if (controller.isDrawingRoad.value) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Finish
              FloatingActionButton(
                heroTag: 'finish_road',
                backgroundColor: TColorsConst.blue500,
                elevation: 4,
                onPressed: () {
                  if (controller.tempRoadPoints.length < 2) {
                    Get.snackbar(
                      'Peringatan',
                      'Minimal 2 titik diperlukan',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  Get.bottomSheet(
                    AddJalanRusakForm(controller: controller),
                    isScrollControlled: true,
                  );
                },
                child: Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),

              /// Undo
              if (controller.tempRoadPoints.isNotEmpty) ...[
                TSpaces.v8(),
                FloatingActionButton.small(
                  heroTag: 'undo_point',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    controller.tempRoadPoints.removeLast();
                    controller.updateTempPolyline();
                  },
                  child: Icon(
                    PhosphorIcons.arrowCounterClockwise(
                      PhosphorIconsStyle.regular,
                    ),
                    color: TColorsConst.neutral600,
                    size: 20.sp,
                  ),
                ),
              ],

              /// Cancel
              TSpaces.v8(),
              FloatingActionButton.small(
                heroTag: 'cancel_road',
                backgroundColor: Colors.white,
                elevation: 4,
                onPressed: () => controller.cancelDrawingRoad(),
                child: Icon(
                  PhosphorIcons.x(PhosphorIconsStyle.regular),
                  color: TColorsConst.neutral600,
                  size: 20.sp,
                ),
              ),
            ],
          );
        }

        /// Default FABs
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Draw road
            FloatingActionButton(
              heroTag: 'draw_road',
              backgroundColor: TColorsConst.blue500,
              elevation: 4,
              onPressed: () => _showRoadTypePicker(context),
              child: Icon(
                PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 22.sp,
              ),
            ),

            /// Center map
            TSpaces.v8(),
            FloatingActionButton.small(
              heroTag: 'center',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                controller.mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(centerSumberkerto, 15.5),
                );
              },
              child: Icon(
                PhosphorIcons.crosshairSimple(PhosphorIconsStyle.regular),
                color: TColorsConst.neutral600,
                size: 20.sp,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM SHEETS
  // ---------------------------------------------------------------------------
  void _showRoadTypePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Drag handle
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
                TSpaces.v16(),

                /// Title
                Text(
                  'Pilih Jenis Jalan',
                  style: TGoogleTextStyleConst.inter16Bold.copyWith(
                    color: TColorsConst.neutral900,
                  ),
                ),
                TSpaces.v16(),

                /// Options
                ...RoadCondition.values.map((condition) {
                  IconData icon;
                  switch (condition) {
                    case RoadCondition.rusak:
                      icon = PhosphorIcons.warning(PhosphorIconsStyle.fill);
                      break;
                    case RoadCondition.gelap:
                      icon = PhosphorIcons.lightbulb(PhosphorIconsStyle.fill);
                      break;
                    case RoadCondition.kabupaten:
                      icon = PhosphorIcons.roadHorizon(PhosphorIconsStyle.fill);
                      break;
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.startDrawingRoad(condition);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: condition.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              icon,
                              color: condition.color,
                              size: 18.sp,
                            ),
                          ),
                          TSpaces.h12(),
                          Text(
                            condition.label,
                            style: TGoogleTextStyleConst.inter14Medium.copyWith(
                              color: TColorsConst.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                TSpaces.v8(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkerListBottomSheet(BuildContext context) {
    Get.bottomSheet(
      MarkerListBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }

  void _showAddMarkerBottomSheet(BuildContext context, LatLng position) {
    Get.bottomSheet(
      AddMarkerForm(position: position, controller: controller),
      isScrollControlled: true,
    );
  }
}
