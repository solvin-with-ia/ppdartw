import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    required this.label,
    required this.onTap,
    this.enabled = true,
    super.key,
  });
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(160, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
        foregroundColor: enabled
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).disabledColor,
        elevation: enabled ? 3 : 0,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: enabled
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}
