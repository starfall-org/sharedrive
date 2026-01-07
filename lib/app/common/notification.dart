import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class SnackBarConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

Map<SnackBarType, SnackBarConfig> _snackBarConfigs = {
  SnackBarType.success: const SnackBarConfig(
    icon: Icons.check_circle,
    backgroundColor: Color(0xFF4CAF50),
    iconColor: Colors.white,
  ),
  SnackBarType.error: const SnackBarConfig(
    icon: Icons.error,
    backgroundColor: Color(0xFFF44336),
    iconColor: Colors.white,
  ),
  SnackBarType.warning: const SnackBarConfig(
    icon: Icons.warning,
    backgroundColor: Color(0xFFFF9800),
    iconColor: Colors.white,
  ),
  SnackBarType.info: const SnackBarConfig(
    icon: Icons.info,
    backgroundColor: Color(0xFF2196F3),
    iconColor: Colors.white,
  ),
};

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final config = _snackBarConfigs[type]!;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            config.icon,
            color: config.iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: config.backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 6,
    ),
  );
}

void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  showSnackBar(
    context,
    message,
    type: SnackBarType.success,
    duration: duration,
    action: action,
  );
}

void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  showSnackBar(
    context,
    message,
    type: SnackBarType.error,
    duration: duration,
    action: action,
  );
}

void showWarningSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  showSnackBar(
    context,
    message,
    type: SnackBarType.warning,
    duration: duration,
    action: action,
  );
}

void showProgressSnackBar(
  BuildContext context,
  String message,
  double progress,
) {
  final percentage = (progress * 100).toInt();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: progress,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2196F3),
      duration: const Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 6,
    ),
  );
}
