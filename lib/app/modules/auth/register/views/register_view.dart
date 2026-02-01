import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/common/text_fields.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.white,

      body: SafeArea(
        child: Column(
          children: [
            // ===== CONTENT (SCROLLABLE) =====
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TSpaces.v48(),

                    Text('Daftar', style: TGoogleTextStyleConst.inter24Bold),
                    TSpaces.v8(),
                    Text(
                      'Buat akun baru 👋',
                      style: TGoogleTextStyleConst.inter14Regular.copyWith(
                        color: TColorsConst.neutral500,
                      ),
                    ),

                    TSpaces.v24(),

                    Text('Nama', style: TGoogleTextStyleConst.inter14Medium),
                    TSpaces.v8(),
                    TTextFields.buildStandard(
                      controller: controller.nameController,
                      hintText: 'Masukkan nama Anda',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),

                    TSpaces.v20(),

                    Text('Email', style: TGoogleTextStyleConst.inter14Medium),
                    TSpaces.v8(),
                    TTextFields.buildStandard(
                      controller: controller.emailController,
                      hintText: 'Masukkan email Anda',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),

                    TSpaces.v20(),

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

            // ===== FOOTER =====
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => TButtons.primary(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.register(context),
                      text: controller.isLoading.value
                          ? 'Mendaftarkan...'
                          : 'Daftar',
                      height: 48.h,
                    ),
                  ),

                  TSpaces.v16(),

                  RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TGoogleTextStyleConst.inter12Regular.copyWith(
                        color: TColorsConst.neutral600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: TGoogleTextStyleConst.inter12Medium.copyWith(
                            color: TColorsConst.blue500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(Routes.LOGIN);
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
