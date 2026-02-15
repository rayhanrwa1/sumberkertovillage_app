import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';

class AnggotaFormView extends GetView<PertanianController> {
  const AnggotaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final kelompokId = args['kelompokId'];
    final anggota = args['anggota'] as Map<String, dynamic>?;
    final isEdit = anggota != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Anggota' : 'Tambah Anggota'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: controller.formKeyAnggota,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Data Anggota
            _buildSectionCard(
              title: 'Data Anggota',
              icon: Icons.person,
              children: [
                _buildTextField(
                  controller: controller.nikController,
                  label: 'NIK',
                  hint: '16 digit NIK',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK harus diisi';
                    }
                    if (value.length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.namaAnggotaController,
                  label: 'Nama Lengkap',
                  hint: 'Nama anggota',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.rencanaTanamController,
                  label: 'Rencana Tanam (Ha)',
                  hint: 'Contoh: 0.5',
                  icon: Icons.landscape,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rencana tanam harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kebutuhan Pupuk
            _buildSectionCard(
              title: 'Kebutuhan Pupuk Bersubsidi (Kg)',
              icon: Icons.grass,
              children: [
                const Text(
                  'Masukkan kebutuhan pupuk per musim tanam (MT1, MT2, MT3)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPupukSection(
                  'UREA',
                  controller.ureaM1Controller,
                  controller.ureaM2Controller,
                  controller.ureaM3Controller,
                  Colors.blue,
                ),
                const Divider(height: 32),
                _buildPupukSection(
                  'NPK',
                  controller.npkM1Controller,
                  controller.npkM2Controller,
                  controller.npkM3Controller,
                  Colors.orange,
                ),
                const Divider(height: 32),
                _buildPupukSection(
                  'NPK Formula',
                  controller.npkFormulaM1Controller,
                  controller.npkFormulaM2Controller,
                  controller.npkFormulaM3Controller,
                  Colors.purple,
                ),
                const Divider(height: 32),
                _buildPupukSection(
                  'Organik',
                  controller.organikM1Controller,
                  controller.organikM2Controller,
                  controller.organikM3Controller,
                  Colors.green,
                ),
                const Divider(height: 32),
                _buildPupukSection(
                  'ZA',
                  controller.zaM1Controller,
                  controller.zaM2Controller,
                  controller.zaM3Controller,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (isEdit) {
                          controller.updateAnggota(
                            kelompokId,
                            anggota['id'],
                            context,
                          );
                        } else {
                          controller.createAnggota(kelompokId, context);
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
                        isEdit ? 'Perbarui Data' : 'Simpan Data',
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
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        counterText: '',
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

  Widget _buildPupukSection(
    String jenisPupuk,
    TextEditingController mt1Controller,
    TextEditingController mt2Controller,
    TextEditingController mt3Controller,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              jenisPupuk,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPupukTextField(
                controller: mt1Controller,
                label: 'MT 1',
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPupukTextField(
                controller: mt2Controller,
                label: 'MT 2',
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPupukTextField(
                controller: mt3Controller,
                label: 'MT 3',
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final total =
              (int.tryParse(mt1Controller.text) ?? 0) +
              (int.tryParse(mt2Controller.text) ?? 0) +
              (int.tryParse(mt3Controller.text) ?? 0);
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total $jenisPupuk',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$total Kg',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPupukTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        labelStyle: TextStyle(color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
