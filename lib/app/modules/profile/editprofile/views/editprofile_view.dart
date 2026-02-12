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
              // ================= SECTION HEADER: DATA WAJIB =================
              _sectionHeader(
                'Data Wajib',
                'Informasi yang harus diisi',
                Icons.person,
              ),
              TSpaces.v16(),

              /// ================= NIK (REQUIRED) =================
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

              /// ================= TANGGAL LAHIR (REQUIRED) =================
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

              /// ================= USERNAME (REQUIRED) =================
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

              /// ================= PHONE (REQUIRED) =================
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

              /// ================= GENDER (REQUIRED) =================
              _requiredLabel('Jenis Kelamin'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedGender.value,
                  hint: 'Pilih jenis kelamin',
                  items: controller.genderOptions,
                  onChanged: (v) => controller.selectedGender.value = v ?? '',
                  isRequired: true,
                  icon: controller.selectedGender.value == 'Laki-laki'
                      ? Icons.male
                      : controller.selectedGender.value == 'Perempuan'
                      ? Icons.female
                      : null,
                ),
              ),

              TSpaces.v20(),

              /// ================= ALAMAT (REQUIRED) =================
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

              TSpaces.v20(),

              /// ================= DUSUN (REQUIRED) =================
              _requiredLabel('Dusun'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedDusun.value,
                  hint: 'Pilih dusun',
                  items: controller.dusunOptions,
                  onChanged: (v) => controller.selectedDusun.value = v ?? '',
                  isRequired: true,
                  icon: Icons.home_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= RW (REQUIRED) =================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _requiredLabel('RW'),
                        TSpaces.v8(),
                        Obx(
                          () => _buildDropdown<String>(
                            value: controller.selectedRW.value,
                            hint: 'Pilih RW',
                            items: controller.rwOptions,
                            onChanged: (v) =>
                                controller.selectedRW.value = v ?? '',
                            isRequired: true,
                            icon: Icons.groups_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TSpaces.h12(),

                  /// ================= RT (REQUIRED) =================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _requiredLabel('RT'),
                        TSpaces.v8(),
                        Obx(
                          () => _buildDropdown<String>(
                            value: controller.selectedRT.value,
                            hint: 'Pilih RT',
                            items: controller.rtOptions,
                            onChanged: (v) =>
                                controller.selectedRT.value = v ?? '',
                            isRequired: true,
                            icon: Icons.group_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              TSpaces.v32(),

              // ================= SECTION HEADER: DATA OPSIONAL =================
              _sectionHeader(
                'Data Opsional',
                'Informasi tambahan (tidak wajib)',
                Icons.info_outline,
              ),
              TSpaces.v16(),

              /// ================= TEMPAT LAHIR (OPTIONAL) =================
              _optionalLabel('Tempat Lahir'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.tempatLahirController,
                decoration: _inputDecoration(
                  hint: 'Contoh: Malang',
                  icon: Icons.location_city_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= STATUS KAWIN (OPTIONAL) =================
              _optionalLabel('Status Perkawinan'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedStatusKawin.value,
                  hint: 'Pilih status perkawinan',
                  items: controller.statusKawinOptions,
                  onChanged: (v) =>
                      controller.selectedStatusKawin.value = v ?? '',
                  isRequired: false,
                  icon: Icons.favorite_outline,
                ),
              ),

              TSpaces.v20(),

              /// ================= GOLONGAN DARAH (OPTIONAL) =================
              _optionalLabel('Golongan Darah'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedGolonganDarah.value,
                  hint: 'Pilih golongan darah',
                  items: controller.golonganDarahOptions,
                  onChanged: (v) =>
                      controller.selectedGolonganDarah.value = v ?? '',
                  isRequired: false,
                  icon: Icons.bloodtype_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= AGAMA (OPTIONAL) =================
              _optionalLabel('Agama'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedAgama.value,
                  hint: 'Pilih agama',
                  items: controller.agamaOptions,
                  onChanged: (v) => controller.selectedAgama.value = v ?? '',
                  isRequired: false,
                  icon: Icons.mosque_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= PENDIDIKAN (OPTIONAL) =================
              _optionalLabel('Pendidikan Terakhir'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedPendidikan.value,
                  hint: 'Pilih pendidikan terakhir',
                  items: controller.pendidikanOptions,
                  onChanged: (v) =>
                      controller.selectedPendidikan.value = v ?? '',
                  isRequired: false,
                  icon: Icons.school_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= PEKERJAAN (OPTIONAL) =================
              _optionalLabel('Pekerjaan'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedPekerjaan.value,
                  hint: 'Pilih pekerjaan',
                  items: controller.pekerjaanOptions,
                  onChanged: (v) =>
                      controller.selectedPekerjaan.value = v ?? '',
                  isRequired: false,
                  icon: Icons.work_outline,
                ),
              ),

              TSpaces.v20(),

              /// ================= KEWARGANEGARAAN (OPTIONAL) =================
              _optionalLabel('Kewarganegaraan'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.kewarganegaraanController,
                decoration: _inputDecoration(
                  hint: 'Contoh: Indonesia',
                  icon: Icons.flag_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= NAMA AYAH (OPTIONAL) =================
              _optionalLabel('Nama Ayah'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.namaAyahController,
                decoration: _inputDecoration(
                  hint: 'Masukkan nama ayah',
                  icon: Icons.person_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= NAMA IBU (OPTIONAL) =================
              _optionalLabel('Nama Ibu'),
              TSpaces.v8(),
              TextFormField(
                controller: controller.namaIbuController,
                decoration: _inputDecoration(
                  hint: 'Masukkan nama ibu',
                  icon: Icons.person_outlined,
                ),
              ),

              TSpaces.v20(),

              /// ================= STATUS KELUARGA (OPTIONAL) =================
              _optionalLabel('Status Keluarga'),
              TSpaces.v8(),
              Obx(
                () => _buildDropdown<String>(
                  value: controller.selectedStatusKeluarga.value,
                  hint: 'Pilih status keluarga',
                  items: controller.statusKeluargaOptions,
                  onChanged: (v) =>
                      controller.selectedStatusKeluarga.value = v ?? '',
                  isRequired: false,
                  icon: Icons.family_restroom_outlined,
                ),
              ),

              TSpaces.v32(),

              /// ================= INFO BOX =================
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: TColorsConst.blue50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: TColorsConst.blue200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: TColorsConst.blue500,
                      size: 20.sp,
                    ),
                    TSpaces.h12(),
                    Expanded(
                      child: Text(
                        'Data yang ditandai * wajib diisi. Data opsional dapat diisi untuk melengkapi profil Anda.',
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.blue700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              TSpaces.v24(),

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

  // ================= SECTION HEADER =================
  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TColorsConst.blue50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: TColorsConst.blue500,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: TColorsConst.white, size: 20.sp),
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    color: TColorsConst.black,
                  ),
                ),
                TSpaces.v4(),
                Text(
                  subtitle,
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: TColorsConst.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  // ================= OPTIONAL LABEL =================
  Widget _optionalLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TGoogleTextStyleConst.inter14Medium.copyWith(
          color: TColorsConst.black,
        ),
        children: [
          TextSpan(
            text: ' (opsional)',
            style: TGoogleTextStyleConst.inter12Regular.copyWith(
              color: TColorsConst.neutral400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DROPDOWN BUILDER =================
  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required Function(T?) onChanged,
    required bool isRequired,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: TColorsConst.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isRequired && (value == null || value.toString().isEmpty)
                  ? TColorsConst.red500
                  : TColorsConst.neutral300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              dropdownColor: TColorsConst.white,
              value: value == null || value.toString().isEmpty ? null : value,
              hint: Text(
                hint,
                style: TGoogleTextStyleConst.inter14Regular.copyWith(
                  color: TColorsConst.neutral400,
                ),
              ),
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Row(
                    children: [
                      if (icon != null)
                        Icon(icon, color: TColorsConst.blue500, size: 20.sp),
                      if (icon != null) TSpaces.h12(),
                      Expanded(
                        child: Text(
                          e.toString(),
                          style: TGoogleTextStyleConst.inter14Regular,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (isRequired && (value == null || value.toString().isEmpty))
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 12.w),
            child: Text(
              'Field ini wajib dipilih',
              style: TGoogleTextStyleConst.inter12Regular.copyWith(
                color: TColorsConst.red500,
              ),
            ),
          ),
      ],
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
