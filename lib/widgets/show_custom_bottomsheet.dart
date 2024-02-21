import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';

import 'bottomsheet_header.dart';

Future<void> showCustomBottomSheet(
  BuildContext context, {
  required Widget child,
  required Color backgroundColor,
  Color dividerColor = Colors.grey,
  required VoidCallback onClose,
}) async {
  await showModalBottomSheet(
    context: context,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    ),
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: context.viewportHeight * 0.9,
        ),
        child: CustomBottomSheet(
          dividerColor: dividerColor,
          onClose: onClose,
          child: child,
        ),
      );
    },
  );
}

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final Color dividerColor;
  final VoidCallback onClose;
  const CustomBottomSheet({
    super.key,
    required this.child,
    required this.dividerColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(
            dividerColor: dividerColor,
            onClose: onClose,
          ),
          child,
          const SizedBox(height: 16)
        ],
      ),
    );
  }
}
