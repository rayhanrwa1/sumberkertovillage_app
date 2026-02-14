import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/common/text_fields.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TSpaces.v48(),

                    Text('Masuk', style: TGoogleTextStyleConst.inter24Bold),
                    TSpaces.v8(),
                    Text(
                      'Selamat datang kembali 👋',
                      style: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral500,
                      ),
                    ),

                    TSpaces.v32(),

                    // EMAIL
                    Text('Email', style: TGoogleTextStyleConst.inter14Medium),
                    TSpaces.v8(),
                    TTextFields.buildStandard(
                      controller: controller.emailController,
                      hintText: 'Masukkan email Anda',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),

                    TSpaces.v20(),

                    // PASSWORD
                    Text(
                      'Kata Sandi',
                      style: TGoogleTextStyleConst.inter14Medium,
                    ),
                    TSpaces.v8(),
                    Obx(
                      () => TTextFields.buildStandard(
                        controller: controller.passwordController,
                        hintText: 'Masukkan kata sandi',
                        obscureText: controller.isPasswordHidden.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: controller.togglePassword,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: TColorsConst.neutral200, height: 1),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: Column(
                children: [
                  // LOGIN BUTTON
                  Obx(
                    () => TButtons.primary(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.login(context),
                      text: controller.isLoading.value
                          ? 'Sedang masuk...'
                          : 'Masuk',
                      height: 48.h,
                    ),
                  ),

                  TSpaces.v16(),

                  // DIVIDER
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: TColorsConst.neutral300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'atau',
                          style: TGoogleTextStyleConst.inter12Regular.copyWith(
                            color: TColorsConst.neutral500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: TColorsConst.neutral300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  TSpaces.v16(),

                  // GOOGLE LOGIN (ICON SAMA SEPERTI REGISTER)
                  Obx(
                    () => OutlinedButton(
                      onPressed: controller.isGoogleLoading.value
                          ? null
                          : () => controller.loginWithGoogle(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        side: BorderSide(
                          color: TColorsConst.neutral300,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        backgroundColor: TColorsConst.white,
                      ),
                      child: controller.isGoogleLoading.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  TColorsConst.blue500,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  TAssetsConst.iconGoogle, // ✅ SAMA REGISTER
                                  height: 20.h,
                                  width: 20.w,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Masuk dengan Google',
                                  style: TGoogleTextStyleConst.inter14Medium
                                      .copyWith(color: TColorsConst.neutral700),
                                ),
                              ],
                            ),
                    ),
                  ),

                  TSpaces.v16(),

                  // BIOMETRIC BUTTON
                  Obx(() {
                    if (controller.canUseBiometric.value) {
                      return OutlinedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.loginWithBiometric(context),
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Masuk dengan Biometrik'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48.h),
                          side: BorderSide(
                            color: TColorsConst.blue500,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          foregroundColor: TColorsConst.blue500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  TSpaces.v16(),

                  RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Daftar',
                          style: TGoogleTextStyleConst.inter12Medium.copyWith(
                            color: TColorsConst.blue500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(Routes.REGISTER);
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
