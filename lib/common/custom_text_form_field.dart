import 'package:flutter/material.dart';
import 'package:tabkha_app/constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? iconSize;
  final Color? fillColor;
  final Color? prefixIconColor;
  final TextStyle? hintStyle;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onEditingComplete,
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
    this.fillColor,
    this.hintStyle,
    this.prefixIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: width ?? size.width * 0.85,
      height: height ?? size.height * 0.08,
      child: TextFormField(
        style: TextStyle(
          fontSize: fontSize ?? size.width * 0.04,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
        cursorHeight: size.height * 0.03,
        cursorColor: AppColors.greenBackground,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          fillColor: fillColor ?? AppColors.loginTextFieldLightGrey,
          prefixIcon: Icon(
            prefixIcon,
            size: iconSize ?? size.width * 0.05,
            color: prefixIconColor ?? AppColors.white,
          ),
          filled: true,
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: AppColors.greyColor,
                fontSize: fontSize ?? size.width * 0.04,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
          errorStyle: TextStyle(
            color: AppColors.errorColor,
            fontSize: size.width * 0.02,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}
