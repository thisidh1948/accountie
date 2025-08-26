import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';

class CustTileWidget extends StatelessWidget {
  const CustTileWidget({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.index,
    this.color,
  });

  final String icon;
  final String label;
  final int? index;
  final String? color;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
    borderRadius: BorderRadius.circular(12),
    color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: SvgIconWidget(iconFileName: icon, width: 90, height: 90),
                ),
                const SizedBox(height: 2),
                Flexible(
                  flex: 1,
                  child: Text(label, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 4),
                if (color != null &&
                    color!.isNotEmpty &&
                    index != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Color',
                          style: TextStyle(
                              color: color!.isNotEmpty
                                  ? Color(int.parse(
                                      color ?? 0xFFFFFFFF.toRadixString(16)))
                                  : Colors.blueGrey),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          index.toString(),
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
