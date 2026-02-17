import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class PertanianView extends GetView<PertanianController> {
  const PertanianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: TColorsConst.white,

        elevation: 0,

        scrolledUnderElevation: 0,

        surfaceTintColor: Colors.transparent,

        shadowColor: Colors.transparent,

        systemOverlayStyle: SystemUiOverlayStyle.dark,

        centerTitle: true,

        title: Text(
          'kelompok Tani',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: const Color(0xFF60A5FA),
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Header Info Card
            _buildHeaderCard(),
            TSpaces.v16(),

            // Statistics Section
            _buildStatistikSection(),
            TSpaces.v20(),

            // Filter Tabs
            _buildFilterTabs(),
            TSpaces.v16(),

            // Search Bar
            _buildSearchBar(),
            TSpaces.v16(),

            // Kelompok List
            _buildKelompokSection(context),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAdmin.value) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showKelompokForm(context),
          backgroundColor: const Color(0xFF60A5FA),
          elevation: 2,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Tambah Kelompok',
            style: TGoogleTextStyleConst.inter14Medium.copyWith(
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.agriculture_rounded,
              color: const Color(0xFF60A5FA),
              size: 24.sp,
            ),
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Pertanian',
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: const Color(0xFF1F2937),
                  ),
                ),
                TSpaces.v4(),
                Obx(
                  () => Text(
                    'Musim Tanam: ${controller.currentMusimTanam.value}',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['Semua', 'Perkebunan', 'Tanaman Pangan', 'Hortikultura'];

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => TSpaces.h8(),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(
            () => _buildFilterChip(
              filter,
              controller.selectedFilter.value == filter,
              () => controller.setFilter(filter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF60A5FA)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TGoogleTextStyleConst.inter12Medium.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistikSection() {
    return Obx(() {
      final stats = controller.statistik;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Data',
            style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          TSpaces.v12(),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Kelompok',
                  '${stats['total_kelompok'] ?? 0}',
                  Icons.groups_rounded,
                ),
              ),
              TSpaces.h12(),
              Expanded(
                child: _buildStatCard(
                  'Total Petani',
                  '${stats['total_anggota'] ?? 0}',
                  Icons.people_rounded,
                ),
              ),
            ],
          ),
          TSpaces.v12(),
          _buildStatCard(
            'Total Luas Tanam',
            '${stats['total_luas_tanam']?.toStringAsFixed(2) ?? '0.00'} Ha',
            Icons.landscape_rounded,
          ),
          TSpaces.v12(),
          _buildPupukCard(stats['total_kebutuhan_pupuk']),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF60A5FA), size: 20.sp),
          TSpaces.v10(),
          Text(
            title,
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          TSpaces.v4(),
          Text(
            value,
            style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPupukCard(dynamic pupuk) {
    if (pupuk == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grass_rounded,
                color: const Color(0xFF60A5FA),
                size: 18.sp,
              ),
              TSpaces.h8(),
              Text(
                'Total Kebutuhan Pupuk (Kg)',
                style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          TSpaces.v12(),
          _buildPupukRow('UREA', pupuk['urea'] ?? 0),
          TSpaces.v8(),
          _buildPupukRow('NPK', pupuk['npk'] ?? 0),
          TSpaces.v8(),
          _buildPupukRow('NPK Formula', pupuk['npk_formula'] ?? 0),
          TSpaces.v8(),
          _buildPupukRow('Organik', pupuk['organik'] ?? 0),
          TSpaces.v8(),
          _buildPupukRow('ZA', pupuk['za'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildPupukRow(String jenis, int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            jenis,
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: const Color(0xFF4B5563),
            ),
          ),
          Text(
            '$total Kg',
            style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: const Color(0xFF9CA3AF), size: 20.sp),
          TSpaces.h8(),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari kelompok tani...',
                hintStyle: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              style: TGoogleTextStyleConst.inter12Regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelompokSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Kelompok Tani',
              style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                color: const Color(0xFF1F2937),
              ),
            ),
            Obx(() {
              final total = controller.filteredKelompokList.length;
              if (total == 0) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '$total',
                  style: TGoogleTextStyleConst.inter12Medium.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              );
            }),
          ],
        ),
        TSpaces.v12(),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: const CircularProgressIndicator(
                  color: Color(0xFF60A5FA),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (controller.filteredKelompokList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredKelompokList.length,
            itemBuilder: (context, index) {
              final kelompok = controller.filteredKelompokList[index];
              return _buildKelompokCard(kelompok, context);
            },
          );
        }),
      ],
    );
  }

  Widget _buildKelompokCard(
    Map<String, dynamic> kelompok,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: () => _showKelompokDetail(context, kelompok),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.agriculture_rounded,
                      color: const Color(0xFF60A5FA),
                      size: 20.sp,
                    ),
                  ),
                  TSpaces.h12(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kelompok['nama_kelompok'] ?? '-',
                          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        TSpaces.v4(),
                        Text(
                          'Kode: ${kelompok['kode_kelompok'] ?? '-'}',
                          style: TGoogleTextStyleConst.inter12Regular.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (!controller.isAdmin.value) {
                      return Icon(
                        Icons.chevron_right,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      );
                    }
                    return PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: const Color(0xFF6B7280),
                        size: 20.sp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      color: Colors.white,
                      elevation: 4,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18.sp,
                                color: const Color(0xFF60A5FA),
                              ),
                              TSpaces.h12(),
                              Text(
                                'Edit',
                                style: TGoogleTextStyleConst.inter14Regular,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18.sp,
                                color: const Color(0xFFEF4444),
                              ),
                              TSpaces.h12(),
                              Text(
                                'Hapus',
                                style: TGoogleTextStyleConst.inter14Regular
                                    .copyWith(color: const Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showKelompokForm(context, kelompok: kelompok);
                        } else if (value == 'delete') {
                          _confirmDelete(context, kelompok);
                        }
                      },
                    );
                  }),
                ],
              ),
              Divider(height: 20.h, color: const Color(0xFFE5E7EB)),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person_outline,
                      'Ketua',
                      kelompok['ketua_kelompok'] ?? '-',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.eco_outlined,
                      'Komoditas',
                      kelompok['komoditas'] ?? '-',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF9CA3AF)),
        TSpaces.h8(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TGoogleTextStyleConst.inter10Regular.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: TGoogleTextStyleConst.inter12Medium.copyWith(
                  color: const Color(0xFF4B5563),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.agriculture_rounded,
              size: 48.sp,
              color: const Color(0xFFD1D5DB),
            ),
            TSpaces.v12(),
            Text(
              'Belum ada kelompok tani',
              style: TGoogleTextStyleConst.inter14Medium.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            TSpaces.v8(),
            Text(
              'Tambahkan kelompok tani baru',
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKelompokForm(
    BuildContext context, {
    Map<String, dynamic>? kelompok,
  }) {
    if (kelompok != null) {
      controller.populateKelompokForm(kelompok);
    } else {
      controller.clearKelompokForm();
    }
    Get.toNamed(Routes.KELOMPOK_FORM, arguments: kelompok ?? {});
  }

  void _showKelompokDetail(
    BuildContext context,
    Map<String, dynamic> kelompok,
  ) {
    Get.toNamed(Routes.KELOMPOK_DETAIL, arguments: kelompok);
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> kelompok) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: Colors.white,
        title: Text(
          'Konfirmasi Hapus',
          style: TGoogleTextStyleConst.inter14SemiBold,
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelompok "${kelompok['nama_kelompok']}"?\n\nSemua data anggota akan ikut terhapus.',
          style: TGoogleTextStyleConst.inter14Regular,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TGoogleTextStyleConst.inter14Medium.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteKelompokTani(kelompok['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text('Hapus', style: TGoogleTextStyleConst.inter14Medium),
          ),
        ],
      ),
    );
  }
}
