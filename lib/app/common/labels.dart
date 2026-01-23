import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TLabels {
  static Row labelMandatory({required String text, TextStyle? style}) {
    return Row(
      children: [
        Text(text, style: style ?? TGoogleTextStyleConst.inter14SemiBold),
        SizedBox(width: 4.w),
        Text(
          "*",
          style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
            color: TColorsConst.errorMain,
          ),
        ),
      ],
    );
  }

  static Text labelOptional({required String text, TextStyle? style}) {
    return Text(text, style: style ?? TGoogleTextStyleConst.inter12SemiBold);
  }
}
