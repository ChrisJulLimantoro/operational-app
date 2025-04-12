import 'package:flutter/material.dart';
import 'package:operational_app/theme/colors.dart';

Future<void> modalSheet({
  required BuildContext context,
  Widget? title,
  String? message,
  IconData icon = Icons.error_outline,
  Color primaryColor = AppColors.error,
  List<Widget>? inputs,
  List<Widget>? actions,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: primaryColor),
            ),
            const SizedBox(height: 15),

            // Flexible Title
            if (title != null)
              DefaultTextStyle(
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                child: title,
              ),

            // Message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],

            // Inputs
            if (inputs != null && inputs.isNotEmpty) ...[
              const SizedBox(height: 15),
              ...inputs,
            ],

            const SizedBox(height: 20),

            // Actions
            if (actions != null && actions.isNotEmpty) ...[
              ...actions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: action,
                  )),
            ],
          ],
        ),
      );
    },
  );
}

// example usage
// await modalSheet(
//   context: context,
//   primaryColor: AppColors.bluePrimary,
//   icon: Icons.question_mark,
//   title: Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: const [
//       Icon(Icons.warning_amber_rounded, color: AppColors.bluePrimary),
//       SizedBox(width: 8),
//       Text("Konfirmasi", style: AppTextStyles.labelBlue),
//     ],
//   ),
//   message: "Apakah yakin approve transaksi ${trans.code} ?",
//   inputs: [/* your inputs here */],
//   actions: [/* your action buttons here */],
// );