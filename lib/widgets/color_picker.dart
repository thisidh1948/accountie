import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatefulWidget {
  final String? initialColorHex;
  final ValueChanged<String> onColorChanged;
  final String label;
  const ColorPickerField({
    Key? key,
    this.initialColorHex,
    required this.onColorChanged,
    this.label = 'Color:',
  }) : super(key: key);

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  String? _selectedColorHex;

  @override
  void initState() {
    super.initState();
    _selectedColorHex = widget.initialColorHex;
  }

  Color get selectedColor {
    if (_selectedColorHex != null) {
      final hex = _selectedColorHex!;
      return Color(int.parse(hex.startsWith('0x') ? hex : '0xFF$hex'));
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            final pickedColor = await showDialog<Color>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pick a color'),
                content: SingleChildScrollView(
                  child: MaterialPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      Navigator.of(context).pop(color);
                    },
                    enableLabel: true,
                  ),
                ),
              ),
            );
            if (pickedColor != null) {
              setState(() {
                _selectedColorHex = '0x${pickedColor.value.toRadixString(16).padLeft(8, '0')}';
              });
              widget.onColorChanged(_selectedColorHex!);
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
          ),
        ),
      ],
    );
  }
}