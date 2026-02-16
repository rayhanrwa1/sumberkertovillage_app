import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';

class AnggotaFormView extends GetView<PertanianController> {
  const AnggotaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final kelompokId = args['kelompokId'];
    final anggota = args['anggota'] as Map<String, dynamic>?;
    final isEdit = anggota != null;

    if (isEdit) {
      controller.populateAnggotaForm(anggota);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Anggota' : 'Tambah Anggota',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Form(
        key: controller.formKeyAnggota,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Data Pribadi
            _buildSectionCard(
              title: 'Data Pribadi',
              children: [
                _buildTextField(
                  controller: controller.nikController,
                  label: 'NIK',
                  hint: '16 digit NIK',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: controller.validateNIK,
                ),
                TSpaces.v16(),
                _buildTextField(
                  controller: controller.namaAnggotaController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                TSpaces.v16(),
                _buildTextField(
                  controller: controller.alamatAnggotaController,
                  label: 'Alamat',
                  hint: 'Alamat lengkap',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                TSpaces.v16(),
                _buildTextField(
                  controller: controller.noTelpController,
                  label: 'Nomor Telepon',
                  hint: '08xxx atau 62xxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^(08|62)[0-9]{8,11}$').hasMatch(value)) {
                        return 'Format nomor tidak valid';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
            TSpaces.v16(),

            // Rencana Tanam
            _buildSectionCard(
              title: 'Rencana Tanam',
              children: [
                _buildTextField(
                  controller: controller.rencanaTanamController,
                  label: 'Luas Tanam',
                  hint: 'Contoh: 0.5',
                  icon: Icons.landscape_outlined,
                  suffix: 'Ha',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rencana tanam harus diisi';
                    }
                    final double? luas = double.tryParse(value);
                    if (luas == null) {
                      return 'Masukkan angka yang valid';
                    }
                    if (luas <= 0) {
                      return 'Luas harus lebih dari 0';
                    }
                    if (luas > 5) {
                      return 'Luas maksimal 5 Ha';
                    }
                    return null;
                  },
                ),
                TSpaces.v12(),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 26, 152, 255),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 18,
                      ),
                      TSpaces.h8(),
                      Text(
                        'Maksimal 5 Ha per anggota',
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TSpaces.v16(),

            // Kebutuhan Pupuk
            _buildSectionCard(
              title: 'Kebutuhan Pupuk Bersubsidi',
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 26, 152, 255),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 18,
                      ),
                      TSpaces.h8(),
                      Expanded(
                        child: Text(
                          'Input kebutuhan pupuk untuk 3 musim tanam (MT1, MT2, MT3) dalam satuan Kg',
                          style: TGoogleTextStyleConst.inter12Regular.copyWith(
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TSpaces.v16(),
                _buildPupukCard(
                  'UREA',
                  controller.ureaM1Controller,
                  controller.ureaM2Controller,
                  controller.ureaM3Controller,
                ),
                TSpaces.v12(),
                _buildPupukCard(
                  'NPK',
                  controller.npkM1Controller,
                  controller.npkM2Controller,
                  controller.npkM3Controller,
                ),
                TSpaces.v12(),
                _buildPupukCard(
                  'NPK Formula',
                  controller.npkFormulaM1Controller,
                  controller.npkFormulaM2Controller,
                  controller.npkFormulaM3Controller,
                ),
                TSpaces.v12(),
                _buildPupukCard(
                  'Organik',
                  controller.organikM1Controller,
                  controller.organikM2Controller,
                  controller.organikM3Controller,
                ),
                TSpaces.v12(),
                _buildPupukCard(
                  'ZA',
                  controller.zaM1Controller,
                  controller.zaM2Controller,
                  controller.zaM3Controller,
                ),
              ],
            ),
            TSpaces.v24(),

            // Submit Button
            Obx(
              () => SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.formKeyAnggota.currentState!
                              .validate()) {
                            if (isEdit) {
                              controller.updateAnggota(
                                kelompokId,
                                anggota['id'],
                                context,
                              );
                            } else {
                              controller.createAnggota(kelompokId, context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 26, 152, 255),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Perbarui Data' : 'Simpan Data',
                          style: TGoogleTextStyleConst.inter16SemiBold,
                        ),
                ),
              ),
            ),
            TSpaces.v16(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TGoogleTextStyleConst.inter16Bold.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TSpaces.v16(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
        ),
        TSpaces.v8(),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
            suffixText: suffix,
            suffixStyle: TGoogleTextStyleConst.inter14SemiBold.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF5BA4C6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
          style: TGoogleTextStyleConst.inter14Regular.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPupukCard(
    String jenisPupuk,
    TextEditingController mt1Controller,
    TextEditingController mt2Controller,
    TextEditingController mt3Controller,
  ) {
    final total = 0.obs;

    void updateTotal() {
      total.value =
          (int.tryParse(mt1Controller.text) ?? 0) +
          (int.tryParse(mt2Controller.text) ?? 0) +
          (int.tryParse(mt3Controller.text) ?? 0);
    }

    mt1Controller.addListener(updateTotal);
    mt2Controller.addListener(updateTotal);
    mt3Controller.addListener(updateTotal);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jenisPupuk,
            style: TGoogleTextStyleConst.inter14Bold.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TSpaces.v12(),
          Row(
            children: [
              Expanded(
                child: _buildPupukTextField(
                  controller: mt1Controller,
                  label: 'MT 1',
                ),
              ),
              TSpaces.h8(),
              Expanded(
                child: _buildPupukTextField(
                  controller: mt2Controller,
                  label: 'MT 2',
                ),
              ),
              TSpaces.h8(),
              Expanded(
                child: _buildPupukTextField(
                  controller: mt3Controller,
                  label: 'MT 3',
                ),
              ),
            ],
          ),
          TSpaces.v12(),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 26, 152, 255),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TGoogleTextStyleConst.inter12SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${total.value} Kg',
                    style: TGoogleTextStyleConst.inter12Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPupukTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TGoogleTextStyleConst.inter12Regular.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        TSpaces.v8(),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 8, 156, 255),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 10.h,
            ),
          ),
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
