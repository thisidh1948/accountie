import 'package:flutter/material.dart';

class CreditDebitSwitch extends StatelessWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final String label;

  const CreditDebitSwitch({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // The outer Row now needs to distribute space among its children
      // because it's itself constrained by a parent Expanded.
      // mainAxisAlignment: MainAxisAlignment.start is fine, but we need flexible children.
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Often better for such elements
      children: [
        // Display the label only if it's not empty
        if (label.isNotEmpty) ...[
          // Give the label a Flexible wrapper.
          // This allows it to shrink and truncate if space is tight.
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis, // Ensures label text truncates
              maxLines: 1, // Ensures it stays on one line
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing slightly to save space
        ],
        // The Container holding the switch and "Debit"/"Credit" texts
        // also needs to be flexible so it takes the remaining space.
        // Use Expanded to ensure it takes all remaining space.
        Expanded( // <--- NEW: Wrap the Container in Expanded
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: Row(
              // This inner Row handles the distribution of "Debit", Switch, "Credit"
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisSize: MainAxisSize.max is generally correct here
              // because it's inside an Expanded.
              // We removed mainAxisSize.min because it was fighting with its parent Expanded.
              children: [
                Flexible( // <--- Make "Debit" text flexible
                  child: Text(
                    'Debit',
                    style: TextStyle(
                      color: initialValue ? Colors.grey : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // The Switch has a fixed intrinsic width, it typically doesn't need Flexible/Expanded
                Switch(
                  value: initialValue,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.shade200,
                  onChanged: onChanged,
                ),
                Flexible( // <--- Make "Credit" text flexible
                  child: Text(
                    'Credit',
                    style: TextStyle(
                      color: initialValue ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}