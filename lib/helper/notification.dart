import 'package:flutter/material.dart';
import 'package:operational_app/widget/notification_sheet.dart';

class NotificationHelper {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar({
    required String message,
    Color backgroundColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: duration,
        action:
            actionLabel != null && onActionPressed != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onActionPressed,
                )
                : null,
      ),
    );
  }

  static void showNotificationSheet({
    required BuildContext context,
    required String title,
    required String message,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    Color primaryColor = Colors.red,
    Color? secondaryColor,
    IconData icon = Icons.error_outline,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing by tapping outside
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => NotificationSheet(
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            secondaryButtonText: secondaryButtonText,
            onSecondaryPressed: onSecondaryPressed,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            icon: icon,
          ),
    );
  }

  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Yes",
    String cancelText = "No",
  }) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  static void showBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(context: context, builder: (context) => child);
  }
}
