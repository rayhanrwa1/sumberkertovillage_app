import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/village_profile_controller.dart';

class ManageKepalaDesaHistoryView extends GetView<VillageProfileController> {
  const ManageKepalaDesaHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.neutral50,
      appBar: AppBar(
        backgroundColor: TColorsConst.blue500,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Sejarah Kepala Desa',
          style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBottomSheet(context),
        backgroundColor: Colors.white,
        foregroundColor: TColorsConst.blue500,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
        label: Text(
          'Tambah',
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: TColorsConst.blue500,
          ),
        ),
        elevation: 4,
      ),
      body: Obx(() {
        final history = controller.getDataObjectList('kepala_desa_history');

        if (history.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return _buildHistoryCard(context, item, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.userCircle(PhosphorIconsStyle.thin),
            size: 100,
            color: TColorsConst.neutral300,
          ),
          TSpaces.v16(),
          Text(
            'Belum Ada Data',
            style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
              color: TColorsConst.neutral800,
            ),
          ),
          TSpaces.v8(),
          Text(
            'Tap tombol + untuk menambahkan\nsejarah kepala desa',
            textAlign: TextAlign.center,
            style: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final isActive = item['isActive'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isActive ? TColorsConst.blue50 : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive ? TColorsConst.blue200 : TColorsConst.neutral200,
        ),
        boxShadow: [
          BoxShadow(
            color: TColorsConst.neutral300.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isActive ? TColorsConst.blue500 : TColorsConst.neutral400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item['nomor']}',
                style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          TSpaces.h16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['nama'] ?? '-',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: isActive
                              ? TColorsConst.blue700
                              : TColorsConst.neutral800,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: TColorsConst.green500,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'AKTIF',
                          style: TGoogleTextStyleConst.inter10SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                TSpaces.v4(),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                      size: 14.sp,
                      color: TColorsConst.neutral500,
                    ),
                    TSpaces.h4(),
                    Text(
                      item['periode'] ?? '-',
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral600,
                      ),
                    ),
                    TSpaces.h8(),
                    Text(
                      '(${item['durasi'] ?? '-'})',
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TSpaces.h8(),
          PopupMenuButton(
            icon: Icon(
              PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
              color: TColorsConst.neutral500,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.pencil(PhosphorIconsStyle.regular),
                      size: 16.sp,
                    ),
                    TSpaces.h8(),
                    const Text('Edit'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _showAddEditBottomSheet(
                    context,
                    item: item,
                    index: index,
                  ),
                ),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.trash(PhosphorIconsStyle.regular),
                      size: 16.sp,
                      color: TColorsConst.red500,
                    ),
                    TSpaces.h8(),
                    Text('Hapus', style: TextStyle(color: TColorsConst.red500)),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _showDeleteBottomSheet(context, index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditBottomSheet(
    BuildContext context, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final isEdit = item != null;
    final namaController = TextEditingController(text: item?['nama'] ?? '');
    final periodeController = TextEditingController(
      text: item?['periode'] ?? '',
    );
    final durasiController = TextEditingController(text: item?['durasi'] ?? '');
    final isActiveNotifier = ValueNotifier<bool>(item?['isActive'] ?? false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: TColorsConst.neutral300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Kepala Desa' : 'Tambah Kepala Desa',
                        style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        PhosphorIcons.x(PhosphorIconsStyle.bold),
                        color: TColorsConst.neutral500,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: TColorsConst.neutral200),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Ir. Hosen',
                          hintStyle: TGoogleTextStyleConst.inter14Regular
                              .copyWith(color: TColorsConst.neutral400),
                          filled: true,
                          fillColor: TColorsConst.neutral50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.blue500,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.regular),
                            color: TColorsConst.neutral500,
                          ),
                        ),
                      ),
                      TSpaces.v20(),

                      Text(
                        'Periode',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: periodeController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 2014 - Sekarang',
                          hintStyle: TGoogleTextStyleConst.inter14Regular
                              .copyWith(color: TColorsConst.neutral400),
                          filled: true,
                          fillColor: TColorsConst.neutral50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.blue500,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                            color: TColorsConst.neutral500,
                          ),
                        ),
                      ),
                      TSpaces.v20(),

                      Text(
                        'Durasi',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: durasiController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 10 tahun atau Aktif',
                          hintStyle: TGoogleTextStyleConst.inter14Regular
                              .copyWith(color: TColorsConst.neutral400),
                          filled: true,
                          fillColor: TColorsConst.neutral50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.neutral200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: TColorsConst.blue500,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            PhosphorIcons.clock(PhosphorIconsStyle.regular),
                            color: TColorsConst.neutral500,
                          ),
                        ),
                      ),
                      TSpaces.v20(),

                      // Checkbox for active status
                      ValueListenableBuilder<bool>(
                        valueListenable: isActiveNotifier,
                        builder: (context, isActive, _) {
                          return InkWell(
                            onTap: () {
                              isActiveNotifier.value = !isActive;
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? TColorsConst.blue50
                                    : TColorsConst.neutral50,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isActive
                                      ? TColorsConst.blue500
                                      : TColorsConst.neutral200,
                                  width: isActive ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? TColorsConst.blue500
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: isActive
                                            ? TColorsConst.blue500
                                            : TColorsConst.neutral300,
                                        width: 2,
                                      ),
                                    ),
                                    child: isActive
                                        ? Icon(
                                            PhosphorIcons.check(
                                              PhosphorIconsStyle.bold,
                                            ),
                                            color: Colors.white,
                                            size: 16.sp,
                                          )
                                        : null,
                                  ),
                                  TSpaces.h12(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kepala Desa Aktif',
                                          style: TGoogleTextStyleConst
                                              .inter14SemiBold
                                              .copyWith(
                                                color: isActive
                                                    ? TColorsConst.blue700
                                                    : TColorsConst.neutral800,
                                              ),
                                        ),
                                        TSpaces.v4(),
                                        Text(
                                          'Centang jika masih menjabat',
                                          style: TGoogleTextStyleConst
                                              .inter12Regular
                                              .copyWith(
                                                color: TColorsConst.neutral500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: TColorsConst.neutral200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: TColorsConst.neutral300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                            color: TColorsConst.neutral700,
                          ),
                        ),
                      ),
                    ),
                    TSpaces.h12(),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final data = {
                            'nama': namaController.text,
                            'periode': periodeController.text,
                            'durasi': durasiController.text,
                            'isActive': isActiveNotifier.value,
                          };

                          if (isEdit && index != null) {
                            controller.updateKepalaDesaHistory(
                              index,
                              data,
                              context,
                            );
                          } else {
                            controller.addKepalaDesaHistory(data, context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColorsConst.blue500,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Perbarui' : 'Tambah',
                          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  void _showDeleteBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(bottom: 20.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: TColorsConst.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: TColorsConst.red50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.trash(PhosphorIconsStyle.fill),
                color: TColorsConst.red500,
                size: 32.sp,
              ),
            ),
            TSpaces.v20(),

            // Title
            Text(
              'Hapus Data',
              style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
                color: TColorsConst.neutral800,
              ),
            ),
            TSpaces.v8(),

            // Description
            Text(
              'Apakah Anda yakin ingin menghapus data ini? Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
            TSpaces.v24(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: TColorsConst.neutral300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                        color: TColorsConst.neutral700,
                      ),
                    ),
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteKepalaDesaHistory(index, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColorsConst.red500,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
