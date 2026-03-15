// lib/appcore/helpers/snackbar_helper.dart

import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
    );
  }

  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue,
    );
  }
}