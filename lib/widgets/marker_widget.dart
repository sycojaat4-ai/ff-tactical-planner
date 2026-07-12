import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';
import 'package:ff_tactical_planner/providers/marker_provider.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

/// A single marker rendered at its normalized position on the map.
/// Supports: drag to move, pinch-rotate/scale via GestureDetector's
/// scale gestures, tap to select, and a quick-action ring when selected.
class MarkerWidget extends StatefulWidget {
  final MarkerModel marker;
  final Size mapSize;

  const MarkerWidget({super.key, required this.marker, required this.mapSize});

  @override
  State<MarkerWidget> createState() => _MarkerWidgetState();
}

class _MarkerWidgetState extends State<MarkerWidget> {
  double _startRotation = 0;
  double _startScale = 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarkerProvider>();
    final m = widget.marker;
    final style = kMarkerStyles[m.type]!;
    final isSelected = provider.selectedId == m.id;

    final left = m.dx * widget.mapSize.width;
    final top = m.dy * widget.mapSize.height;
    final size = kMarkerBaseSize * m.scale;

    return Positioned(
      left: left - size / 2,
      top: top - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          provider.select(m.id);
        },
        onScaleStart: (details) {
          provider.select(m.id);
          _startRotation = m.rotation;
          _startScale = m.scale;
        },
        onScaleUpdate: (details) {
          if (m.locked) return;
          // Combined pan + pinch-rotate + pinch-scale, all normalized against
          // the map's own coordinate space so it stays accurate at any zoom.
          final newDx = m.dx + details.focalPointDelta.dx / widget.mapSize.width;
          final newDy = m.dy + details.focalPointDelta.dy / widget.mapSize.height;
          provider.moveMarker(m.id, newDx, newDy);

          if (details.pointerCount >= 2) {
            provider.rotateMarker(m.id, _startRotation + details.rotation);
            provider.resizeMarker(
              m.id,
              (_startScale * details.scale).clamp(kMinScale, kMaxScale),
            );
          }
        },
        child: Transform.rotate(
          angle: m.rotation,
          child: AnimatedScale(
            scale: isSelected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutBack,
            child: Container(
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : style.color,
                  width: isSelected ? 2.5 : 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: style.color.withOpacity(0.45),
                    blurRadius: isSelected ? 14 : 6,
                    spreadRadius: isSelected ? 1 : 0,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(style.icon, color: style.color, size: size * 0.55),
                  if (m.locked)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded,
                            size: 10, color: AppColors.gold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
