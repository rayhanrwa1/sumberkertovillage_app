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
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: IgnorePointer(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: condition?.color ?? TColorsConst.errorMain,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mode Gambar Jalan: ${condition?.label ?? ""}',
                        textAlign: TextAlign.center,
                        style: TGoogleTextStyleConst.inter14Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      TSpaces.v4(),
                      Text(
                        'Titik: $pointCount | Tap pointer untuk menambah',
                        textAlign: TextAlign.center,
                        style: TGoogleTextStyleConst.inter12Medium.copyWith(
                          color: Colors.white.withOpacity(0.9),
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

          Obx(() {
            final roadData = controller.selectedRoadData.value;
            if (roadData == null) return const SizedBox.shrink();
            return RoadDetailCard(roadData: roadData, controller: controller);
          }),

          _buildCenterPointer(context),

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
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      TSpaces.h12(),
                      Text(
                        'Mencari rute...',
                        style: TGoogleTextStyleConst.inter14Medium.copyWith(
                          color: Colors.white,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Desa Sumberkerto',
        style: TGoogleTextStyleConst.inter16Bold.copyWith(
          color: TColorsConst.blue500,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: TColorsConst.blue500),
      actions: [
        // IconButton(
        //   icon: Icon(PhosphorIcons.info(PhosphorIconsStyle.bold)),
        //   onPressed: () => _showInfoDialog(context),
        // ),
        IconButton(
          icon: Icon(PhosphorIcons.list(PhosphorIconsStyle.bold)),
          onPressed: () => _showMarkerListBottomSheet(context),
        ),
      ],
    );
  }

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

  Widget _buildCenterPointer(BuildContext context) {
    return Obx(() {
      final isDrawing = controller.isDrawingRoad.value;
      final isLoading = controller.isLoadingRoute.value;
      final hasMarkerDetail = controller.selectedMarkerData.value != null;
      final hasRoadDetail = controller.selectedRoadData.value != null;

      if (isLoading) {
        return const SizedBox.shrink();
      }

      if (hasMarkerDetail || hasRoadDetail) {
        return const SizedBox.shrink();
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final center = controller.currentMapCenter.value;

                if (isDrawing) {
                  // Add road point with route
                  await controller.addRoadPointWithRoute(center);
                } else {
                  // Add marker
                  _showAddMarkerBottomSheet(context, center);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    // Pointer icon
                    Image.asset(
                      TAssetsConst.pointer,
                      width: isDrawing ? 56.w : 48.w,
                      height: isDrawing ? 56.h : 48.h,
                      color: isDrawing
                          ? controller.selectedRoadCondition.value?.color
                          : null,
                    ),

                    // Label for road mode
                    if (isDrawing) ...[
                      TSpaces.v8(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12.r),
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
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      right: 16.w,
      child: Obx(() {
        if (controller.isDrawingRoad.value) {
          return Column(
            children: [
              // Finish button
              FloatingActionButton.extended(
                heroTag: 'finish_road',
                backgroundColor: TColorsConst.blue500,
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
                icon: Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
                  color: Colors.white,
                ),
                label: Text(
                  'Selesai (${controller.tempRoadPoints.length})',
                  style: TGoogleTextStyleConst.inter14Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              TSpaces.v8(),

              // Undo button
              if (controller.tempRoadPoints.length > 0)
                FloatingActionButton.small(
                  heroTag: 'undo_point',
                  backgroundColor: TColorsConst.blue500,
                  onPressed: () {
                    if (controller.tempRoadPoints.isNotEmpty) {
                      controller.tempRoadPoints.removeLast();
                      controller.updateTempPolyline();
                    }
                  },
                  child: Icon(
                    PhosphorIcons.arrowCounterClockwise(
                      PhosphorIconsStyle.bold,
                    ),
                    color: Colors.white,
                  ),
                ),

              if (controller.tempRoadPoints.length > 0) TSpaces.v8(),

              // Cancel button
              FloatingActionButton.small(
                heroTag: 'cancel_road',
                backgroundColor: TColorsConst.blue500,
                onPressed: () {
                  controller.cancelDrawingRoad();
                },
                child: Icon(
                  PhosphorIcons.x(PhosphorIconsStyle.bold),
                  color: Colors.white,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            // Draw road button
            FloatingActionButton(
              heroTag: 'draw_road',
              backgroundColor: TColorsConst.blue500,
              onPressed: () {
                _showRoadTypePicker(context);
              },
              child: Icon(
                PhosphorIcons.roadHorizon(PhosphorIconsStyle.bold),
                color: Colors.white,
              ),
            ),

            TSpaces.v8(),

            // Center button
            FloatingActionButton.small(
              heroTag: 'center',
              backgroundColor: TColorsConst.blue500,
              onPressed: () {
                controller.mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(centerSumberkerto, 15.5),
                );
              },
              child: Icon(
                PhosphorIcons.crosshairSimple(PhosphorIconsStyle.bold),
                color: Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showRoadTypePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TSpaces.v8(),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: TColorsConst.neutral300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              TSpaces.v16(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Pilih Jenis Jalan',
                  style: TGoogleTextStyleConst.inter18Bold,
                ),
              ),

              TSpaces.v16(),

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

                return ListTile(
                  leading: Icon(icon, color: condition.color),
                  title: Text(
                    condition.label,
                    style: TGoogleTextStyleConst.inter16Medium,
                  ),
                  onTap: () {
                    Get.back();
                    controller.startDrawingRoad(condition);
                  },
                );
              }).toList(),

              TSpaces.v16(),
            ],
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

  // void _showInfoDialog(BuildContext context) {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Informasi Peta'),
  //       content: const Text(
  //         'Gunakan pointer di tengah peta untuk:\n\n'
  //         '• Menambah marker lokasi\n'
  //         '• Menambah titik jalan saat mode gambar jalan aktif\n\n'
  //         'Jalan akan otomatis mengikuti rute yang ada.\n\n'
  //         'Tap pada polyline untuk melihat detail jalan.',
  //       ),
  //       actions: [TextButton(onPressed: Get.back, child: const Text('Tutup'))],
  //     ),
  //   );
  // }
}
