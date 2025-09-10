import 'package:flutter/material.dart';

class BottomSheetHeader extends StatelessWidget {
  final Color dividerColor;
  final VoidCallback onClose;
  const BottomSheetHeader({
    super.key,
    required this.dividerColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            height: 6,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(
                  right: 16,
                  left: 16,
                  bottom: 12,
                  top: 3.25,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Divider(
          height: 0,
          thickness: 1,
          color: dividerColor.withOpacity(0.2),
        ),
      ],
    );
  }
}
