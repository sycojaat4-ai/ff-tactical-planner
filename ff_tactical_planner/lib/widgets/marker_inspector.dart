import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/providers/marker_provider.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

/// A glassmorphic floating action strip that appears above the toolbar
/// whenever a marker is selected, giving quick access to rotate, resize,
/// lock, duplicate and delete - without cluttering the main toolbar.
class MarkerInspector extends StatelessWidget {
  const MarkerInspector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarkerProvider>();
    final marker = provider.selected;
    if (marker == null) return const SizedBox.shrink();

    final style = kMarkerStyles[marker.type]!;

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(style.icon, color: style.color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(style.label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
                _InspectorButton(
                  icon: Icons.rotate_right_rounded,
                  onTap: () => provider.rotateMarker(
                      marker.id, marker.rotation + 0.3927),
                ),
                _InspectorButton(
                  icon: Icons.add_circle_outline_rounded,
                  onTap: () => provider.resizeMarker(marker.id, marker.scale + 0.15),
                ),
                _InspectorButton(
                  icon: Icons.remove_circle_outline_rounded,
                  onTap: () => provider.resizeMarker(marker.id, marker.scale - 0.15),
                ),
                _InspectorButton(
                  icon: marker.locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                  active: marker.locked,
                  onTap: () => provider.toggleLock(marker.id),
                ),
                _InspectorButton(
                  icon: Icons.copy_rounded,
                  onTap: () => provider.duplicateMarker(marker.id),
                ),
                _InspectorButton(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.accentSecondary,
                  onTap: () => provider.deleteMarker(marker.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InspectorButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool active;

  const _InspectorButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
