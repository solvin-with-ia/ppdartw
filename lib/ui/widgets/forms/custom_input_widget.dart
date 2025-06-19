import 'package:flutter/material.dart';

/// Widget base para inputs personalizados (preparado para integración futura de autocomplete, validaciones, etc)
class CustomInputWidget extends StatelessWidget {
  const CustomInputWidget({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.hintText,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}
