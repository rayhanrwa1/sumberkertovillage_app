import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/pemetaan_controller.dart';

class MarkerDetailCard extends StatelessWidget {
  final Map<String, dynamic> markerData;
  final PemetaanController controller;

  const MarkerDetailCard({
    super.key,
    required this.markerData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final iconType = markerData['icon_type'] ?? '';
    final iconUrl = controller.iconMap[iconType] ?? '';
    final photos = markerData['photos'] ?? [];

    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: TColorsConst.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: TColorsConst.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MarkerHeader(
                iconUrl: iconUrl,
                iconType: iconType,
                markerData: markerData,
                controller: controller,
              ),
              if (markerData['note'] != null &&
                  markerData['note'].toString().isNotEmpty) ...[
                TSpaces.v16(),
                _NoteSection(note: markerData['note']),
              ],
              TSpaces.v16(),
              _CoordinateSection(markerData: markerData),
              if (photos is List && photos.isNotEmpty) ...[
                TSpaces.v16(),
                _PhotoGallery(photos: photos),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerHeader extends StatelessWidget {
  final String iconUrl;
  final String iconType;
  final Map<String, dynamic> markerData;
  final PemetaanController controller;

  const _MarkerHeader({
    required this.iconUrl,
    required this.iconType,
    required this.markerData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MarkerIcon(iconUrl: iconUrl),
        TSpaces.h12(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                markerData['nama_lokasi'] ?? 'Tanpa Nama',
                style: TGoogleTextStyleConst.inter18Bold.copyWith(
                  color: TColorsConst.neutral800,
                ),
              ),
              TSpaces.v4(),
              _IconTypeChip(iconType: iconType),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            PhosphorIcons.x(PhosphorIconsStyle.bold),
            color: TColorsConst.neutral600,
          ),
          onPressed: controller.closeMarkerDetail,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
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
            TColorsConst.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: iconUrl.isNotEmpty
          ? Image.network(
              iconUrl,
              width: 36.w,
              height: 36.h,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  size: 36.sp,
                  color: TColorsConst.blue500,
                );
              },
            )
          : Icon(
              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
              size: 36.sp,
              color: TColorsConst.blue500,
            ),
    );
  }
}

class _IconTypeChip extends StatelessWidget {
  final String iconType;

  const _IconTypeChip({required this.iconType});

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _NoteSection extends StatelessWidget {
  final String note;

  const _NoteSection({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TColorsConst.neutral50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TColorsConst.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.note(PhosphorIconsStyle.fill),
            size: 18.sp,
            color: TColorsConst.blue500,
          ),
          TSpaces.h12(),
          Expanded(
            child: Text(
              note,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinateSection extends StatelessWidget {
  final Map<String, dynamic> markerData;

  const _CoordinateSection({required this.markerData});

  @override
  Widget build(BuildContext context) {
    final double lat = markerData['latitude'];
    final double lng = markerData['longitude'];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TColorsConst.neutral50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TColorsConst.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                size: 16.sp,
                color: TColorsConst.blue500,
              ),
              TSpaces.h8(),
              Text(
                'Alamat',
                style: TGoogleTextStyleConst.inter12Bold.copyWith(
                  color: TColorsConst.neutral800,
                ),
              ),
            ],
          ),
          TSpaces.v10(),
          FutureBuilder<String>(
            future: PemetaanController.to.getAddressFromLatLng(lat, lng),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Mengambil alamat...");
              }
              return Text(
                snapshot.data ?? "Alamat tidak ditemukan",
                style: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: TColorsConst.neutral700,
                  height: 1.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  final List photos;

  const _PhotoGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 10.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                photos[index],
                width: 90.w,
                height: 90.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90.w,
                    height: 90.h,
                    color: TColorsConst.neutral300,
                    child: Icon(
                      PhosphorIcons.image(PhosphorIconsStyle.fill),
                      color: TColorsConst.neutral400,
                      size: 32.sp,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
