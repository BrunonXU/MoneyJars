import 'package:flutter/material.dart';
import '../../config/constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconXLarge,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              message,
              style: AppConstants.titleStyle.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                details!,
                style: AppConstants.captionStyle,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppConstants.buttonRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.cardColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLarge,
                    vertical: AppConstants.spacingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;
  final Widget? action;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: AppConstants.textSecondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconXLarge,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              message,
              style: AppConstants.titleStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                description!,
                style: AppConstants.captionStyle,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppConstants.spacingLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
} 