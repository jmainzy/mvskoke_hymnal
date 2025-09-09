import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDistruptive;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.isDistruptive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.marginLarge),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Dimens.marginLarge),
          Text(description ?? '', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: Dimens.marginLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDistruptive
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      confirmText ?? 'Confirm',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: isDistruptive ? Colors.white : null,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: Text(
                      cancelText ?? 'Cancel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
