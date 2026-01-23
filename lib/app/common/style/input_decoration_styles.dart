import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TInputDecorationStyles {
  static InputDecoration outlineInputBorder(
    String hintText, {
    bool useLabel = true,
    bool blackLabel = true,
  }) => InputDecoration(
    hintText: hintText,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.neutral400.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.neutral400.withOpacity(0.3)),
    ),
    focusColor: TColorsConst.blue400,
    hintStyle: TGoogleTextStyleConst.inter12Medium.copyWith(
      color: TColorsConst.neutral400,
      fontSize: 14.sp,
    ),
    floatingLabelBehavior: useLabel
        ? FloatingLabelBehavior.auto
        : FloatingLabelBehavior.never,
    floatingLabelStyle: TGoogleTextStyleConst.inter12Medium.copyWith(
      color: TColorsConst.blue400,
      fontSize: 12.sp,
    ),
    labelText: hintText,
    alignLabelWithHint: true,
    labelStyle: blackLabel
        ? TGoogleTextStyleConst.inter12Medium.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          )
        : TGoogleTextStyleConst.inter12Medium.copyWith(
            color: TColorsConst.neutral400,
            fontSize: 14.sp,
          ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.blue400, width: 2.w),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: Colors.red.shade400, width: 2.w),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
  );

  // Fill Rounded Button Styles
  static InputDecoration outlineDropdownInputBorder(
    String hintText, {
    bool useLabel = true,
  }) => InputDecoration(
    hintText: hintText,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.neutral400.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.neutral400.withOpacity(0.3)),
    ),
    focusColor: TColorsConst.blue400,
    hintStyle: TGoogleTextStyleConst.inter12Medium.copyWith(
      fontSize: 14.sp,
      color: TColorsConst.neutral400,
    ),
    floatingLabelBehavior: useLabel
        ? FloatingLabelBehavior.auto
        : FloatingLabelBehavior.never,
    floatingLabelStyle: TGoogleTextStyleConst.inter12Medium.copyWith(
      color: TColorsConst.blue400,
      fontSize: 12.sp,
    ),
    labelText: hintText,
    labelStyle: TGoogleTextStyleConst.inter12Medium.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: TColorsConst.blue400, width: 2.w),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
      borderSide: BorderSide(color: Colors.red.shade400, width: 2.w),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
  );
}
