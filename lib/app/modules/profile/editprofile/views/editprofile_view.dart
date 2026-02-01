import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/editprofile_controller.dart';

class EditprofileView extends StatefulWidget {
  const EditprofileView({super.key});

  @override
  State<EditprofileView> createState() => _EditprofileViewState();
}

class _EditprofileViewState extends State<EditprofileView> {
  final EditprofileController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProfileData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.white,
      appBar: AppBar(
        backgroundColor: TColorsConst.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColorsConst.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profil',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.nikController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              /// ================= NIK =================
              _requiredLabel('NIK'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.nikController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: controller.validateNIK,
                decoration: _inputDecoration(
                  hint: 'Masukkan NIK 16 digit',
                  icon: Icons.badge_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= TANGGAL LAHIR =================
              _requiredLabel('Tanggal Lahir'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.tanggalLahirController,
                readOnly: true,
                onTap: () => controller.selectDate(context),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                decoration: _inputDecoration(
                  hint: 'Pilih tanggal lahir',
                  icon: Icons.cake_outlined,
                  suffixIcon: Icons.calendar_today_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= USERNAME =================
              _requiredLabel('Username'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.usernameController,
                validator: controller.validateUsername,
                decoration: _inputDecoration(
                  hint: 'Masukkan username',
                  icon: Icons.person_outline,
                ),
              ),

              TSpaces.v20(),

              /// ================= PHONE =================
              _requiredLabel('No. Telepon'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
                decoration: _inputDecoration(
                  hint: '+62 812 xxxx xxxx',
                  icon: Icons.phone_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= GENDER =================
              _requiredLabel('Jenis Kelamin'),
              TSpaces.v8(),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: TColorsConst.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: controller.selectedGender.value.isEmpty
                              ? TColorsConst.red500
                              : TColorsConst.neutral300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: TColorsConst.white,
                          value: controller.selectedGender.value.isEmpty
                              ? null
                              : controller.selectedGender.value,
                          hint: Text(
                            'Pilih jenis kelamin',
                            style: TGoogleTextStyleConst.inter14Regular
                                .copyWith(color: TColorsConst.neutral400),
                          ),
                          items: controller.genderOptions.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  Icon(
                                    e == 'Laki-laki'
                                        ? Icons.male
                                        : Icons.female,
                                    color: TColorsConst.blue500,
                                  ),
                                  TSpaces.h12(),
                                  Text(e),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            controller.selectedGender.value = v ?? '';
                          },
                        ),
                      ),
                    ),
                    if (controller.selectedGender.value.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 12.w),
                        child: Text(
                          'Jenis kelamin wajib dipilih',
                          style: TGoogleTextStyleConst.inter12Regular.copyWith(
                            color: TColorsConst.red500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              TSpaces.v20(),

              /// ================= ALAMAT =================
              _requiredLabel('Alamat'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.addressController,
                maxLines: 3,
                validator: (v) => v == null || v.length < 10
                    ? 'Alamat minimal 10 karakter'
                    : null,
                decoration: _inputDecoration(
                  hint: 'Masukkan alamat lengkap',
                  icon: Icons.location_on_outlined,
                ),
              ),

              TSpaces.v32(),

              /// ================= SAVE BUTTON =================
              Obx(
                () => TButtons.primary(
                  onPressed:
                      controller.isLoading.value ||
                          !controller.isFormValid.value
                      ? null
                      : () => controller.updateProfile(context),
                  text: controller.isLoading.value
                      ? 'Menyimpan...'
                      : 'Simpan Perubahan',
                ),
              ),

              TSpaces.v20(),
            ],
          ),
        );
      }),
    );
  }

  // ================= REQUIRED LABEL =================
  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TGoogleTextStyleConst.inter14Medium.copyWith(
          color: TColorsConst.black,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: TColorsConst.red500),
          ),
        ],
      ),
    );
  }

  // ================= INPUT DECORATION =================
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      filled: true,
      fillColor: TColorsConst.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: TColorsConst.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: TColorsConst.blue500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: TColorsConst.red500),
      ),
    );
  }
}
