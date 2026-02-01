import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadProfile(context);

    return Scaffold(
      backgroundColor: TColorsConst.white,
      appBar: AppBar(
        backgroundColor: TColorsConst.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TColorsConst.neutral200,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: TColorsConst.neutral100,
                            backgroundImage:
                                controller.photoProfile.value.isNotEmpty
                                ? NetworkImage(controller.photoProfile.value)
                                : null,
                            child: controller.photoProfile.value.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: TColorsConst.neutral400,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showImageSourceDialog(context),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: TColorsConst.blue500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: TColorsConst.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16.sp,
                                color: TColorsConst.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TSpaces.v16(),
                    Text(
                      controller.name.value.isNotEmpty
                          ? controller.name.value
                          : controller.username.value.isNotEmpty
                          ? controller.username.value
                          : 'User',
                      style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
                        color: TColorsConst.black,
                      ),
                    ),
                    TSpaces.v4(),
                    Text(
                      controller.email.value,
                      style: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral500,
                      ),
                    ),
                    if (controller.role.value.isNotEmpty) ...[
                      TSpaces.v8(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: TColorsConst.blue50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          controller.role.value.toUpperCase(),
                          style: TGoogleTextStyleConst.inter12Medium.copyWith(
                            color: TColorsConst.blue600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: OutlinedButton(
                  onPressed: () => controller.goToEditProfile(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 44.h),
                    side: const BorderSide(
                      color: TColorsConst.neutral300,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Edit profile',
                    style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                      color: TColorsConst.black,
                    ),
                  ),
                ),
              ),

              TSpaces.v24(),

              _buildSectionHeader('Informasi Akun'),
              _buildInfoTile(
                icon: Icons.badge_outlined,
                title: 'NIK',
                value: controller.nik.value.isEmpty
                    ? 'Belum diisi'
                    : controller.nik.value,
              ),
              _buildInfoTile(
                icon: Icons.cake_outlined,
                title: 'Tanggal Lahir',
                value: controller.tanggalLahir.value.isEmpty
                    ? 'Belum diisi'
                    : controller.tanggalLahir.value,
              ),
              _buildInfoTile(
                icon: Icons.person_outline,
                title: 'Username',
                value: controller.username.value.isEmpty
                    ? 'Belum diisi'
                    : controller.username.value,
              ),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                title: 'No. Telepon',
                value: controller.phone.value.isEmpty
                    ? 'Belum diisi'
                    : controller.phone.value,
              ),
              _buildInfoTile(
                icon: Icons.wc_outlined,
                title: 'Jenis Kelamin',
                value: controller.gender.value.isEmpty
                    ? 'Belum diisi'
                    : controller.gender.value,
              ),
              _buildInfoTile(
                icon: Icons.location_on_outlined,
                title: 'Alamat',
                value: controller.address.value.isEmpty
                    ? 'Belum diisi'
                    : controller.address.value,
                maxLines: 2,
              ),

              TSpaces.v24(),

              _buildSectionHeader('Preferences'),

              Obx(() {
                if (controller.isBiometricAvailable.value) {
                  return _buildSwitchMenuItem(
                    icon: controller.biometricType.value == 'Face ID'
                        ? Icons.face
                        : Icons.fingerprint,
                    title: controller.biometricType.value,
                    value: controller.isBiometricEnabled.value,
                    onChanged: (val) =>
                        controller.toggleBiometric(context, val),
                  );
                }
                return const SizedBox.shrink();
              }),

              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Ganti Password',
                onTap: () => controller.goToChangePassword(context),
              ),

              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: () => controller.logout(context),
              ),

              TSpaces.v40(),
            ],
          ),
        );
      }),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: TColorsConst.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickAndUploadImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickAndUploadImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TGoogleTextStyleConst.inter12Medium.copyWith(
            color: TColorsConst.neutral500,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        border: Border(
          bottom: BorderSide(color: TColorsConst.neutral200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: TColorsConst.neutral100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: TColorsConst.neutral700),
          ),
          TSpaces.h12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: TColorsConst.neutral500,
                  ),
                ),
                TSpaces.v4(),
                Text(
                  value,
                  style: TGoogleTextStyleConst.inter14Medium.copyWith(
                    color: value == 'Belum diisi'
                        ? TColorsConst.neutral400
                        : TColorsConst.black,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: TColorsConst.white,
          border: Border(
            bottom: BorderSide(color: TColorsConst.neutral200, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDestructive
                    ? TColorsConst.red50
                    : TColorsConst.neutral100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: isDestructive
                    ? TColorsConst.red600
                    : TColorsConst.neutral700,
              ),
            ),
            TSpaces.h12(),
            Expanded(
              child: Text(
                title,
                style: TGoogleTextStyleConst.inter14Medium.copyWith(
                  color: isDestructive
                      ? TColorsConst.red600
                      : TColorsConst.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: TColorsConst.neutral400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: TColorsConst.white,
        border: Border(
          bottom: BorderSide(color: TColorsConst.neutral200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: TColorsConst.neutral100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: TColorsConst.neutral700),
          ),
          TSpaces.h12(),
          Expanded(
            child: Text(
              title,
              style: TGoogleTextStyleConst.inter14Medium.copyWith(
                color: TColorsConst.black,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: TColorsConst.green500,
          ),
        ],
      ),
    );
  }
}
