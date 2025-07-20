import 'package:accountie/widgets/icon_selection_widget.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';

class IconPickerFormField extends FormField<String> {
  IconPickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    String super.initialValue = '',
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    InputDecoration decoration = const InputDecoration(),
    required BuildContext context, // Need context to show the dialog
  }) : super(
          builder: (FormFieldState<String> state) {
            // Get the current selected icon file name from the form field state
            final String? selectedIconFileName = state.value;

            // Function to show the icon selection dialog
            void showIconPicker() async {
              final String? pickedIcon = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return IconSelectionDialog(); // Show the icon selection dialog
                },
              );

              // If an icon was picked, update the form field's value
              if (pickedIcon != null) {
                state.didChange(
                    pickedIcon); // Update the internal form field state
              }
            }

            // Build the UI for the form field
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  // Use the FormFieldState's value directly for display
                  initialValue: selectedIconFileName,
                  decoration: decoration.copyWith(
                    labelText:
                        decoration.labelText ?? 'Select Icon', // Default label
                    suffixIcon: IconButton(
                      // Add a suffix icon button to open the picker
                      icon:
                          const Icon(Icons.folder_open), // Icon to open picker
                      onPressed:
                          showIconPicker, // Call the function to show the dialog
                    ),
                    prefixIcon: selectedIconFileName != null &&
                            selectedIconFileName.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(
                                8.0), // Add padding around the icon
                            child: SvgIconWidget(
                              // Display the selected icon as a prefix
                              iconFileName: selectedIconFileName,
                              width: 24, // Adjust size
                              height: 24,
                            ),
                          )
                        : null, // No prefix icon if no icon is selected
                  ),
                  readOnly: true, // Make the text field read-only
                  onTap:
                      showIconPicker, // Also allow tapping the field to open picker
                  // Disable the default onChanged as we manage the value with state.didChange
                  onChanged: (value) {},
                  // No validator here, validation is handled by the FormField validator
                ),
                // Display validation error message if any
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12.0),
                    ),
                  ),
              ],
            );
          },
        );
}
