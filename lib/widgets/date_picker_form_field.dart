import 'package:flutter/material.dart';

class DatePickerFormField extends StatelessWidget {
  final DateTime? initialDate;
  final String label;
  final FormFieldSetter<DateTime> onSaved;
  final FormFieldValidator<DateTime>? validator;

  const DatePickerFormField({
    Key? key,
    this.initialDate,
    required this.label,
    required this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: initialDate,
      validator: validator,
      onSaved: onSaved,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.value ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  state.didChange(picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  state.value != null
                      ? '${state.value!.year}-${state.value!.month.toString().padLeft(2, '0')}-${state.value!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  style: TextStyle(
                    color: state.value != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.0),
                ),
              ),
          ],
        );
      },
    );
  }
}
