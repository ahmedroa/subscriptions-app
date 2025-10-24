// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subscriptions_app/core/theme/color.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final String? initialValue;
  final bool? isObscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final int? maxLength;
  final Function(String)? onChanged;
  final void Function()? onTap;
  final String? helperText;
  final String? prefixText;
  // final String? title;

  final List<TextInputFormatter>? inputFormatters;
  final Widget? counter;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? readOnly;
  final FocusNode? focusNode;
  final bool? enabled;
  final TextInputAction? textInputAction;

  const AppTextFormField({
    super.key,
    this.keyboardType,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backgroundColor,
    this.enabled,
    this.controller,
    required this.validator,
    this.fillColor,
    this.maxLength,
    this.onChanged,
    this.helperText,
    this.prefixText,
    this.borderRadius,
    this.prefixIcon,
    // this.title,
    this.inputFormatters,
    this.onTap,
    this.counter,
    this.maxLines,
    this.textAlign,
    this.readOnly,
    this.focusNode,
    this.initialValue,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (title != null && title!.isNotEmpty)
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction ?? TextInputAction.next,
          textAlign: textAlign ?? TextAlign.start,
          keyboardType: keyboardType,
          controller: controller,

          style: TextStyle(fontSize: 14, color: Colors.white),
          // style: TextStyles(context).font14GrayRegular.copyWith(color: Theme.of(context).colorScheme.secondary),
          onChanged: onChanged,

          maxLength: maxLength,
          inputFormatters: inputFormatters,
          maxLines: maxLines ?? 1,
          onTap: onTap,
          obscureText: isObscureText ?? false,
          validator: validator,
          readOnly: readOnly ?? false,
          decoration: InputDecoration(
            helperText: helperText,
            suffixText: prefixText,
            counter: counter,
            isDense: true,
            contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            focusedBorder:
                focusedBorder ??
                OutlineInputBorder(
                  borderSide: const BorderSide(color: ColorsManager.kPrimaryColor, width: .1),
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
            enabledBorder:
                enabledBorder ??
                OutlineInputBorder(
                  borderSide: BorderSide(color: ColorsManager.containerColorDark, width: .1),
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: .1),
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: .1),
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),

            hintText: hintText,
            hintStyle: hintStyle ?? const TextStyle(color: Colors.white70),
            helperStyle: const TextStyle(color: Colors.white),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            // fillColor: fillColor ?? ColorsManager.textFormField,
            fillColor: ColorsManager.containerColorDark,
            labelStyle: const TextStyle(color: Colors.white),

            filled: true,
          ),
        ),
      ],
    );
  }
}
