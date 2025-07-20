import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show PlatformException; // Needed for asset errors

// A common widget to display SVG icons from assets
class SvgIconWidget extends StatelessWidget {
  final String iconFileName;
  final double? width;
  final double? height;
  final Color? color;
  final double? fontSize; 
  static const String _basePath = 'assets/icons/';

  const SvgIconWidget({
    super.key,
    required this.iconFileName,
    this.width,
    this.height,
    this.color,
    this.fontSize, // Allow overriding font size for fallback
  });

  String _getIconPath(String fileName) {
    // Ensure the filename has a .svg extension if it's missing
    if (!fileName.toLowerCase().endsWith('.svg')) {
      return '$_basePath${fileName.toLowerCase().replaceAll(' ', '_')}.svg'; // Example: groceries_icon.svg
    }
    return '$_basePath$fileName';
  }

  // Generates a two-letter abbreviation from a string
  String _generateFallbackText(String text) {
    if (text.isEmpty) {
      return '??';
    }
    String cleanText = text.replaceAll(RegExp(r'\.(svg|png|jpg|jpeg|gif)$', caseSensitive: false), '');
    cleanText = cleanText.replaceAll('-', ' '); 

    final words = cleanText.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) {
      return text.substring(0, 1).toUpperCase();
    }
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String assetPath = _getIconPath(iconFileName);
    final String fallbackText = _generateFallbackText(iconFileName);

    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString(assetPath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return SvgPicture.string(
            snapshot.data!,
            width: width ?? 24,
            height: height ?? 24,
            fit: BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          );
        } else if (snapshot.hasError) {
          return Container(
            width: width ?? 24,
            height: height ?? 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              fallbackText,
              style: TextStyle(
                color: color != null ? color!.computeLuminance() > 0.5 ? Colors.black : Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: fontSize ?? (width ?? 24) * 0.5,
              ),
            ),
          );
        }

        return SizedBox(
          width: width ?? 24,
          height: height ?? 24,
          child: const Center(
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        );
      },
    );
  }
}