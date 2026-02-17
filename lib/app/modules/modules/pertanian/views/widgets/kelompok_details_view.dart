import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class KelompokDetailView extends GetView<PertanianController> {
  const KelompokDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final kelompok = Get.arguments as Map<String, dynamic>;
    final kelompokId = kelompok['id'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAnggota(kelompokId);
    });

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
          kelompok['nama_kelompok'] ?? 'Detail Kelompok',
          style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAnggota(kelompokId),
        color: const Color(0xFF60A5FA),
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildKelompokInfoCard(kelompok),
            TSpaces.v16(),
            _buildAnggotaSection(kelompokId, context),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAdmin.value) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showAnggotaForm(context, kelompokId),
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: Text(
            'Tambah Anggota',
            style: TGoogleTextStyleConst.inter14Medium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF60A5FA),
          elevation: 2,
        );
      }),
    );
  }

  Widget _buildKelompokInfoCard(Map<String, dynamic> kelompok) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
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
                        style: TGoogleTextStyleConst.inter14Bold.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      TSpaces.v4(),
                      Text(
                        'Kode: ${kelompok['kode_kelompok'] ?? '-'}',
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  'Ketua',
                  kelompok['ketua_kelompok'] ?? '-',
                ),
                Divider(height: 16.h, color: const Color(0xFFE5E7EB)),
                _buildInfoRow(
                  Icons.school_outlined,
                  'Penyuluh',
                  kelompok['penyuluh_pendamping'] ?? '-',
                ),
                Divider(height: 16.h, color: const Color(0xFFE5E7EB)),
                _buildInfoRow(
                  Icons.category_outlined,
                  'Subsektor',
                  kelompok['subsektor'] ?? '-',
                ),
                Divider(height: 16.h, color: const Color(0xFFE5E7EB)),
                _buildInfoRow(
                  Icons.eco_outlined,
                  'Komoditas',
                  kelompok['komoditas'] ?? '-',
                ),
                if (kelompok['kios_pupuk'] != null &&
                    kelompok['kios_pupuk'].toString().isNotEmpty) ...[
                  Divider(height: 16.h, color: const Color(0xFFE5E7EB)),
                  _buildInfoRow(
                    Icons.store_outlined,
                    'Kios Pupuk',
                    kelompok['kios_pupuk'],
                  ),
                ],
                Divider(height: 16.h, color: const Color(0xFFE5E7EB)),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Tahun RDKK',
                  kelompok['tahun_rdkk'] ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF9CA3AF)),
        TSpaces.h12(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              TSpaces.v4(),
              Text(
                value,
                style: TGoogleTextStyleConst.inter12Medium.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnggotaSection(String kelompokId, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Anggota',
              style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                color: const Color(0xFF1F2937),
              ),
            ),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${controller.anggotaList.length} Anggota',
                  style: TGoogleTextStyleConst.inter12Medium.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
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

          if (controller.anggotaList.isEmpty) {
            return _buildEmptyAnggota();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.anggotaList.length,
            itemBuilder: (context, index) {
              final anggota = controller.anggotaList[index];
              return _buildAnggotaCard(kelompokId, anggota, index + 1, context);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAnggotaCard(
    String kelompokId,
    Map<String, dynamic> anggota,
    int number,
    BuildContext context,
  ) {
    final pupuk = anggota['kebutuhan_pupuk'];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                  color: const Color(0xFF60A5FA),
                ),
              ),
            ),
          ),
          title: Text(
            anggota['nama'] ?? '-',
            style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TSpaces.v8(),
              Text(
                'NIK: ${anggota['nik'] ?? '-'}',
                style: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                'Luas: ${anggota['rencana_tanam_ha']?.toString() ?? '0'} Ha',
                style: TGoogleTextStyleConst.inter12Regular.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          trailing: Obx(() {
            if (!controller.isAdmin.value) {
              return Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF9CA3AF),
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18.sp),
                  onPressed: () =>
                      _showAnggotaForm(context, kelompokId, anggota: anggota),
                  color: const Color(0xFF60A5FA),
                  padding: EdgeInsets.all(4.w),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18.sp),
                  onPressed: () =>
                      _confirmDeleteAnggota(context, kelompokId, anggota),
                  color: const Color(0xFFEF4444),
                  padding: EdgeInsets.all(4.w),
                  constraints: const BoxConstraints(),
                ),
              ],
            );
          }),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
              ),
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kebutuhan Pupuk Bersubsidi (Kg)',
                    style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  TSpaces.v10(),
                  if (pupuk != null) ...[
                    _buildPupukRow('UREA', pupuk['urea']),
                    _buildPupukRow('NPK', pupuk['npk']),
                    _buildPupukRow('NPK Formula', pupuk['npk_formula']),
                    _buildPupukRow('Organik', pupuk['organik']),
                    _buildPupukRow('ZA', pupuk['za']),
                  ] else
                    Text(
                      'Belum ada data pupuk',
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPupukRow(String jenis, dynamic data) {
    if (data == null) return const SizedBox.shrink();

    final mt1 = data['MT1'] ?? 0;
    final mt2 = data['MT2'] ?? 0;
    final mt3 = data['MT3'] ?? 0;
    final total = mt1 + mt2 + mt3;

    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jenis,
              style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                color: const Color(0xFF1F2937),
              ),
            ),
            TSpaces.v8(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MT1: $mt1',
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'MT2: $mt2',
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'MT3: $mt3',
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Total: $total',
                    style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                      color: Colors.white,
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

  Widget _buildEmptyAnggota() {
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
              Icons.people_outline,
              size: 48.sp,
              color: const Color(0xFFD1D5DB),
            ),
            TSpaces.v12(),
            Text(
              'Belum ada anggota',
              style: TGoogleTextStyleConst.inter12Medium.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            TSpaces.v8(),
            Text(
              'Tambahkan anggota kelompok tani',
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnggotaForm(
    BuildContext context,
    String kelompokId, {
    Map<String, dynamic>? anggota,
  }) {
    if (anggota != null) {
      controller.populateAnggotaForm(anggota);
    } else {
      controller.clearAnggotaForm();
    }

    Get.toNamed(
      Routes.ANGGOTA_FORM,
      arguments: {'kelompokId': kelompokId, 'anggota': anggota},
    );
  }

  void _confirmDeleteAnggota(
    BuildContext context,
    String kelompokId,
    Map<String, dynamic> anggota,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: Colors.white,
        title: Text(
          'Konfirmasi Hapus',
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus anggota "${anggota['nama']}"?',
          style: TGoogleTextStyleConst.inter14Regular.copyWith(
            color: const Color(0xFF6B7280),
          ),
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
              controller.deleteAnggota(kelompokId, anggota['id']);
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
