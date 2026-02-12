import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/village_profile_controller.dart';

class VillageProfileEditView extends GetView<VillageProfileController> {
  const VillageProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TColorsConst.neutral50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: TColorsConst.neutral800),
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profil Desa',
                style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
                  color: TColorsConst.neutral800,
                ),
              ),
              Obx(() {
                if (controller.dataExists.value) {
                  return Text(
                    'Mode: Edit Data',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.blue600,
                    ),
                  );
                } else {
                  return Text(
                    'Mode: Buat Data Baru',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.green600,
                    ),
                  );
                }
              }),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: TColorsConst.neutral200, width: 1),
                ),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: TColorsConst.blue600,
                unselectedLabelColor: TColorsConst.neutral500,
                indicatorColor: TColorsConst.blue600,
                indicatorWeight: 3,
                labelStyle: TGoogleTextStyleConst.inter14SemiBold,
                unselectedLabelStyle: TGoogleTextStyleConst.inter14Regular,
                tabs: const [
                  Tab(text: 'Identitas Desa'),
                  Tab(text: 'Wilayah & Demografi'),
                  Tab(text: 'Penggunaan Lahan'),
                  Tab(text: 'Sejarah'),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (!controller.isAdmin.value) {
            return _buildAccessDenied();
          }

          return Form(
            key: controller.formKey,
            child: TabBarView(
              children: [
                _buildIdentitasTab(context),
                _buildWilayahDemografiTab(context),
                _buildLahanTab(context),
                _buildSejarahTab(context),
              ],
            ),
          );
        }),
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
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: TColorsConst.neutral300.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: TColorsConst.red50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                size: 48.sp,
                color: TColorsConst.red500,
              ),
            ),
            TSpaces.v20(),
            Text(
              'Akses Terbatas',
              style: TGoogleTextStyleConst.inter20SemiBold.copyWith(
                color: TColorsConst.neutral900,
              ),
            ),
            TSpaces.v8(),
            Text(
              'Halaman ini hanya dapat diakses oleh administrator',
              textAlign: TextAlign.center,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: IDENTITAS DESA =================
  Widget _buildIdentitasTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildInfoBanner(),
        TSpaces.v24(),

        _buildFormSection(
          title: 'Informasi Dasar',
          subtitle: 'Data identitas dan lokasi desa',
          icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.namaDesaController,
              label: 'Nama Desa',
              hint: 'Masukkan nama desa',
              icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
              isRequired: true,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.kecamatanController,
              label: 'Kecamatan',
              hint: 'Masukkan kecamatan',
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
              isRequired: true,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.kabupatenController,
              label: 'Kabupaten',
              hint: 'Masukkan kabupaten',
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
              isRequired: true,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.provinsiController,
              label: 'Provinsi',
              hint: 'Masukkan provinsi',
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
              isRequired: true,
            ),
            TSpaces.v16(),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.ketinggianController,
                    label: 'Ketinggian',
                    hint: '470 m dpl',
                    icon: PhosphorIcons.mountains(PhosphorIconsStyle.regular),
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.luasWilayahController,
                    label: 'Luas Wilayah',
                    hint: '1.092,5 Ha',
                    icon: PhosphorIcons.resize(PhosphorIconsStyle.regular),
                  ),
                ),
              ],
            ),
          ],
        ),

        TSpaces.v24(),

        _buildFormSection(
          title: 'Kepemimpinan',
          subtitle: 'Informasi kepala desa aktif',
          icon: PhosphorIcons.userCircleGear(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.kepalaDesaController,
              label: 'Kepala Desa',
              hint: 'Nama lengkap kepala desa',
              icon: PhosphorIcons.userCircle(PhosphorIconsStyle.regular),
              isRequired: true,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.tahunMenjabatController,
              label: 'Tahun Menjabat',
              hint: 'Contoh: 2014',
              icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
              keyboardType: TextInputType.number,
            ),
          ],
        ),

        TSpaces.v24(),

        _buildFormSection(
          title: 'Visi & Misi',
          subtitle: 'Visi dan misi pembangunan desa',
          icon: PhosphorIcons.target(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.visiController,
              label: 'Visi',
              hint: 'Tuliskan visi desa',
              icon: PhosphorIcons.eye(PhosphorIconsStyle.regular),
              maxLines: 3,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.misiController,
              label: 'Misi',
              hint:
                  'Tuliskan misi desa (pisahkan dengan enter)\nContoh:\n• Meningkatkan kesejahteraan masyarakat\n• Mengembangkan infrastruktur desa',
              icon: PhosphorIcons.listBullets(PhosphorIconsStyle.regular),
              maxLines: 8,
            ),
          ],
        ),

        TSpaces.v24(),

        _buildFormSection(
          title: 'Aksesibilitas',
          subtitle: 'Jarak dan waktu tempuh ke pusat pemerintahan',
          icon: PhosphorIcons.roadHorizon(PhosphorIconsStyle.duotone),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.jarakKecamatanController,
                    label: 'Jarak ke Kecamatan',
                    hint: '6 km',
                    icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.regular),
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.waktuKeKecamatanController,
                    label: 'Waktu Tempuh',
                    hint: '60 menit',
                    icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
                  ),
                ),
              ],
            ),
            TSpaces.v16(),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.jarakKabupatenController,
                    label: 'Jarak ke Kabupaten',
                    hint: '54 km',
                    icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.regular),
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.waktuKeKabupatenController,
                    label: 'Waktu Tempuh',
                    hint: '6 jam',
                    icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
                  ),
                ),
              ],
            ),
          ],
        ),

        TSpaces.v32(),
        _buildSaveButton(context),
        TSpaces.v20(),
      ],
    );
  }

  // ================= TAB 2: WILAYAH & DEMOGRAFI =================
  Widget _buildWilayahDemografiTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildFormSection(
          title: 'Pembagian Wilayah Administratif',
          subtitle: 'Struktur wilayah administrasi desa',
          icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.duotone),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.jumlahDusunController,
                    label: 'Jumlah Dusun',
                    hint: '0',
                    icon: PhosphorIcons.buildings(PhosphorIconsStyle.regular),
                    keyboardType: TextInputType.number,
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.jumlahRwController,
                    label: 'Jumlah RW',
                    hint: '0',
                    icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                    keyboardType: TextInputType.number,
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.jumlahRtController,
                    label: 'Jumlah RT',
                    hint: '0',
                    icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.namaDusunController,
              label: 'Nama Dusun',
              hint: 'Pisahkan dengan koma. Contoh: Krajan, Tengah, Timur',
              icon: PhosphorIcons.list(PhosphorIconsStyle.regular),
              maxLines: 2,
            ),
          ],
        ),

        TSpaces.v24(),

        _buildFormSection(
          title: 'Batas Wilayah',
          subtitle: 'Batas geografis desa dengan wilayah sekitar',
          icon: PhosphorIcons.compass(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.batasUtaraController,
              label: 'Sebelah Utara',
              hint: 'Nama desa/wilayah',
              icon: PhosphorIcons.arrowUp(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.batasSelatanController,
              label: 'Sebelah Selatan',
              hint: 'Nama desa/wilayah',
              icon: PhosphorIcons.arrowDown(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.batasBaratController,
              label: 'Sebelah Barat',
              hint: 'Nama desa/wilayah',
              icon: PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.batasTimurController,
              label: 'Sebelah Timur',
              hint: 'Nama desa/wilayah',
              icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.regular),
            ),
          ],
        ),

        TSpaces.v24(),

        _buildFormSection(
          title: 'Data Kependudukan',
          subtitle: 'Statistik penduduk dan kepala keluarga',
          icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.totalPendudukController,
              label: 'Total Penduduk',
              hint: '0 jiwa',
              icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
              keyboardType: TextInputType.number,
            ),
            TSpaces.v16(),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.lakiLakiController,
                    label: 'Laki-laki',
                    hint: '0 jiwa',
                    icon: PhosphorIcons.genderMale(PhosphorIconsStyle.regular),
                    keyboardType: TextInputType.number,
                  ),
                ),
                TSpaces.h12(),
                Expanded(
                  child: _buildTextField(
                    controller: controller.perempuanController,
                    label: 'Perempuan',
                    hint: '0 jiwa',
                    icon: PhosphorIcons.genderFemale(
                      PhosphorIconsStyle.regular,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.totalKkController,
              label: 'Total Kepala Keluarga (KK)',
              hint: '0 KK',
              icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
              keyboardType: TextInputType.number,
            ),
          ],
        ),

        TSpaces.v32(),
        _buildSaveButton(context),
        TSpaces.v20(),
      ],
    );
  }

  // ================= TAB 3: PENGGUNAAN LAHAN =================
  Widget _buildLahanTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildFormSection(
          title: 'Pemanfaatan Lahan Desa',
          subtitle: 'Rincian penggunaan lahan berdasarkan fungsi',
          icon: PhosphorIcons.tree(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.lahanPemukimanController,
              label: 'Lahan Pemukiman',
              hint: 'Contoh: 99,80 Ha',
              icon: PhosphorIcons.buildings(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanPertanianController,
              label: 'Lahan Pertanian',
              hint: 'Contoh: 12,00 Ha',
              icon: PhosphorIcons.plant(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanPerkebunanController,
              label: 'Lahan Perkebunan',
              hint: 'Contoh: 781,10 Ha',
              icon: PhosphorIcons.tree(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanPerkantoran,
              label: 'Lahan Perkantoran',
              hint: 'Contoh: 1,32 Ha',
              icon: PhosphorIcons.building(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanSekolahController,
              label: 'Lahan Pendidikan',
              hint: 'Contoh: 4,16 Ha',
              icon: PhosphorIcons.graduationCap(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanOlahragaController,
              label: 'Lahan Olahraga',
              hint: 'Contoh: 0,22 Ha',
              icon: PhosphorIcons.football(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanPemakamanController,
              label: 'Lahan Pemakaman',
              hint: 'Contoh: 4,00 Ha',
              icon: PhosphorIcons.cross(PhosphorIconsStyle.regular),
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.lahanJalanController,
              label: 'Lahan Jalan Desa',
              hint: 'Contoh: 189,90 Ha',
              icon: PhosphorIcons.roadHorizon(PhosphorIconsStyle.regular),
            ),
          ],
        ),

        TSpaces.v32(),
        _buildSaveButton(context),
        TSpaces.v20(),
      ],
    );
  }

  // ================= TAB 4: SEJARAH =================
  Widget _buildSejarahTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildFormSection(
          title: 'Sejarah Desa',
          subtitle: 'Catatan historis dan asal usul desa',
          icon: PhosphorIcons.book(PhosphorIconsStyle.duotone),
          children: [
            _buildTextField(
              controller: controller.sejarahSingkatController,
              label: 'Sejarah Singkat',
              hint:
                  'Tuliskan ringkasan sejarah pembentukan dan perkembangan desa...',
              icon: PhosphorIcons.article(PhosphorIconsStyle.regular),
              maxLines: 6,
            ),
            TSpaces.v16(),
            _buildTextField(
              controller: controller.asalUsulNamaController,
              label: 'Asal Usul Nama Desa',
              hint: 'Ceritakan latar belakang penamaan desa...',
              icon: PhosphorIcons.textAa(PhosphorIconsStyle.regular),
              maxLines: 6,
            ),
          ],
        ),

        TSpaces.v32(),
        _buildSaveButton(context),
        TSpaces.v20(),
      ],
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildInfoBanner() {
    return Obx(() {
      final isNewData = !controller.dataExists.value;
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isNewData
                ? [TColorsConst.green100, TColorsConst.green100]
                : [TColorsConst.blue50, TColorsConst.blue100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isNewData ? TColorsConst.green200 : TColorsConst.blue200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isNewData
                    ? TColorsConst.green500.withOpacity(0.1)
                    : TColorsConst.blue500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isNewData
                    ? PhosphorIcons.plusCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.info(PhosphorIconsStyle.fill),
                color: isNewData ? TColorsConst.green600 : TColorsConst.blue600,
                size: 24.sp,
              ),
            ),
            TSpaces.h16(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNewData ? 'Membuat Data Baru' : 'Mengedit Data',
                    style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                      color: isNewData
                          ? TColorsConst.green800
                          : TColorsConst.blue800,
                    ),
                  ),
                  TSpaces.v4(),
                  Text(
                    isNewData
                        ? 'Data profil desa akan dibuat untuk pertama kalinya. Isi semua informasi dengan lengkap dan akurat.'
                        : 'Anda sedang mengedit data profil desa. Perubahan akan langsung tersimpan ke database.',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: isNewData
                          ? TColorsConst.green700
                          : TColorsConst.blue700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFormSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TColorsConst.neutral200),
        boxShadow: [
          BoxShadow(
            color: TColorsConst.neutral300.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: TColorsConst.blue50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: TColorsConst.blue600, size: 24.sp),
                ),
                TSpaces.h16(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
                          color: TColorsConst.neutral900,
                        ),
                      ),
                      TSpaces.v4(),
                      Text(
                        subtitle,
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: TColorsConst.neutral200),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: TGoogleTextStyleConst.inter14Medium.copyWith(
                  color: TColorsConst.neutral800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRequired) ...[
              TSpaces.h4(),
              Text(
                '*',
                style: TGoogleTextStyleConst.inter14Medium.copyWith(
                  color: TColorsConst.red500,
                ),
              ),
            ],
          ],
        ),
        TSpaces.v8(),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TGoogleTextStyleConst.inter14Regular.copyWith(
            color: TColorsConst.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: TColorsConst.neutral400,
            ),
            prefixIcon: Icon(icon, size: 20.sp, color: TColorsConst.neutral500),
            filled: true,
            fillColor: TColorsConst.neutral50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 16.h : 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: TColorsConst.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: TColorsConst.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: TColorsConst.blue500, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: TColorsConst.red500),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: TColorsConst.red500, width: 2),
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label harus diisi';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isNewData = !controller.dataExists.value;

      return Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [TColorsConst.blue500, TColorsConst.blue600],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: TColorsConst.blue500.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : () => controller.saveBasicInfo(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNewData
                          ? PhosphorIcons.check(PhosphorIconsStyle.bold)
                          : PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    TSpaces.h12(),
                    Text(
                      isNewData ? 'Buat Data Desa' : 'Simpan Perubahan',
                      style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
