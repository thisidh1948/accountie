import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for rootBundle
import 'dart:convert'; // Required for json decoding (if needed, though not directly for SVG list)


class IconSelectionDialog extends StatelessWidget {
  // Base path to your electronics icons - must match pubspec.yaml
  static const String _basePath = 'assets/icons/';

  const IconSelectionDialog({super.key});

  Future<List<String>> _loadAssetList(BuildContext context) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      return manifestMap.keys
          .where(
              (String key) => key.startsWith(_basePath) && key.endsWith('.svg'))
          .map((String key) =>
              key.replaceFirst(_basePath, '')) // Get just the file name
          .toList();
    } catch (e) {
      print('Error loading asset manifest: $e');
      return []; // Return empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select an Icon'),
      content: FutureBuilder<List<String>>(
        future: _loadAssetList(context), // Load the list of icon file names
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading icons: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No icons found in assets/icons/electronics/'));
          } else {
            // Display the icons in a GridView
            final List<String> iconFileNames = snapshot.data!;

            return SizedBox(
              // Wrap GridView in Container to constrain its size in the dialog
              width: double.maxFinite, // Allow it to take max width in dialog
              height:
                  300, // Give it a fixed height or use constraints from parent
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Adjust number of columns as needed
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: iconFileNames.length,
                itemBuilder: (context, index) {
                  final String iconFileName = iconFileNames[index];
                  return InkWell(
                    // Make the icon tappable
                    onTap: () {
                      // Return the selected icon file name when tapped
                      Navigator.of(context).pop(iconFileName);
                    },
                    child: Card(
                      // Wrap in Card for a visual boundary
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Center(
                        // Use the SvgIconWidget to display the icon
                        child: SvgIconWidget(
                          iconFileName: iconFileName,
                          width: 40, // Adjust size for display in the grid
                          height: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without selecting
          },
        ),
      ],
    );
  }
}
