import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class KelompokDetailView extends GetView<PertanianController> {
  const KelompokDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final kelompok = Get.arguments as Map<String, dynamic>;
    final kelompokId = kelompok['id'];

    // Load anggota when view opens
    controller.loadAnggota(kelompokId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(kelompok['nama_kelompok'] ?? 'Detail Kelompok'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAnggota(kelompokId),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kelompok Info Card
            _buildKelompokInfoCard(kelompok),
            const SizedBox(height: 16),

            // Anggota Section
            _buildAnggotaSection(kelompokId, context),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAdmin.value) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showAnggotaForm(context, kelompokId),
          icon: const Icon(Icons.person_add),
          label: const Text('Tambah Anggota'),
          backgroundColor: Colors.green[700],
        );
      }),
    );
  }

  Widget _buildKelompokInfoCard(Map<String, dynamic> kelompok) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[500]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelompok['nama_kelompok'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kode: ${kelompok['kode_kelompok'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.person,
                  'Ketua',
                  kelompok['ketua_kelompok'] ?? '-',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.school,
                  'Penyuluh',
                  kelompok['penyuluh_pendamping'] ?? '-',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.category,
                  'Subsektor',
                  kelompok['subsektor'] ?? '-',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.grass,
                  'Komoditas',
                  kelompok['komoditas'] ?? '-',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.store,
                  'Kios Pupuk',
                  kelompok['kios_pupuk'] ?? '-',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
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
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
            const Text(
              'Daftar Anggota',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.anggotaList.length} Anggota',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Text(
              '$number',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            anggota['nama'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('NIK: ${anggota['nik'] ?? '-'}'),
              Text(
                'Luas: ${anggota['rencana_tanam_ha']?.toString() ?? '0'} Ha',
              ),
            ],
          ),
          trailing: Obx(() {
            if (!controller.isAdmin.value) {
              return const Icon(Icons.keyboard_arrow_down);
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () =>
                      _showAnggotaForm(context, kelompokId, anggota: anggota),
                  color: Colors.blue[700],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () =>
                      _confirmDeleteAnggota(context, kelompokId, anggota),
                  color: Colors.red,
                ),
              ],
            );
          }),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kebutuhan Pupuk Bersubsidi (Kg)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (pupuk != null) ...[
                    _buildPupukRow('UREA', pupuk['urea']),
                    _buildPupukRow('NPK', pupuk['npk']),
                    _buildPupukRow('NPK Formula', pupuk['npk_formula']),
                    _buildPupukRow('Organik', pupuk['organik']),
                    _buildPupukRow('ZA', pupuk['za']),
                  ] else
                    const Text('Belum ada data pupuk'),
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

    final mt1 = data['mt1'] ?? 0;
    final mt2 = data['mt2'] ?? 0;
    final mt3 = data['mt3'] ?? 0;
    final total = data['total'] ?? 0;

    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              jenis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text('MT1: $mt1', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text('MT2: $mt2', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text('MT3: $mt3', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              'Total: $total',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnggota() {
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada anggota',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan anggota kelompok tani',
              style: TextStyle(color: Colors.grey[600]),
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

    // Use Routes constant
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
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus anggota "${anggota['nama']}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAnggota(kelompokId, anggota['id']);
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
