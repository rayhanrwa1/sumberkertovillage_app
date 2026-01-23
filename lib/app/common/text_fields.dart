import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sumberkerto_smart_village/app/common/spaces.dart';
import 'package:sumberkerto_smart_village/app/common/style/input_decoration_styles.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TTextFields {
  TTextFields._();

  static Widget buildStandard({
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    Function? onTapOutside,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
    Color? suffixIconColor,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    TextCapitalization? textCapitalization,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      style: TGoogleTextStyleConst.inter12Regular,
      cursorColor: TColorsConst.neutral500,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: TColorsConst.neutral300,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: TColorsConst.neutral300,
            width: 0.5,
          ),
        ),
        hintText: hintText,
        hintStyle: TGoogleTextStyleConst.inter12Regular.copyWith(
          color: TColorsConst.neutral500,
        ),
        suffixIconColor: suffixIconColor ?? TColorsConst.neutral200,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.h),
        fillColor: TColorsConst.neutral50,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: TColorsConst.blue500, width: 1.0),
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }

  static Widget buildDatePicker({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    bool isLabelVisible = true,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? borderRadius,
    double? borderWidth,
    double? focusedBorderWidth,
    EdgeInsets? contentPadding,
    bool enabled = true,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd/MM/yyyy',
    Function(DateTime)? onDateSelected,
    bool floatingLabelBehavior = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLabelVisible
            ? Text(
                label,
                style: labelStyle ?? TGoogleTextStyleConst.inter14SemiBold,
              )
            : const SizedBox(),
        TSpaces.v8(),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          validator: validator,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          style: inputStyle ?? TGoogleTextStyleConst.inter12Regular,
          decoration: TInputDecorationStyles.outlineInputBorder(label).copyWith(
            hintText: hintText,
            filled: true,
            fillColor:
                fillColor ??
                (floatingLabelBehavior
                    ? TColorsConst.neutral50
                    : Colors.transparent),
            floatingLabelBehavior: floatingLabelBehavior
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.never,
            suffixIcon: Icon(
              Icons.calendar_today,
              color: TColorsConst.neutral400,
              size: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: borderColor ?? TColorsConst.neutral200,
                width: borderWidth ?? 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: borderColor ?? TColorsConst.neutral200,
                width: borderWidth ?? 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: focusedBorderColor ?? TColorsConst.blue500,
                width: focusedBorderWidth ?? 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? TColorsConst.red500,
                width: borderWidth ?? 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? TColorsConst.red500,
                width: focusedBorderWidth ?? 1.0,
              ),
            ),
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          autovalidateMode: autovalidateMode,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: TColorsConst.blue500,
                      onPrimary: Colors.white,
                      onSurface: TColorsConst.neutral600,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              controller.text = DateFormat(dateFormat).format(picked);
              if (onDateSelected != null) {
                onDateSelected(picked);
              }
            }
          },
        ),
      ],
    );
  }

  static Widget buildDropDown<T>({
    required BuildContext context,
    required String label,
    required String hintText,
    required List<T> items,
    required String Function(T) itemLabel,
    T? selectedValue,
    String? Function(T?)? validator,
    Function(T?)? onChanged,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    Color? fillColor,
    bool isLabelVisible = true,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? borderRadius,
    double? borderWidth,
    double? focusedBorderWidth,
    EdgeInsets? contentPadding,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLabelVisible
            ? Text(
                label,
                style: labelStyle ?? TGoogleTextStyleConst.inter14SemiBold,
              )
            : const SizedBox(),
        TSpaces.v8(),
        DropdownButtonFormField<T>(
          initialValue: selectedValue,
          validator: validator,
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style:
                    inputStyle ??
                    TGoogleTextStyleConst.inter12SemiBold.copyWith(
                      color: TColorsConst.neutral600,
                    ),
              ),
            );
          }).toList(),
          decoration: TInputDecorationStyles.outlineInputBorder(label).copyWith(
            hintText: hintText,
            filled: true,
            fillColor: fillColor ?? TColorsConst.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: borderColor ?? TColorsConst.neutral200,
                width: borderWidth ?? 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: borderColor ?? TColorsConst.neutral200,
                width: borderWidth ?? 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: focusedBorderColor ?? TColorsConst.blue500,
                width: focusedBorderWidth ?? 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? TColorsConst.red500,
                width: borderWidth ?? 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? TColorsConst.red500,
                width: focusedBorderWidth ?? 2,
              ),
            ),
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: TColorsConst.neutral400),
          dropdownColor: fillColor ?? TColorsConst.neutral50,
        ),
      ],
    );
  }
}
