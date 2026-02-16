import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/common/text_fields.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/modules/modules/pertanian/controllers/pertanian_controller.dart';

class KelompokFormViewImproved extends GetView<PertanianController> {
  const KelompokFormViewImproved({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? kelompok =
        Get.arguments as Map<String, dynamic>?;
    final isEdit = kelompok != null && kelompok.isNotEmpty;

    // Initialize form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit) {
        controller.populateKelompokForm(kelompok);
      } else {
        controller.clearKelompokForm();
        // Set default values
        if (controller.subsektorOptions.isNotEmpty &&
            controller.subsektorController.text.isEmpty) {
          controller.subsektorController.text =
              controller.subsektorOptions.first;
          controller.updateKomoditasOptions(controller.subsektorOptions.first);
        }
      }
    });

    return Scaffold(
      backgroundColor: TColorsConst.neutral50,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Kelompok Tani' : 'Tambah Kelompok Tani',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 63, 150, 255),
        iconTheme: const IconThemeData(color: TColorsConst.white),
      ),
      body: Form(
        key: controller.formKeyKelompok,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Informasi Kelompok
            _buildSectionCard(
              title: 'Informasi Kelompok',
              children: [
                TTextFields.buildStandard(
                  controller: controller.kodeKelompokController,
                  hintText: 'Contoh: 889860',
                  keyboardType: TextInputType.number,
                ),
                TSpaces.v12(),

                TTextFields.buildStandard(
                  controller: controller.namaKelompokController,
                  hintText: 'Contoh: KARYO UTOMO III',
                  textCapitalization: TextCapitalization.characters,
                ),
                TSpaces.v12(),

                TTextFields.buildStandard(
                  controller: controller.ketuaKelompokController,
                  hintText: 'Nama ketua kelompok',
                  textCapitalization: TextCapitalization.words,
                ),
                TSpaces.v12(),

                TTextFields.buildStandard(
                  controller: controller.penyuluhController,
                  hintText: 'Nama penyuluh pendamping',
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            TSpaces.v16(),

            // Lokasi
            _buildSectionCard(
              title: 'Lokasi',
              children: [
                TTextFields.buildStandard(
                  controller: controller.alamatController,
                  hintText: 'Alamat lengkap kelompok',
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                ),
                TSpaces.v12(),

                TTextFields.buildStandard(
                  controller: controller.kecamatanController,
                  hintText: 'Nama kecamatan',
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            TSpaces.v16(),
            // Subsektor & Komoditas
            _buildSectionCard(
              title: 'Subsektor & Komoditas',
              children: [
                Obx(
                  () => TTextFields.buildDropDown<String>(
                    context: context,
                    label: 'Subsektor',
                    hintText: 'Pilih subsektor',
                    items: controller.subsektorOptions,
                    itemLabel: (item) => item,
                    selectedValue: controller.subsektorController.text.isEmpty
                        ? null
                        : controller.subsektorController.text,
                    onChanged: (value) {
                      if (value != null) {
                        controller.subsektorController.text = value;
                        controller.updateKomoditasOptions(value);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Subsektor harus dipilih';
                      }
                      return null;
                    },
                    // UBAH WARNA INI MENJADI PUTIH
                    borderColor:
                        TColorsConst.neutral200, // atau Colors.grey[300]
                    focusedBorderColor: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ), // atau warna biru yang sesuai
                  ),
                ),
                TSpaces.v12(),

                Obx(
                  () => TTextFields.buildDropDown<String>(
                    context: context,
                    label: 'Komoditas',
                    hintText: 'Pilih komoditas',
                    items: controller.komoditasOptions,
                    itemLabel: (item) => item,
                    selectedValue: controller.komoditasController.text.isEmpty
                        ? null
                        : controller.komoditasController.text,
                    onChanged: (value) {
                      if (value != null) {
                        controller.komoditasController.text = value;
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Komoditas harus dipilih';
                      }
                      return null;
                    },
                    // UBAH WARNA INI MENJADI PUTIH
                    borderColor: TColorsConst.neutral200,
                    focusedBorderColor: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ),
                  ),
                ),
              ],
            ),
            TSpaces.v16(),

            // Informasi Tambahan
            _buildSectionCard(
              title: 'Informasi Tambahan',
              children: [
                TTextFields.buildStandard(
                  controller: controller.kiosPupukController,
                  hintText: 'Contoh: VINKA, KIOS',
                  textCapitalization: TextCapitalization.characters,
                ),
                TSpaces.v12(),

                TTextFields.buildStandard(
                  controller: controller.tahunRdkkController,
                  hintText: 'Contoh: 2026',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            TSpaces.v24(),

            // Submit Button
            Obx(
              () => TButtons.primary(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (controller.formKeyKelompok.currentState!
                            .validate()) {
                          if (isEdit) {
                            controller.updateKelompokTani(
                              kelompok['id'],
                              context,
                            );
                          } else {
                            controller.createKelompokTani(context);
                          }
                        }
                      },
                text: controller.isLoading.value
                    ? 'Memproses...'
                    : (isEdit ? 'Perbarui Kelompok' : 'Simpan Kelompok'),
                backgroundColor: TColorsConst.blue500,
                height: 48.h,
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
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: TColorsConst.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: TGoogleTextStyleConst.inter16Bold.copyWith(
                color: TColorsConst.neutral800,
              ),
            ),
          ),
          Divider(height: 1.h, color: const Color.fromARGB(255, 255, 255, 255)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
