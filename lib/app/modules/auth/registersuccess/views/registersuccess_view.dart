import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';

class RegistersuccessView extends StatelessWidget {
  const RegistersuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = Get.arguments?['phone'];

    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.LOGIN);
    });

    return Scaffold(
      backgroundColor: TColorsConst.neutral100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: TColorsConst.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    TAssetsConst.success,
                    width: 160.w,
                    repeat: false,
                  ),

                  SizedBox(height: 16.h),

                  Text('Berhasil', style: TGoogleTextStyleConst.inter20Bold),

                  SizedBox(height: 6.h),

                  Text(
                    phone != null
                        ? 'Kode OTP akan dikirim ke\n$phone'
                        : 'Akun Anda berhasil dibuat',
                    style: TGoogleTextStyleConst.inter14Regular.copyWith(
                      color: TColorsConst.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20.h),

                  SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: const CircularProgressIndicator(strokeWidth: 2.5),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Mengalihkan ke halaman login...',
                    style: TGoogleTextStyleConst.inter12Regular.copyWith(
                      color: TColorsConst.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
