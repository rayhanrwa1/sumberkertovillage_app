import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TInputs {
  static GestureDetector uploadFileInput({
    required String? filePath,
    required VoidCallback onTap,
    required Icon icon,
    bool isTitle = false,
    String? title = "Upload File",
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: TColorsConst.neutral200),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                color: TColorsConst.neutral200,
              ),
              height: double.infinity,
              child: Row(
                children: [
                  icon,
                  if (isTitle) TSpaces.h8(),
                  if (isTitle)
                    Text(title!, style: TGoogleTextStyleConst.inter12Medium),
                ],
              ),
            ),
            TSpaces.h8(),
            Expanded(
              child: Text(
                filePath ?? 'No file selected',
                style: const TextStyle(
                  // color: filePath != null
                  //     ? TColorsConst.black
                  //     : TColorsConst.greyLuminosity,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static GestureDetector dateInput({
    required String? filePath,
    required VoidCallback onTap,
    required Icon icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: TColorsConst.greyLuminosity),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                color: TColorsConst.neutral200,
              ),
              height: double.infinity,
              child: icon,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                filePath ?? 'No date selected',
                style: TextStyle(
                  color: filePath != null
                      ? TColorsConst.black
                      : TColorsConst.greyLuminosity,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
