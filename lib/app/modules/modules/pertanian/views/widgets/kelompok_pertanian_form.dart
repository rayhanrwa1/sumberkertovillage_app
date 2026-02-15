import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';

class KelompokFormView extends GetView<PertanianController> {
  const KelompokFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? kelompok =
        Get.arguments as Map<String, dynamic>?;

    final isEdit = kelompok != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kelompok Tani' : 'Tambah Kelompok Tani'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: controller.formKeyKelompok,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'Informasi Kelompok',
              icon: Icons.info_outline,
              children: [
                _buildTextField(
                  controller: controller.kodeKelompokController,
                  label: 'Kode Kelompok',
                  hint: 'Contoh: 889860',
                  icon: Icons.tag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode kelompok harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.namaKelompokController,
                  label: 'Nama Kelompok',
                  hint: 'Contoh: KARYO UTOMO III',
                  icon: Icons.group,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kelompok harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.ketuaKelompokController,
                  label: 'Nama Ketua',
                  hint: 'Nama ketua kelompok',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama ketua harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.penyuluhController,
                  label: 'Penyuluh Pendamping',
                  hint: 'Nama penyuluh',
                  icon: Icons.school,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Subsektor & Komoditas',
              icon: Icons.agriculture,
              children: [
                Obx(
                  () => _buildDropdownField(
                    label: 'Subsektor',
                    value: controller.subsektorController.text.isEmpty
                        ? null
                        : controller.subsektorController.text,
                    items: controller.subsektorOptions,
                    icon: Icons.category,
                    onChanged: (value) {
                      if (value != null) {
                        controller.subsektorController.text = value;
                        controller.updateKomoditasOptions(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Subsektor harus dipilih';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _buildDropdownField(
                    label: 'Komoditas',
                    value: controller.komoditasController.text.isEmpty
                        ? null
                        : controller.komoditasController.text,
                    items: controller.komoditasOptions,
                    icon: Icons.grass,
                    onChanged: (value) {
                      if (value != null) {
                        controller.komoditasController.text = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Komoditas harus dipilih';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Informasi Tambahan',
              icon: Icons.more_horiz,
              children: [
                _buildTextField(
                  controller: controller.kiosPupukController,
                  label: 'Kios Pupuk',
                  hint: 'Contoh: VINKA, KIOS',
                  icon: Icons.store,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.tahunRdkkController,
                  label: 'Tahun RDKK',
                  hint: 'Contoh: 2026',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tahun RDKK harus diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (isEdit) {
                          controller.updateKelompokTani(
                            kelompok['id'],
                            context,
                          );
                        } else {
                          controller.createKelompokTani(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Perbarui Kelompok' : 'Simpan Kelompok',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required RxList<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
