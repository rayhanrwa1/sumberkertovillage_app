import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/changepassword_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

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
          'Ganti Password',
          style: TGoogleTextStyleConst.inter18SemiBold.copyWith(
            color: TColorsConst.black,
          ),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TSpaces.v24(),

                  // Info Card
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: TColorsConst.blue50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: TColorsConst.blue200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TColorsConst.blue600,
                          size: 24.sp,
                        ),
                        TSpaces.h12(),
                        Expanded(
                          child: Text(
                            'Password baru minimal 6 karakter dan berbeda dari password saat ini',
                            style: TGoogleTextStyleConst.inter12Regular
                                .copyWith(color: TColorsConst.blue700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  TSpaces.v32(),

                  // Current Password
                  Text(
                    'Password Saat Ini',
                    style: TGoogleTextStyleConst.inter14Medium.copyWith(
                      color: TColorsConst.black,
                    ),
                  ),
                  TSpaces.v8(),
                  TextField(
                    controller: controller.currentPasswordController,
                    obscureText: !controller.isCurrentPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password saat ini',
                      hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral400,
                      ),
                      filled: true,
                      fillColor: TColorsConst.neutral50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.blue500,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isCurrentPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: TColorsConst.neutral400,
                        ),
                        onPressed: controller.toggleCurrentPasswordVisibility,
                      ),
                    ),
                  ),

                  TSpaces.v24(),

                  // New Password
                  Text(
                    'Password Baru',
                    style: TGoogleTextStyleConst.inter14Medium.copyWith(
                      color: TColorsConst.black,
                    ),
                  ),
                  TSpaces.v8(),
                  TextField(
                    controller: controller.newPasswordController,
                    obscureText: !controller.isNewPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password baru',
                      hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral400,
                      ),
                      filled: true,
                      fillColor: TColorsConst.neutral50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.blue500,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isNewPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: TColorsConst.neutral400,
                        ),
                        onPressed: controller.toggleNewPasswordVisibility,
                      ),
                    ),
                  ),

                  TSpaces.v24(),

                  // Confirm Password
                  Text(
                    'Konfirmasi Password Baru',
                    style: TGoogleTextStyleConst.inter14Medium.copyWith(
                      color: TColorsConst.black,
                    ),
                  ),
                  TSpaces.v8(),
                  TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: 'Masukkan ulang password baru',
                      hintStyle: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral400,
                      ),
                      filled: true,
                      fillColor: TColorsConst.neutral50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.neutral200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: TColorsConst.blue500,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: TColorsConst.neutral400,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),

                  TSpaces.v40(),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColorsConst.blue500,
                        disabledBackgroundColor: TColorsConst.neutral300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading Overlay
            if (controller.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }
}
