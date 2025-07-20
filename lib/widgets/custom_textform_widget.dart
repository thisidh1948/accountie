import 'package:flutter/material.dart';

class CustomTextFormWidget extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final Icon icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;

  const CustomTextFormWidget({
    super.key,
    required this.label,
    required this.textController,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1, // Default to 1 line
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      decoration: itemFormFieldDecor(context, // <-- Pass BuildContext here
        labelText: label,
        hintText: 'Enter $label',
        prefixIcon: icon.icon,
      ),
      obscureText: label.toLowerCase() == 'password',
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator ??
          (value) {
            // Use provided validator or a default one
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
      maxLines: maxLines,
    );
  }
}

InputDecoration itemFormFieldDecor(
  BuildContext context, // <-- BuildContext still passed as a required parameter
  {
    String labelText = 'Item',
    String? hintText,
    IconData? prefixIcon,
    // You can add more customizable parameters here if needed
  }
) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2.0,
      ),
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
  );
}
