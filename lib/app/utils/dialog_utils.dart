import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sumberkerto_smart_village/app/common/buttons.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

enum AppDialogType { info, success, warning, error }

class AppDialog {
  /// CONFIRM dialog (return true jika Confirm, false jika Cancel/backdrop)
  static Future<bool> confirm({
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    AppDialogType type = AppDialogType.warning,
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await Get.dialog<bool>(
      _BaseDialog(
        type: type,
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        showCancel: true,
        onCancel: () {
          onCancel?.call();
          Get.back(result: false);
        },
        onConfirm: () {
          onConfirm?.call();
          Get.back(result: true);
        },
      ),
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }

  /// ALERT dialog (1 tombol saja, return void)
  static Future<void> alert({
    required String title,
    required String message,
    String buttonText = 'OK',
    AppDialogType type = AppDialogType.info,
    bool barrierDismissible = true,
    VoidCallback? onOk,
  }) async {
    await Get.dialog<void>(
      _BaseDialog(
        type: type,
        title: title,
        message: message,
        cancelText: '',
        confirmText: buttonText,
        showCancel: false,
        onCancel: null,
        onConfirm: () {
          onOk?.call();
          Get.back();
        },
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Biar enak panggil cepat
  static Future<void> success({
    String title = 'Success',
    required String message,
    String buttonText = 'OK',
  }) => alert(
    title: title,
    message: message,
    buttonText: buttonText,
    type: AppDialogType.success,
  );

  static Future<void> error({
    String title = 'Error',
    required String message,
    String buttonText = 'OK',
  }) => alert(
    title: title,
    message: message,
    buttonText: buttonText,
    type: AppDialogType.error,
  );

  static Future<void> info({
    String title = 'Info',
    required String message,
    String buttonText = 'OK',
  }) => alert(
    title: title,
    message: message,
    buttonText: buttonText,
    type: AppDialogType.info,
  );
}

class _BaseDialog extends StatelessWidget {
  final AppDialogType type;
  final String title;
  final String message;

  final String cancelText;
  final String confirmText;

  final bool showCancel;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;

  const _BaseDialog({
    required this.type,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.showCancel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = Get.width >= 500 ? 420.w : double.infinity;

    final iconColor = _iconColor(type);
    final iconBg = _iconBg(type);
    final icon = _icon(type);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
            decoration: BoxDecoration(
              color: TColorsConst.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: TColorsConst.black.withAlpha(20),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon bubble
                Container(
                  width: 66.w,
                  height: 66.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: Center(
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: iconColor, width: 2.w),
                      ),
                      child: Icon(icon, size: 18.sp, color: iconColor),
                    ),
                  ),
                ),

                TSpaces.v12(),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                    fontSize: 16.sp,
                    color: TColorsConst.neutral900,
                  ),
                ),

                TSpaces.v8(),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TGoogleTextStyleConst.inter12Regular.copyWith(
                    color: TColorsConst.neutral500,
                    height: 1.35,
                  ),
                ),

                TSpaces.v16(),

                Row(
                  children: [
                    if (showCancel) ...[
                      Expanded(
                        child: SizedBox(
                          height: 40.h,
                          child: TButtons.outline(
                            onPressed: () {
                              Get.back();
                            },
                            text: cancelText,
                            textColor: TColorsConst.red500,
                            borderColor: TColorsConst.red500,
                          ),
                        ),
                      ),
                      TSpaces.h12(),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: TButtons.primary(
                          onPressed: onConfirm,
                          text: confirmText,
                          backgroundColor: _confirmBg(type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- style mapping ----

  Color _iconColor(AppDialogType t) {
    switch (t) {
      case AppDialogType.success:
        return TColorsConst.green500;
      case AppDialogType.error:
        return TColorsConst.red500;
      case AppDialogType.info:
        return TColorsConst.blue500; // pastikan ada di const kamu
      case AppDialogType.warning:
        return TColorsConst.red500;
    }
  }

  Color _iconBg(AppDialogType t) {
    switch (t) {
      case AppDialogType.success:
        return TColorsConst.green100;
      case AppDialogType.error:
        return TColorsConst.red50;
      case AppDialogType.info:
        return TColorsConst.blue50; // pastikan ada di const kamu
      case AppDialogType.warning:
        return TColorsConst.red50;
    }
  }

  IconData _icon(AppDialogType t) {
    switch (t) {
      case AppDialogType.success:
        return Icons.check_rounded;
      case AppDialogType.error:
        return Icons.close_rounded;
      case AppDialogType.info:
        return Icons.info_outline_rounded;
      case AppDialogType.warning:
        return Icons.priority_high_rounded;
    }
  }

  // cancel outline merah untuk warning/error, netral untuk lainnya

  // TODO: kalau mau dipakein lagi, uncomment ini
  // Color _cancelBorder(AppDialogType t) {
  //   if (t == AppDialogType.warning || t == AppDialogType.error) {
  //     return TColorsConst.red500;
  //   }
  //   return TColorsConst.neutral200;
  // }

  // Color _cancelText(AppDialogType t) {
  //   if (t == AppDialogType.warning || t == AppDialogType.error) {
  //     return TColorsConst.red500;
  //   }
  //   return TColorsConst.neutral900;
  // }

  // confirm button biru (seperti screenshot) untuk warning/error,
  // hijau untuk success, biru untuk info
  Color _confirmBg(AppDialogType t) {
    switch (t) {
      case AppDialogType.success:
        return TColorsConst.green500;
      case AppDialogType.info:
        return TColorsConst.blue500;
      case AppDialogType.warning:
      case AppDialogType.error:
        return TColorsConst.blue500;
    }
  }
}
