import 'package:flutter/material.dart';

class CustomTextFormWidget extends StatelessWidget {
  final String label;
  final TextEditingController? textController;
  final String? initialValue;
  final Icon icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;

  const CustomTextFormWidget({
    super.key,
    required this.label,
    this.textController,
    this.initialValue,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onSaved,
    this.onChanged,
  }) : assert(
         textController == null || initialValue == null,
         'Provide either a controller or an initialValue, not both.',
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      initialValue: textController == null ? initialValue : null,
      onSaved: onSaved,
      onChanged: onChanged,
      decoration: itemFormFieldDecor(
        context,
        labelText: label,
        hintText: 'Enter $label',
        prefixIcon: icon.icon,
      ),
      obscureText: label.toLowerCase() == 'password',
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator ??
          (value) {
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
  BuildContext context, {
    String labelText = 'Item',
    String? hintText,
    IconData? prefixIcon,
}) {
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
