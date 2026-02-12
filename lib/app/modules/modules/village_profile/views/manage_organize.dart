import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/village_profile_controller.dart';

class ManageOrganizationView extends GetView<VillageProfileController> {
  const ManageOrganizationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    final String organizationType = args['type'];
    final String title = args['title'];
    final List<String> fields = List<String>.from(args['fields']);

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
          title,
          style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddEditBottomSheet(context, organizationType, fields, title),
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
        final members = controller.getDataObjectList(organizationType);

        if (members.isEmpty) {
          return _buildEmptyState(title);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(
                context,
                member,
                index,
                organizationType,
                fields,
                title,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.users(PhosphorIconsStyle.thin),
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
            'Tap tombol + untuk menambahkan\nanggota $title',
            textAlign: TextAlign.center,
            style: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Map<String, dynamic> member,
    int index,
    String organizationType,
    List<String> fields,
    String title,
  ) {
    // Get display text based on fields
    String primaryText = '';
    String secondaryText = '';

    if (fields.length >= 2) {
      primaryText = member[fields[0]] ?? '-';
      secondaryText = member[fields[1]] ?? '-';
    } else if (fields.length == 1) {
      primaryText = member[fields[0]] ?? '-';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: TColorsConst.blue50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              PhosphorIcons.userCircle(PhosphorIconsStyle.bold),
              color: TColorsConst.blue500,
              size: 24.sp,
            ),
          ),
          TSpaces.h16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (primaryText.isNotEmpty)
                  Text(
                    primaryText,
                    style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                      color: TColorsConst.neutral800,
                    ),
                  ),
                if (secondaryText.isNotEmpty) ...[
                  TSpaces.v4(),
                  Text(
                    secondaryText,
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.neutral600,
                    ),
                  ),
                ],
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
                    organizationType,
                    fields,
                    title,
                    item: member,
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
                  () =>
                      _showDeleteBottomSheet(context, organizationType, index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditBottomSheet(
    BuildContext context,
    String organizationType,
    List<String> fields,
    String title, {
    Map<String, dynamic>? item,
    int? index,
  }) {
    final isEdit = item != null;

    // Create controllers for each field
    final controllers = <String, TextEditingController>{};
    for (final field in fields) {
      controllers[field] = TextEditingController(text: item?[field] ?? '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
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
                        isEdit ? 'Edit Anggota' : 'Tambah Anggota',
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
                    children: fields.map((field) {
                      final isLast = field == fields.last;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFieldLabel(field),
                            style: TGoogleTextStyleConst.inter14SemiBold
                                .copyWith(color: TColorsConst.neutral800),
                          ),
                          TSpaces.v8(),
                          TextField(
                            controller: controllers[field],
                            decoration: InputDecoration(
                              hintText: _getFieldHint(field),
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
                                _getFieldIcon(field),
                                color: TColorsConst.neutral500,
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          if (!isLast) TSpaces.v20(),
                        ],
                      );
                    }).toList(),
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
                          // Build data object
                          final data = <String, dynamic>{};
                          for (final field in fields) {
                            data[field] = controllers[field]!.text;
                          }

                          if (isEdit && index != null) {
                            controller.updateOrganizationMember(
                              organizationType,
                              index,
                              data,
                              context,
                            );
                          } else {
                            controller.addOrganizationMember(
                              organizationType,
                              data,
                              context,
                            );
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

  void _showDeleteBottomSheet(
    BuildContext context,
    String organizationType,
    int index,
  ) {
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
                      controller.deleteOrganizationMember(
                        organizationType,
                        index,
                        context,
                      );
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

  String _getFieldLabel(String field) {
    switch (field) {
      case 'jabatan':
        return 'Jabatan';
      case 'nama':
        return 'Nama';
      case 'dusun':
        return 'Dusun';
      default:
        return field;
    }
  }

  String _getFieldHint(String field) {
    switch (field) {
      case 'jabatan':
        return 'Contoh: Ketua, Sekretaris, Anggota';
      case 'nama':
        return 'Nama lengkap';
      case 'dusun':
        return 'Contoh: Dusun Krajan';
      default:
        return '';
    }
  }

  IconData _getFieldIcon(String field) {
    switch (field) {
      case 'jabatan':
        return PhosphorIcons.briefcase(PhosphorIconsStyle.regular);
      case 'nama':
        return PhosphorIcons.user(PhosphorIconsStyle.regular);
      case 'dusun':
        return PhosphorIcons.mapPin(PhosphorIconsStyle.regular);
      default:
        return PhosphorIcons.textAa(PhosphorIconsStyle.regular);
    }
  }
}
