import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SnackbarUtils {
  static void showModernSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(message, isError: isError));
  }

  /// Safe variant for use after async gaps — accept ScaffoldMessengerState captured
  /// BEFORE the await so we never access BuildContext across an async boundary.
  static void showModernSnackBarOnMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(_buildSnackBar(message, isError: isError));
  }

  static SnackBar _buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? LucideIcons.xCircle : LucideIcons.checkCircle2,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(24),
      elevation: 8,
      duration: const Duration(seconds: 3),
    );
  }
}
