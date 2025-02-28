import 'package:flutter/material.dart';
import 'package:operational_app/theme/colors.dart';

class NotificationSheet extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final Color primaryColor;
  final Color? secondaryColor;
  final IconData icon;

  const NotificationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.primaryColor = AppColors.error,
    this.secondaryColor,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at the top
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: primaryColor),
          ),

          const SizedBox(height: 15),

          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Buttons
          Column(
            children: [
              // Primary Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onPrimaryPressed();
                  },
                  child: Text(
                    primaryButtonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              if (secondaryButtonText != null) ...[
                const SizedBox(height: 10),
                // Secondary Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor ?? Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed:
                        onSecondaryPressed ?? () => Navigator.pop(context),
                    child: Text(
                      secondaryButtonText!,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
