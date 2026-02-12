import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/village_profile_controller.dart';

class ManageTimelineSejarahView extends GetView<VillageProfileController> {
  const ManageTimelineSejarahView({super.key});

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
          'Timeline Sejarah',
          style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBottomSheet(context),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: TColorsConst.blue500.withOpacity(0.3)),
        ),
        icon: Icon(
          PhosphorIcons.plus(PhosphorIconsStyle.bold),
          color: TColorsConst.blue500,
        ),
        label: Text(
          'Tambah',
          style: TextStyle(
            color: TColorsConst.blue500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        final timeline = controller.getDataObjectList('timeline_sejarah');

        if (timeline.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              return _buildTimelineCard(context, item, index);
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
            PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.thin),
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
            'Tap tombol + untuk menambahkan\ntimeline sejarah desa',
            textAlign: TextAlign.center,
            style: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: TColorsConst.blue500,
                  shape: BoxShape.circle,
                  border: Border.all(color: TColorsConst.blue200, width: 3),
                ),
              ),
              if (index <
                  controller.getDataObjectList('timeline_sejarah').length - 1)
                Container(
                  width: 2.w,
                  height: 80.h,
                  color: TColorsConst.blue200,
                ),
            ],
          ),
          TSpaces.h12(),

          // Content card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: TColorsConst.neutral200),
                boxShadow: [
                  BoxShadow(
                    color: TColorsConst.neutral300.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: TColorsConst.blue50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            item['tahun'] ?? '-',
                            style: TGoogleTextStyleConst.inter12SemiBold
                                .copyWith(color: TColorsConst.blue600),
                          ),
                        ),
                      ),
                      TSpaces.h8(),
                      PopupMenuButton(
                        icon: Icon(
                          PhosphorIcons.dotsThreeVertical(
                            PhosphorIconsStyle.bold,
                          ),
                          color: TColorsConst.neutral500,
                          size: 20.sp,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.pencil(
                                    PhosphorIconsStyle.regular,
                                  ),
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
                                  PhosphorIcons.trash(
                                    PhosphorIconsStyle.regular,
                                  ),
                                  size: 16.sp,
                                  color: TColorsConst.red500,
                                ),
                                TSpaces.h8(),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: TColorsConst.red500),
                                ),
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
                  TSpaces.v8(),
                  Text(
                    item['judul'] ?? '-',
                    style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                      color: TColorsConst.neutral800,
                    ),
                  ),
                  if ((item['deskripsi'] ?? '').isNotEmpty) ...[
                    TSpaces.v4(),
                    Text(
                      item['deskripsi'],
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral600,
                        height: 1.5,
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
  }

  void _showAddEditBottomSheet(
    BuildContext context, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final isEdit = item != null;
    final tahunController = TextEditingController(text: item?['tahun'] ?? '');
    final judulController = TextEditingController(text: item?['judul'] ?? '');
    final deskripsiController = TextEditingController(
      text: item?['deskripsi'] ?? '',
    );

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
                        isEdit ? 'Edit Timeline' : 'Tambah Timeline',
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
                        'Tahun',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: tahunController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 1910 atau Era Kolonial',
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
                        'Judul Peristiwa',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: judulController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Pemecahan Desa',
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
                            PhosphorIcons.textT(PhosphorIconsStyle.regular),
                            color: TColorsConst.neutral500,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      TSpaces.v20(),

                      Text(
                        'Deskripsi (Opsional)',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      TSpaces.v8(),
                      TextField(
                        controller: deskripsiController,
                        decoration: InputDecoration(
                          hintText: 'Penjelasan singkat tentang peristiwa',
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
                            PhosphorIcons.article(PhosphorIconsStyle.regular),
                            color: TColorsConst.neutral500,
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
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
                          if (tahunController.text.isEmpty ||
                              judulController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Tahun dan Judul harus diisi',
                              backgroundColor: TColorsConst.red500,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          final data = {
                            'tahun': tahunController.text,
                            'judul': judulController.text,
                            'deskripsi': deskripsiController.text,
                          };

                          if (isEdit && index != null) {
                            controller.updateTimelineSejarah(
                              index,
                              data,
                              context,
                            );
                          } else {
                            controller.addTimelineSejarah(data, context);
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
              'Hapus Timeline',
              style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
                color: TColorsConst.neutral800,
              ),
            ),
            TSpaces.v8(),

            // Description
            Text(
              'Apakah Anda yakin ingin menghapus timeline ini? Tindakan ini tidak dapat dibatalkan.',
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
                      controller.deleteTimelineSejarah(index, context);
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
