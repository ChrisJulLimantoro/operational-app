import 'package:flutter/material.dart';
import 'package:operational_app/theme/colors.dart';

class AppTextStyles {
  static const TextStyle headingWhite = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headingBlack = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: -0.5,
  );

  static const TextStyle headingBlue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textBlue,
    letterSpacing: -0.5,
  );

  static const TextStyle subheadingBlue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textBlue,
    letterSpacing: -0.5,
  );

  static const TextStyle labelPink = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.pinkPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle labelBlue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.bluePrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle labelBlueItalic = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textBlue,
    letterSpacing: -0.5,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyBlue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textBlue,
    letterSpacing: -0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
