import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TButtons {
  TButtons._();

  static Widget primary({
    required VoidCallback? onPressed,
    required String text,
    double? height,
    double? width,
    double? elevation,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        backgroundColor: backgroundColor ?? TColorsConst.blue500,
        minimumSize: Size(width ?? double.infinity, height ?? 44.h),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style:
            textStyle ??
            TGoogleTextStyleConst.inter14Medium.copyWith(
              color: textColor ?? TColorsConst.white,
            ),
      ),
    );
  }

  static Widget outline({
    required VoidCallback? onPressed,
    required String text,
    double? height,
    double? width,
    Color? borderColor,
    Color? textColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? borderWidth,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, height ?? 44.h),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        side: BorderSide(
          color: borderColor ?? TColorsConst.blue500,
          width: borderWidth ?? 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Text(
        text,
        style:
            textStyle ??
            TGoogleTextStyleConst.inter14Medium.copyWith(
              color: textColor ?? TColorsConst.blue500,
            ),
      ),
    );
  }
}
