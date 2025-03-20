import 'package:flutter/material.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';

class FormSheet extends StatelessWidget {
  final String title;
  final Widget form;
  final Function()? onOkPressed;
  final VoidCallback? onCancelPressed;
  final Color primaryColor;
  final Color? secondaryColor;
  final IconData icon;

  const FormSheet({
    super.key,
    required this.title,
    required this.form,
    required this.onOkPressed,
    this.onCancelPressed,
    this.primaryColor = AppColors.bluePrimary,
    this.secondaryColor,
    this.icon = Icons.edit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at the top
          // Container(
          //   padding: const EdgeInsets.all(15),
          //   decoration: BoxDecoration(
          //     color: primaryColor.withAlpha(20),
          //     shape: BoxShape.circle,
          //   ),
          //   child: Icon(icon, size: 50, color: primaryColor),
          // ),
          const SizedBox(height: 15),

          // Title
          Text(
            title,
            style: AppTextStyles.headingBlue,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          // Form Content
          form,

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor ?? AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: onCancelPressed ?? () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // OK Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: onOkPressed,
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
