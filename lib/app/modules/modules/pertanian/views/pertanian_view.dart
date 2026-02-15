import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class PertanianView extends GetView<PertanianController> {
  const PertanianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kelompok Tani'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Statistik Cards
            _buildStatistikSection(),
            const SizedBox(height: 16),

            // Kelompok Tani List
            _buildKelompokSection(context),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAdmin.value) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _showKelompokForm(context),
          icon: const Icon(
            Icons.add,
            color: Colors.blue, // icon biru
          ),
          label: const Text(
            'Tambah Kelompok',
            style: TextStyle(
              color: Colors.blue, // text biru
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white, // bg putih
          elevation: 4,
        );
      }),
    );
  }

  Widget _buildStatistikSection() {
    return Obx(() {
      final stats = controller.statistik;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Kelompok',
                  '${stats['total_kelompok'] ?? 0}',
                  Icons.groups,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Anggota',
                  '${stats['total_anggota'] ?? 0}',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Luas Tanam',
                  '${stats['total_luas_tanam']?.toStringAsFixed(2) ?? '0'} Ha',
                  Icons.landscape,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPupukStatCard(stats['total_kebutuhan_pupuk']),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPupukStatCard(dynamic pupuk) {
    if (pupuk == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.grass, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Kebutuhan Pupuk (Kg)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPupukRow('UREA', pupuk['urea'] ?? 0, Colors.blue),
          const SizedBox(height: 8),
          _buildPupukRow('NPK', pupuk['npk'] ?? 0, Colors.orange),
          const SizedBox(height: 8),
          _buildPupukRow(
            'NPK Formula',
            pupuk['npk_formula'] ?? 0,
            Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildPupukRow('Organik', pupuk['organik'] ?? 0, Colors.green),
          const SizedBox(height: 8),
          _buildPupukRow('ZA', pupuk['za'] ?? 0, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildPupukRow(String jenis, int total, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(jenis, style: const TextStyle(fontSize: 13)),
          ],
        ),
        Text(
          '$total Kg',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildKelompokSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Kelompok Tani',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.kelompokTaniList.isEmpty) {
            return _buildEmptyKelompok();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.kelompokTaniList.length,
            itemBuilder: (context, index) {
              final kelompok = controller.kelompokTaniList[index];
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _showKelompokDetail(context, kelompok),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kelompok['nama_kelompok'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kode: ${kelompok['kode_kelompok'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (!controller.isAdmin.value) {
                      return const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      );
                    }
                    return PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showKelompokForm(context, kelompok: kelompok);
                        } else if (value == 'delete') {
                          _confirmDeleteKelompok(context, kelompok);
                        }
                      },
                    );
                  }),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person,
                      'Ketua',
                      kelompok['ketua_kelompok'] ?? '-',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.grass,
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
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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

  Widget _buildEmptyKelompok() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada kelompok tani',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan kelompok tani baru',
              style: TextStyle(color: Colors.grey[600]),
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
    Get.toNamed(Routes.KELOMPOK_FORM, arguments: kelompok ?? {});
  }

  void _showKelompokDetail(
    BuildContext context,
    Map<String, dynamic> kelompok,
  ) {
    // Use Routes constant instead of string
    Get.toNamed(Routes.KELOMPOK_DETAIL, arguments: kelompok);
  }

  void _confirmDeleteKelompok(
    BuildContext context,
    Map<String, dynamic> kelompok,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelompok "${kelompok['nama_kelompok']}"?\n\nSemua data anggota akan ikut terhapus.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteKelompokTani(kelompok['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
