import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectTagsDialog extends StatefulWidget {
  // Changed to StatefulWidget
  final List<String> initialSelectedTags;

  const SelectTagsDialog({super.key, required this.initialSelectedTags});

  @override
  State<SelectTagsDialog> createState() => _SelectTagsDialogState();
}

class _SelectTagsDialogState extends State<SelectTagsDialog> {
  late List<String> _selectedTags; // Now mutable state

  @override
  void initState() {
    super.initState();
    _selectedTags =
        List.from(widget.initialSelectedTags); // Initialize from initial value
  }

  // Placeholder for random color generation for tags
  Color _getRandomColor(String tag) {
    final int hash = tag.hashCode;
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = (hash & 0x0000FF) >> 0;
    return Color.fromARGB(255, r % 255, g % 255, b % 255);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tags').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return AlertDialog(
            title: const Text('Select Tags'),
            content: const Text('No tags found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop([]), // Corrected: wrapped in function
                child: const Text('Close'),
              ),
            ],
          );
        }

        final List<String> allTags = snapshot.data!.docs
            .map((doc) => doc.id)
            .toList(); // Assuming tag name is doc ID

        return AlertDialog(
          title: const Text('Select Tags'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allTags.map((tag) {
                final bool isSelected =
                    _selectedTags.contains(tag); // Use internal state
                return CheckboxListTile(
                  title: Text(tag),
                  secondary: CircleAvatar(
                    backgroundColor: _getRandomColor(tag),
                    radius: 12,
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      // Use setState to update UI
                      if (value == true) {
                        if (!_selectedTags.contains(tag)) {
                          _selectedTags.add(tag);
                        }
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(_selectedTags), // Corrected: wrapped in function
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop([]), // Corrected: wrapped in function
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
