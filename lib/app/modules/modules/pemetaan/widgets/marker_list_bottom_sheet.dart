import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/pemetaan_controller.dart';

class MarkerListBottomSheet extends StatelessWidget {
  final PemetaanController controller;

  const MarkerListBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _Header(controller: controller),
          Expanded(child: _MarkerList(controller: controller)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PemetaanController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: TColorsConst.neutral200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _DragHandle(),
          TSpaces.v16(),
          _TitleSection(controller: controller),
          TSpaces.v16(),
          _SearchBar(controller: controller),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: TColorsConst.neutral300,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final PemetaanController controller;

  const _TitleSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TColorsConst.blue500.withOpacity(0.1),
                TColorsConst.blue600.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            PhosphorIcons.list(PhosphorIconsStyle.bold),
            color: TColorsConst.blue500,
            size: 24.sp,
          ),
        ),
        TSpaces.h12(),
        Text('Daftar Marker', style: TGoogleTextStyleConst.inter20Bold),
        const Spacer(),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TColorsConst.blue500, TColorsConst.blue600],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${controller.filteredMarkers.length}',
              style: TGoogleTextStyleConst.inter14Bold.copyWith(
                color: TColorsConst.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final PemetaanController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => controller.searchMarkers(value),
      decoration: InputDecoration(
        hintText: 'Cari marker...',
        hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
          color: TColorsConst.neutral400,
        ),
        prefixIcon: Icon(
          PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold),
          color: TColorsConst.blue500,
        ),
        filled: true,
        fillColor: TColorsConst.neutral50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: TColorsConst.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: TColorsConst.blue500, width: 2),
        ),
      ),
    );
  }
}

class _MarkerList extends StatelessWidget {
  final PemetaanController controller;

  const _MarkerList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredMarkers.isEmpty) {
        return _EmptyState(searchQuery: controller.searchQuery.value);
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.filteredMarkers.length,
        itemBuilder: (context, index) {
          final marker = controller.filteredMarkers[index];
          final markerId = marker['id'];

          return _MarkerListItem(
            marker: marker,
            markerId: markerId,
            controller: controller,
          );
        },
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final String searchQuery;

  const _EmptyState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsLight.mapPin,
            size: 80.sp,
            color: TColorsConst.neutral400,
          ),
          TSpaces.v16(),
          Text(
            searchQuery.isEmpty ? 'Belum ada marker' : 'Marker tidak ditemukan',
            style: TGoogleTextStyleConst.inter16Medium.copyWith(
              color: TColorsConst.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerListItem extends StatelessWidget {
  final Map<String, dynamic> marker;
  final String markerId;
  final PemetaanController controller;

  const _MarkerListItem({
    required this.marker,
    required this.markerId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final iconType = marker['icon_type'] ?? '';
    final iconUrl = controller.iconMap[iconType] ?? '';

    return Dismissible(
      key: Key(markerId),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) => controller.deleteMarker(markerId),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: TColorsConst.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: TColorsConst.neutral200),
          boxShadow: [
            BoxShadow(
              color: TColorsConst.neutral200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16.w),
          leading: _MarkerIcon(iconUrl: iconUrl),
          title: Text(
            marker['nama_lokasi'] ?? 'Tanpa Nama',
            style: TGoogleTextStyleConst.inter16Bold,
          ),
          subtitle: _MarkerSubtitle(marker: marker, iconType: iconType),
          trailing: Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
            color: TColorsConst.blue500,
          ),
          onTap: () {
            Get.back();
            controller.onMarkerTapped(markerId);
          },
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white, // <-- ini biar putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: TColorsConst.warningMain,
              size: 28.sp,
            ),
            TSpaces.h12(),
            Text('Hapus Marker?', style: TGoogleTextStyleConst.inter18Bold),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus marker "${marker['nama_lokasi']}"?',
          style: TGoogleTextStyleConst.inter14Regular,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Batal',
              style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColorsConst.errorMain,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Hapus',
              style: TGoogleTextStyleConst.inter14Bold.copyWith(
                color: TColorsConst.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TColorsConst.red500, TColorsConst.red600],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      child: Icon(
        PhosphorIcons.trash(PhosphorIconsStyle.bold),
        color: TColorsConst.white,
        size: 28.sp,
      ),
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  final String iconUrl;

  const _MarkerIcon({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: iconUrl.isNotEmpty
          ? Image.network(
              iconUrl,
              width: 32.w,
              height: 32.h,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  size: 32.sp,
                  color: const Color.fromARGB(255, 255, 255, 255),
                );
              },
            )
          : Icon(
              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
              size: 32.sp,
              color: TColorsConst.blue500,
            ),
    );
  }
}

class _MarkerSubtitle extends StatelessWidget {
  final Map<String, dynamic> marker;
  final String iconType;

  const _MarkerSubtitle({required this.marker, required this.iconType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TSpaces.v4(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: TColorsConst.blue500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            _getIconLabel(iconType),
            style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
              color: TColorsConst.blue600,
            ),
          ),
        ),
        if (marker['note'] != null && marker['note'].toString().isNotEmpty) ...[
          TSpaces.v4(),
          Text(
            marker['note'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: TColorsConst.neutral600,
            ),
          ),
        ],
      ],
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
