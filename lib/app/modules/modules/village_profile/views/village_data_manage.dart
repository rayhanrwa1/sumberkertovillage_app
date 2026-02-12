import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import '../controllers/village_profile_controller.dart';

class VillageDataManageView extends GetView<VillageProfileController> {
  const VillageDataManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.neutral50,
      body: Obx(() {
        if (!controller.isAdmin.value) {
          return _buildAccessDenied();
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(children: [_buildHeader(), _buildDataCategories()]),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 72.h,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: TColorsConst.neutral700),
        onPressed: Get.back,
      ),
      title: Text(
        'Kelola Data Struktural',
        style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
          color: TColorsConst.neutral900,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(height: 1, color: TColorsConst.neutral200),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: TColorsConst.neutral300.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: TColorsConst.red50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                size: 56.sp,
                color: TColorsConst.red500,
              ),
            ),
            TSpaces.v24(),
            Text(
              'Akses Terbatas',
              style: TGoogleTextStyleConst.inter24SemiBold.copyWith(
                color: TColorsConst.neutral900,
              ),
            ),
            TSpaces.v12(),
            Text(
              'Halaman pengelolaan data hanya dapat diakses oleh administrator desa',
              textAlign: TextAlign.center,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TColorsConst.neutral200),
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
              PhosphorIcons.database(PhosphorIconsStyle.regular),
              color: TColorsConst.blue500,
              size: 24.sp,
            ),
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Data',
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: TColorsConst.neutral900,
                  ),
                ),
                TSpaces.v4(),
                Text(
                  'Kelola kepemimpinan, struktur organisasi, dan sejarah desa',
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: TColorsConst.neutral600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCategories() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(
            title: 'Kepemimpinan Desa',
            items: [
              _DataItem(
                title: 'Sejarah Kepala Desa',
                subtitle: 'Daftar kepala desa dari masa ke masa',
                icon: PhosphorIcons.clockCounterClockwise(
                  PhosphorIconsStyle.duotone,
                ),
                color: TColorsConst.blue500,
                count: controller
                    .getDataObjectList('kepala_desa_history')
                    .length,
                route: Routes.MANAGE_KEPALA_DESA_HISTORY,
              ),
            ],
          ),
          TSpaces.v24(),
          _buildCategorySection(
            title: 'Struktur Pemerintahan',
            items: [
              _DataItem(
                title: 'Struktur Pemerintahan',
                subtitle: 'Perangkat desa dan jabatan struktural',
                icon: PhosphorIcons.treeStructure(PhosphorIconsStyle.duotone),
                color: TColorsConst.purple500,
                count: controller
                    .getDataObjectList('struktur_pemerintahan')
                    .length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'struktur_pemerintahan',
                  'title': 'Struktur Pemerintahan',
                  'fields': ['jabatan', 'nama'],
                },
              ),
              _DataItem(
                title: 'Kepala Dusun (Kamituwo)',
                subtitle: 'Daftar kepala dusun yang bertugas',
                icon: PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
                color: TColorsConst.blue400,
                count: controller.getDataObjectList('kamituwo').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'kamituwo',
                  'title': 'Kepala Dusun (Kamituwo)',
                  'fields': ['dusun', 'nama'],
                },
              ),
              _DataItem(
                title: 'Perangkat Lainnya',
                subtitle: 'Perangkat pendukung pemerintahan desa',
                icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
                color: TColorsConst.teal600,
                count: controller.getDataObjectList('perangkat_lainnya').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'perangkat_lainnya',
                  'title': 'Perangkat Lainnya',
                  'fields': ['jabatan', 'nama'],
                },
              ),
            ],
          ),
          TSpaces.v24(),
          _buildCategorySection(
            title: 'Lembaga Kemasyarakatan',
            items: [
              _DataItem(
                title: 'BPD',
                subtitle: 'Badan Permusyawaratan Desa',
                icon: PhosphorIcons.usersFour(PhosphorIconsStyle.duotone),
                color: TColorsConst.teal500,
                count: controller.getDataObjectList('bpd').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'bpd',
                  'title': 'BPD',
                  'fields': ['jabatan', 'nama'],
                },
              ),
              _DataItem(
                title: 'LPMD',
                subtitle: 'Lembaga Pemberdayaan Masyarakat Desa',
                icon: PhosphorIcons.handshake(PhosphorIconsStyle.duotone),
                color: TColorsConst.green500,
                count: controller.getDataObjectList('lpmd').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'lpmd',
                  'title': 'LPMD',
                  'fields': ['jabatan', 'nama'],
                },
              ),
              _DataItem(
                title: 'Karang Taruna',
                subtitle: 'Organisasi kepemudaan desa',
                icon: PhosphorIcons.usersThree(PhosphorIconsStyle.duotone),
                color: TColorsConst.warningMain,
                count: controller.getDataObjectList('karang_taruna').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'karang_taruna',
                  'title': 'Karang Taruna',
                  'fields': ['jabatan', 'nama'],
                },
              ),
              _DataItem(
                title: 'PKK',
                subtitle: 'Pemberdayaan Kesejahteraan Keluarga',
                icon: PhosphorIcons.userList(PhosphorIconsStyle.duotone),
                color: TColorsConst.red300,
                count: controller.getDataObjectList('pkk').length,
                route: Routes.MANAGE_ORGANIZATION,
                arguments: {
                  'type': 'pkk',
                  'title': 'PKK',
                  'fields': ['jabatan', 'nama'],
                },
              ),
            ],
          ),
          TSpaces.v24(),
          _buildCategorySection(
            title: 'Sejarah & Dokumentasi',
            items: [
              _DataItem(
                title: 'Timeline Sejarah',
                subtitle: 'Catatan peristiwa penting desa',
                icon: PhosphorIcons.timer(PhosphorIconsStyle.duotone),
                color: TColorsConst.amber500,
                count: controller.getDataObjectList('timeline_sejarah').length,
                route: Routes.MANAGE_TIMELINE_SEJARAH,
              ),
            ],
          ),
          TSpaces.v32(),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required List<_DataItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title,
            style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
              color: TColorsConst.neutral900,
            ),
          ),
        ),
        ...items.map((item) => _buildDataCard(item)),
      ],
    );
  }

  Widget _buildDataCard(_DataItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.arguments != null) {
              Get.toNamed(item.route, arguments: item.arguments);
            } else {
              Get.toNamed(item.route);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: TColorsConst.neutral200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: TColorsConst.neutral300.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(item.icon, color: item.color, size: 28.sp),
                ),
                TSpaces.h16(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral900,
                        ),
                      ),
                      TSpaces.v4(),
                      Text(
                        item.subtitle,
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                TSpaces.h12(),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${item.count}',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: item.color,
                        ),
                      ),
                    ),
                    TSpaces.v8(),
                    Icon(
                      PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                      color: TColorsConst.neutral400,
                      size: 20.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int count;
  final String route;
  final Map<String, dynamic>? arguments;

  _DataItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.count,
    required this.route,
    this.arguments,
  });
}
