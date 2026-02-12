import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import '../controllers/village_profile_controller.dart';

class VillageProfileView extends GetView<VillageProfileController> {
  const VillageProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: TColorsConst.neutral50,
        body: Obx(() {
          if (controller.isLoading.value && controller.villageData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // ================= APP BAR =================
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: TColorsConst.blue500,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    Obx(() {
                      if (controller.isAdmin.value) {
                        return Row(
                          children: [
                            // Edit Basic Info Button
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.pencilSimple(
                                  PhosphorIconsStyle.bold,
                                ),
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.toNamed(Routes.VILLAGE_PROFILE_EDIT);
                              },
                            ),
                            // Manage Data Button
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.database(PhosphorIconsStyle.bold),
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.toNamed(Routes.VILLAGE_DATA_MANAGE);
                              },
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    }),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Profil Desa',
                      style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image
                        Image.asset(TAssetsConst.bgMaps, fit: BoxFit.cover),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TColorsConst.blue600.withOpacity(0.7),
                                TColorsConst.blue500.withOpacity(0.85),
                              ],
                            ),
                          ),
                        ),
                        // Icon
                        SafeArea(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.buildings(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  color: Colors.white.withOpacity(0.3),
                                  size: 80,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= TAB BAR =================
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      isScrollable: true,
                      labelColor: TColorsConst.blue500,
                      unselectedLabelColor: TColorsConst.neutral500,
                      indicatorColor: TColorsConst.blue500,
                      indicatorWeight: 3,
                      labelStyle: TGoogleTextStyleConst.inter14SemiBold,
                      unselectedLabelStyle:
                          TGoogleTextStyleConst.inter14Regular,
                      tabs: [
                        Tab(
                          icon: Icon(
                            PhosphorIcons.identificationCard(
                              PhosphorIconsStyle.regular,
                            ),
                            size: 20,
                          ),
                          text: 'Identitas',
                        ),
                        Tab(
                          icon: Icon(
                            PhosphorIcons.users(PhosphorIconsStyle.regular),
                            size: 20,
                          ),
                          text: 'Kepemimpinan',
                        ),
                        Tab(
                          icon: Icon(
                            PhosphorIcons.mapTrifold(
                              PhosphorIconsStyle.regular,
                            ),
                            size: 20,
                          ),
                          text: 'Wilayah',
                        ),
                        Tab(
                          icon: Icon(
                            PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
                            size: 20,
                          ),
                          text: 'Data',
                        ),
                        Tab(
                          icon: Icon(
                            PhosphorIcons.book(PhosphorIconsStyle.regular),
                            size: 20,
                          ),
                          text: 'Sejarah',
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: controller.refreshData,
              child: TabBarView(
                children: [
                  // ================= TAB 1: IDENTITAS =================
                  _buildIdentitasTab(),

                  // ================= TAB 2: KEPEMIMPINAN =================
                  _buildKepemimpinanTab(),

                  // ================= TAB 3: WILAYAH =================
                  _buildWilayahTab(),

                  // ================= TAB 4: DATA =================
                  _buildDataTab(),

                  // ================= TAB 5: SEJARAH =================
                  _buildSejarahTab(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ================= TAB 1: IDENTITAS =================
  Widget _buildIdentitasTab() {
    return Obx(() {
      final isEmpty = controller.getData('nama_desa').isEmpty;

      if (isEmpty && controller.isAdmin.value) {
        return _buildEmptyStateWithAction(
          'Data Identitas Belum Diisi',
          'Silakan isi data identitas desa melalui tombol edit di pojok kanan atas',
          PhosphorIcons.identificationCard(PhosphorIconsStyle.thin),
        );
      }

      return ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Identitas Desa
          _buildSectionCard(
            title: 'Identitas Desa',
            icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.bold),
            children: [
              _buildInfoRow('Nama Desa', controller.getData('nama_desa')),
              _buildInfoRow('Kecamatan', controller.getData('kecamatan')),
              _buildInfoRow('Kabupaten', controller.getData('kabupaten')),
              _buildInfoRow('Provinsi', controller.getData('provinsi')),
              _buildInfoRow('Ketinggian', controller.getData('ketinggian')),
              _buildInfoRow('Luas Wilayah', controller.getData('luas_wilayah')),
            ],
          ),

          TSpaces.v16(),

          // Visi & Misi
          _buildSectionCard(
            title: 'Visi & Misi',
            icon: PhosphorIcons.target(PhosphorIconsStyle.bold),
            children: [_buildVisiMisi()],
          ),

          TSpaces.v16(),

          // Jarak Tempuh
          _buildSectionCard(
            title: 'Jarak Tempuh',
            icon: PhosphorIcons.roadHorizon(PhosphorIconsStyle.bold),
            children: [
              _buildInfoRow(
                'Ke Kecamatan',
                '${controller.getData('jarak_kecamatan')} (${controller.getData('waktu_ke_kecamatan')})',
              ),
              _buildInfoRow(
                'Ke Kabupaten',
                '${controller.getData('jarak_kabupaten')} (${controller.getData('waktu_ke_kabupaten')})',
              ),
            ],
          ),
        ],
      );
    });
  }

  // ================= TAB 2: KEPEMIMPINAN =================
  Widget _buildKepemimpinanTab() {
    return Obx(() {
      final history = controller.getDataObjectList('kepala_desa_history');
      final struktur = controller.getDataObjectList('struktur_pemerintahan');
      final isEmpty = history.isEmpty && struktur.isEmpty;

      if (isEmpty && controller.isAdmin.value) {
        return _buildEmptyStateWithAction(
          'Data Kepemimpinan Belum Diisi',
          'Silakan kelola data kepemimpinan melalui menu Kelola Data',
          PhosphorIcons.users(PhosphorIconsStyle.thin),
        );
      }

      return ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Kepala Desa Aktif
          _buildSectionCard(
            title: 'Kepala Desa Aktif',
            icon: PhosphorIcons.userCircleGear(PhosphorIconsStyle.bold),
            children: [
              _buildInfoRow('Nama', controller.getData('kepala_desa')),
              _buildInfoRow(
                'Tahun Menjabat',
                controller.getData('tahun_menjabat'),
              ),
              _buildInfoRow('Periode', 'Sekarang'),
            ],
          ),

          TSpaces.v16(),

          // Sejarah Kepemimpinan
          if (history.isNotEmpty)
            _buildSectionCard(
              title: 'Sejarah Kepala Desa',
              icon: PhosphorIcons.clockCounterClockwise(
                PhosphorIconsStyle.bold,
              ),
              children: history
                  .map(
                    (item) => _buildKepalaDesaHistoryItem(
                      '${item['nomor']}.',
                      item['nama'] ?? '-',
                      item['periode'] ?? '-',
                      item['durasi'] ?? '-',
                      isActive: item['isActive'] ?? false,
                    ),
                  )
                  .toList(),
            ),

          if (history.isNotEmpty) TSpaces.v16(),

          // Struktur Pemerintahan
          if (struktur.isNotEmpty)
            _buildSectionCard(
              title: 'Struktur Pemerintahan Desa',
              icon: PhosphorIcons.treeStructure(PhosphorIconsStyle.bold),
              children: struktur
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),

          // Rest of organizations...
          _buildOrganizationSections(),
        ],
      );
    });
  }

  Widget _buildOrganizationSections() {
    return Obx(() {
      final kamituwo = controller.getDataObjectList('kamituwo');
      final perangkatLain = controller.getDataObjectList('perangkat_lainnya');
      final bpd = controller.getDataObjectList('bpd');
      final lpmd = controller.getDataObjectList('lpmd');
      final karangTaruna = controller.getDataObjectList('karang_taruna');
      final pkk = controller.getDataObjectList('pkk');

      return Column(
        children: [
          if (kamituwo.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'Kepala Dusun (Kamituwo)',
              icon: PhosphorIcons.userCircle(PhosphorIconsStyle.bold),
              children: kamituwo
                  .map(
                    (item) => _buildStrukturItem(
                      item['dusun'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (perangkatLain.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'Perangkat Lainnya',
              icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
              children: perangkatLain
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (bpd.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'Badan Permusyawaratan Desa (BPD)',
              icon: PhosphorIcons.usersFour(PhosphorIconsStyle.bold),
              children: bpd
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (lpmd.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'LPMD',
              icon: PhosphorIcons.handshake(PhosphorIconsStyle.bold),
              children: lpmd
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (karangTaruna.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'Karang Taruna',
              icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
              children: karangTaruna
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (pkk.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'PKK',
              icon: PhosphorIcons.userList(PhosphorIconsStyle.bold),
              children: pkk
                  .map(
                    (item) => _buildStrukturItem(
                      item['jabatan'] ?? '-',
                      item['nama'] ?? '-',
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      );
    });
  }

  // ================= TAB 3: WILAYAH =================
  Widget _buildWilayahTab() {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        // Wilayah Administratif
        _buildSectionCard(
          title: 'Wilayah Administratif',
          icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.bold),
          children: [
            _buildInfoRow(
              'Jumlah Dusun',
              '${controller.getDataInt('jumlah_dusun')} Dusun',
            ),
            _buildInfoRow(
              'Nama Dusun',
              controller.getDataList('nama_dusun').join(', '),
            ),
            _buildInfoRow(
              'Jumlah RW',
              '${controller.getDataInt('jumlah_rw')} RW',
            ),
            _buildInfoRow(
              'Jumlah RT',
              '${controller.getDataInt('jumlah_rt')} RT',
            ),
          ],
        ),

        TSpaces.v16(),

        // Batas Wilayah
        _buildSectionCard(
          title: 'Batas Wilayah',
          icon: PhosphorIcons.compass(PhosphorIconsStyle.bold),
          children: [
            _buildInfoRow('Utara', controller.getData('batas_utara')),
            _buildInfoRow('Selatan', controller.getData('batas_selatan')),
            _buildInfoRow('Barat', controller.getData('batas_barat')),
            _buildInfoRow('Timur', controller.getData('batas_timur')),
          ],
        ),

        TSpaces.v16(),

        // Penggunaan Lahan
        _buildSectionCard(
          title: 'Penggunaan Lahan',
          icon: PhosphorIcons.tree(PhosphorIconsStyle.bold),
          children: [
            _buildInfoRow(
              'Pemukiman',
              controller.getData('lahan_pemukiman', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Pertanian',
              controller.getData('lahan_pertanian', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Perkebunan',
              controller.getData('lahan_perkebunan', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Perkantoran',
              controller.getData('lahan_perkantoran', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Sekolah',
              controller.getData('lahan_sekolah', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Olahraga',
              controller.getData('lahan_olahraga', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Pemakaman',
              controller.getData('lahan_pemakaman', defaultValue: '-'),
            ),
            _buildInfoRow(
              'Jalan Desa',
              controller.getData('lahan_jalan', defaultValue: '-'),
            ),
          ],
        ),
      ],
    );
  }

  // ================= TAB 4: DATA =================
  Widget _buildDataTab() {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        // Demografi
        _buildSectionCard(
          title: 'Data Kependudukan',
          icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
          children: [
            _buildInfoRow(
              'Total Penduduk',
              '${controller.getDataInt('total_penduduk')} jiwa',
            ),
            _buildInfoRow(
              'Laki-laki',
              '${controller.getDataInt('laki_laki')} jiwa',
            ),
            _buildInfoRow(
              'Perempuan',
              '${controller.getDataInt('perempuan')} jiwa',
            ),
            _buildInfoRow(
              'Total KK',
              '${controller.getDataInt('total_kk')} KK',
            ),
          ],
        ),

        TSpaces.v16(),

        // Statistik Card
        if (controller.getDataInt('total_penduduk') > 0)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TColorsConst.blue500, TColorsConst.blue600],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: TColorsConst.blue500.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Rasio Gender',
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
                TSpaces.v16(),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: PhosphorIcons.genderMale(PhosphorIconsStyle.fill),
                        label: 'Laki-laki',
                        value:
                            '${((controller.getDataInt('laki_laki') / controller.getDataInt('total_penduduk')) * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                    TSpaces.h12(),
                    Expanded(
                      child: _buildStatCard(
                        icon: PhosphorIcons.genderFemale(
                          PhosphorIconsStyle.fill,
                        ),
                        label: 'Perempuan',
                        value:
                            '${((controller.getDataInt('perempuan') / controller.getDataInt('total_penduduk')) * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ================= TAB 5: SEJARAH =================
  Widget _buildSejarahTab() {
    return Obx(() {
      final timeline = controller.getDataObjectList('timeline_sejarah');
      final sejarahSingkat = controller.getData('sejarah_singkat');
      final asalUsulNama = controller.getData('asal_usul_nama');
      final isEmpty =
          sejarahSingkat.isEmpty && asalUsulNama.isEmpty && timeline.isEmpty;

      if (isEmpty && controller.isAdmin.value) {
        return _buildEmptyStateWithAction(
          'Data Sejarah Belum Diisi',
          'Silakan isi data sejarah desa melalui menu edit',
          PhosphorIcons.book(PhosphorIconsStyle.thin),
        );
      }

      return ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Sejarah Desa
          if (sejarahSingkat.isNotEmpty)
            _buildSectionCard(
              title: 'Sejarah Desa',
              icon: PhosphorIcons.book(PhosphorIconsStyle.bold),
              children: [
                Text(
                  sejarahSingkat,
                  style: TGoogleTextStyleConst.inter14Regular.copyWith(
                    color: TColorsConst.neutral700,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),

          if (sejarahSingkat.isNotEmpty && timeline.isNotEmpty) TSpaces.v16(),

          // Timeline Sejarah
          if (timeline.isNotEmpty)
            _buildSectionCard(
              title: 'Timeline Penting',
              icon: PhosphorIcons.clockCounterClockwise(
                PhosphorIconsStyle.bold,
              ),
              children: timeline
                  .map(
                    (item) => _buildTimelineItem(
                      item['tahun'] ?? '-',
                      item['judul'] ?? '-',
                      item['deskripsi'] ?? '',
                    ),
                  )
                  .toList(),
            ),

          if (asalUsulNama.isNotEmpty) ...[
            TSpaces.v16(),
            _buildSectionCard(
              title: 'Asal Usul Nama',
              icon: PhosphorIcons.textAa(PhosphorIconsStyle.bold),
              children: [
                Text(
                  asalUsulNama,
                  style: TGoogleTextStyleConst.inter14Regular.copyWith(
                    color: TColorsConst.neutral700,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  // ================= HELPER WIDGETS =================

  Widget _buildEmptyStateWithAction(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: TColorsConst.neutral300),
            TSpaces.v16(),
            Text(
              title,
              style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
                color: TColorsConst.neutral800,
              ),
              textAlign: TextAlign.center,
            ),
            TSpaces.v8(),
            Text(
              subtitle,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: TColorsConst.neutral300.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: TColorsConst.blue50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: TColorsConst.blue500, size: 20.sp),
                TSpaces.h12(),
                Text(
                  title,
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: TColorsConst.blue700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TGoogleTextStyleConst.inter14Medium.copyWith(
                color: TColorsConst.neutral600,
              ),
            ),
          ),
          TSpaces.h8(),
          Expanded(
            child: Text(
              value,
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisiMisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visi',
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: TColorsConst.blue600,
          ),
        ),
        TSpaces.v8(),
        Text(
          controller.getData('visi'),
          style: TGoogleTextStyleConst.inter14Regular.copyWith(
            color: TColorsConst.neutral700,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        TSpaces.v16(),
        Text(
          'Misi',
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: TColorsConst.blue600,
          ),
        ),
        TSpaces.v8(),
        ...controller.getDataList('misi').asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key + 1}. ',
                  style: TGoogleTextStyleConst.inter14Medium.copyWith(
                    color: TColorsConst.blue500,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TGoogleTextStyleConst.inter14Regular.copyWith(
                      color: TColorsConst.neutral700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKepalaDesaHistoryItem(
    String number,
    String nama,
    String periode,
    String durasi, {
    bool isActive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isActive ? TColorsConst.blue50 : TColorsConst.neutral50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isActive ? TColorsConst.blue200 : TColorsConst.neutral200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isActive ? TColorsConst.blue500 : TColorsConst.neutral400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: isActive
                        ? TColorsConst.blue700
                        : TColorsConst.neutral800,
                  ),
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
                      periode,
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral600,
                      ),
                    ),
                    TSpaces.h8(),
                    Text(
                      '($durasi)',
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
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
    );
  }

  Widget _buildStrukturItem(String jabatan, String nama) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          if (jabatan.isNotEmpty)
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              size: 16.sp,
              color: TColorsConst.blue500,
            ),
          if (jabatan.isNotEmpty) TSpaces.h8(),
          if (jabatan.isEmpty) SizedBox(width: 24.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TGoogleTextStyleConst.inter14Regular.copyWith(
                  color: TColorsConst.neutral700,
                ),
                children: [
                  if (jabatan.isNotEmpty)
                    TextSpan(
                      text: '$jabatan: ',
                      style: TGoogleTextStyleConst.inter14Medium,
                    ),
                  TextSpan(text: nama),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32.sp),
          TSpaces.v8(),
          Text(
            label,
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          TSpaces.v4(),
          Text(
            value,
            style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String year, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              if (description.isNotEmpty)
                Container(
                  width: 2.w,
                  height: 40.h,
                  color: TColorsConst.blue200,
                ),
            ],
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                    color: TColorsConst.blue600,
                  ),
                ),
                TSpaces.v4(),
                Text(
                  title,
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: TColorsConst.neutral800,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  TSpaces.v4(),
                  Text(
                    description,
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.neutral600,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TAB BAR DELEGATE =================
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
