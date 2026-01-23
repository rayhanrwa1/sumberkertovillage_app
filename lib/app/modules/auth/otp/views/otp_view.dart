import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.white,
      appBar: AppBar(title: const Text('Verifikasi OTP'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TSpaces.v32(),

            Text('Masukkan Kode OTP', style: TGoogleTextStyleConst.inter20Bold),
            TSpaces.v8(),
            Text(
              'Kode dikirim ke ${controller.phone}',
              style: TGoogleTextStyleConst.inter14Regular.copyWith(
                color: TColorsConst.neutral500,
              ),
            ),

            TSpaces.v32(),

            TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TGoogleTextStyleConst.inter20Bold,
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

            TSpaces.v24(),

            Obx(
              () => TButtons.primary(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.verifyOtp,
                text: controller.isLoading.value
                    ? 'Memverifikasi...'
                    : 'Verifikasi',
                height: 48.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
