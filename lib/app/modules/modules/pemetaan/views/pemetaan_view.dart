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
import '../widgets/marker_detail_card.dart';
import '../widgets/marker_list_bottom_sheet.dart';

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

          Obx(() {
            final markerData = controller.selectedMarkerData.value;
            if (markerData == null) return const SizedBox.shrink();
            return MarkerDetailCard(
              markerData: markerData,
              controller: controller,
            );
          }),

          _buildCenterPointer(context),

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
          color: const Color.fromARGB(255, 64, 141, 255),
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
      ),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 139, 234)),
      actions: [
        IconButton(
          icon: Icon(PhosphorIcons.info(PhosphorIconsStyle.bold)),
          onPressed: () => _showInfoDialog(context),
          tooltip: 'Informasi',
        ),
        IconButton(
          icon: Icon(PhosphorIcons.list(PhosphorIconsStyle.bold)),
          onPressed: () => _showMarkerListBottomSheet(context),
          tooltip: 'Daftar Marker',
        ),
      ],
    );
  }

  Widget _buildGoogleMaps() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: Obx(
        () => controller.isLoading.value
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: TColorsConst.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: TColorsConst.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: TColorsConst.blue500,
                        strokeWidth: 3,
                      ),
                      TSpaces.v20(),
                      Text(
                        'Memuat peta Sumberkerto...',
                        style: TGoogleTextStyleConst.inter16Medium.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: centerSumberkerto,
                  zoom: 15.5,
                ),
                mapType: MapType.normal,
                zoomControlsEnabled: false,
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
                style: '''
                  [
                    {
                      "featureType": "poi",
                      "elementType": "labels",
                      "stylers": [{"visibility": "off"}]
                    }
                  ]
                ''',
              ),
      ),
    );
  }

  Widget _buildCenterPointer(BuildContext context) {
    // TODO: Ubah ignoring dari false ke true agar pointer tidak menghalangi interaksi peta. Tapi biarkan GestureDetector tetap bisa menerima tap
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              final center = controller.currentMapCenter.value;
              _showAddMarkerBottomSheet(context, center);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TColorsConst.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                TAssetsConst.pointer,
                width: 48.w,
                height: 48.h,
              ),
            ),
          ),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      right: 16.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              controller.mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            backgroundColor: TColorsConst.white,
            child: Icon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              color: TColorsConst.blue500,
            ),
          ),
          TSpaces.v8(),
          // Zoom Out
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              controller.mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            backgroundColor: TColorsConst.white,
            child: Icon(
              PhosphorIcons.minus(PhosphorIconsStyle.bold),
              color: TColorsConst.blue500,
            ),
          ),
          TSpaces.v8(),
          // Center to Village
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: () {
              controller.mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(centerSumberkerto, 15.5),
              );
            },
            backgroundColor: TColorsConst.white,
            child: Icon(
              PhosphorIcons.crosshairSimple(PhosphorIconsStyle.bold),
              color: TColorsConst.blue500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerListBottomSheet(BuildContext context) {
    Get.bottomSheet(
      MarkerListBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }

  void _showInfoDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white, // <-- ini
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColorsConst.blue500.withOpacity(0.1),
                    TColorsConst.blue600.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                PhosphorIcons.info(PhosphorIconsStyle.fill),
                color: TColorsConst.blue500,
                size: 28.sp,
              ),
            ),
            TSpaces.h12(),
            Text('Informasi Peta', style: TGoogleTextStyleConst.inter18Bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Desa', value: 'Sumberkerto'),
            _InfoRow(label: 'Kecamatan', value: 'Pagak'),
            _InfoRow(label: 'Kabupaten', value: 'Malang'),
            Obx(
              () => _InfoRow(
                label: 'Total Pemetaan',
                value: '${controller.markers.length}',
              ),
            ),
            Divider(height: 24.h),
            Text('Cara Penggunaan:', style: TGoogleTextStyleConst.inter16Bold),
            TSpaces.v12(),
            const _UsageRow(text: 'Tap pointer tengah untuk menambah marker'),
            const _UsageRow(text: 'Tap marker di peta untuk melihat detail'),
            const _UsageRow(text: 'Tap icon list untuk melihat semua marker'),
            const _UsageRow(text: 'Geser kiri marker untuk menghapus'),
            const _UsageRow(text: 'Upload foto maksimal 4 gambar'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColorsConst.blue500,
              foregroundColor: TColorsConst.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Tutup',
              style: TGoogleTextStyleConst.inter14Bold.copyWith(
                color: TColorsConst.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMarkerBottomSheet(BuildContext context, LatLng position) {
    Get.bottomSheet(
      AddMarkerForm(position: position, controller: controller),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }
}

// ============= HELPER WIDGETS =============

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
          ),
          Text(': ', style: TGoogleTextStyleConst.inter14Regular),
          Expanded(
            child: Text(value, style: TGoogleTextStyleConst.inter14SemiBold),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final String text;

  const _UsageRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: TColorsConst.blue500,
              shape: BoxShape.circle,
            ),
          ),
          TSpaces.h12(),
          Expanded(
            child: Text(
              text,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
