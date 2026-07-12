import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';
import 'package:ff_tactical_planner/models/drawing_model.dart';
import 'package:ff_tactical_planner/providers/drawing_provider.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

/// The main bottom toolbar. Glassmorphic, dark, rounded - houses:
///  - a "Place" button that expands into every marker category
///  - a "Draw" button that expands into shape/freehand tools + color picker
/// Selecting a marker type arms `onArmMarker`; the map screen listens for
/// the next tap to actually place it.
class MapToolbar extends StatefulWidget {
  final void Function(MarkerType type) onArmMarker;
  final MarkerType? armedMarker;

  const MapToolbar({
    super.key,
    required this.onArmMarker,
    required this.armedMarker,
  });

  @override
  State<MapToolbar> createState() => _MapToolbarState();
}

enum _Panel { none, markers, draw }

class _MapToolbarState extends State<MapToolbar> {
  _Panel _panel = _Panel.none;

  void _togglePanel(_Panel p) {
    HapticFeedback.lightImpact();
    setState(() => _panel = _panel == p ? _Panel.none : p);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: _panel == _Panel.markers
              ? _MarkerPanel(
                  armed: widget.armedMarker,
                  onSelect: (t) {
                    widget.onArmMarker(t);
                  },
                )
              : _panel == _Panel.draw
                  ? const _DrawPanel()
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        _MainBar(
          activePanel: _panel,
          onTapMarkers: () => _togglePanel(_Panel.markers),
          onTapDraw: () => _togglePanel(_Panel.draw),
        ),
      ],
    );
  }
}

/// The always-visible bottom bar row with the two expandable buttons plus
/// undo/redo/clear shortcuts for drawing.
class _MainBar extends StatelessWidget {
  final _Panel activePanel;
  final VoidCallback onTapMarkers;
  final VoidCallback onTapDraw;

  const _MainBar({
    required this.activePanel,
    required this.onTapMarkers,
    required this.onTapDraw,
  });

  @override
  Widget build(BuildContext context) {
    final drawing = context.watch<DrawingProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolButton(
                icon: Icons.add_location_alt_rounded,
                label: 'Markers',
                active: activePanel == _Panel.markers,
                onTap: onTapMarkers,
              ),
              const SizedBox(width: 6),
              _ToolButton(
                icon: Icons.edit_rounded,
                label: 'Draw',
                active: activePanel == _Panel.draw || drawing.drawingEnabled,
                onTap: onTapDraw,
              ),
              const SizedBox(width: 6),
              _IconOnlyButton(
                icon: Icons.undo_rounded,
                onTap: drawing.undo,
              ),
              _IconOnlyButton(
                icon: Icons.redo_rounded,
                onTap: drawing.redo,
              ),
              _IconOnlyButton(
                icon: Icons.layers_clear_rounded,
                onTap: drawing.clearAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent.withOpacity(0.18) : Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? AppColors.accent : AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.accent : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconOnlyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Expandable grid of every marker category, grouped into
/// Objects / Roles / Tactics for scannability.
class _MarkerPanel extends StatelessWidget {
  final MarkerType? armed;
  final void Function(MarkerType) onSelect;

  const _MarkerPanel({required this.armed, required this.onSelect});

  static const _objects = [
    MarkerType.vendingMachine,
    MarkerType.coinMachine,
    MarkerType.launchPad,
    MarkerType.arsenal,
    MarkerType.zipline,
  ];
  static const _roles = [
    MarkerType.rusher1,
    MarkerType.rusher2,
    MarkerType.assaulter,
    MarkerType.sniper,
  ];
  static const _tactics = [
    MarkerType.waypoint,
    MarkerType.enemy,
    MarkerType.safePosition,
    MarkerType.danger,
    MarkerType.vehicle,
    MarkerType.camp,
    MarkerType.loot,
    MarkerType.rotationArrow,
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Map Objects'),
                _chipRow(_objects),
                const SizedBox(height: 10),
                _sectionLabel('Player Roles'),
                _chipRow(_roles),
                const SizedBox(height: 10),
                _sectionLabel('Tactics'),
                _chipRow(_tactics),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6)),
      );

  Widget _chipRow(List<MarkerType> types) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((t) {
        final style = kMarkerStyles[t]!;
        final isArmed = armed == t;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(t);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isArmed ? style.color.withOpacity(0.25) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isArmed ? style.color : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 16, color: style.color),
                const SizedBox(width: 6),
                Text(style.label,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Expandable panel for drawing tool + color + width selection.
class _DrawPanel extends StatelessWidget {
  const _DrawPanel();

  @override
  Widget build(BuildContext context) {
    final drawing = context.watch<DrawingProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      drawing.drawingEnabled ? 'Drawing: ON' : 'Drawing: OFF',
                      style: TextStyle(
                        color: drawing.drawingEnabled ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: drawing.drawingEnabled,
                    activeColor: AppColors.accent,
                    onChanged: (v) => drawing.toggleDrawingMode(v),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DrawTool.values.map((tool) {
                  final active = drawing.activeTool == tool;
                  return GestureDetector(
                    onTap: () => drawing.setTool(tool),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.accent.withOpacity(0.22)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: active ? AppColors.accent : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_toolIcon(tool), size: 16,
                              color: active ? AppColors.accent : AppColors.textPrimary),
                          const SizedBox(width: 6),
                          Text(_toolLabel(tool),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: kDrawColors.map((c) {
                  final active = drawing.activeColor.value == c.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => drawing.setColor(c),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.line_weight_rounded, size: 16, color: AppColors.textSecondary),
                  Expanded(
                    child: Slider(
                      value: drawing.activeWidth,
                      min: 2,
                      max: 12,
                      activeColor: AppColors.accent,
                      onChanged: drawing.setWidth,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _toolIcon(DrawTool tool) {
    switch (tool) {
      case DrawTool.freehand:
        return Icons.brush_rounded;
      case DrawTool.line:
        return Icons.horizontal_rule_rounded;
      case DrawTool.arrow:
        return Icons.north_east_rounded;
      case DrawTool.circle:
        return Icons.circle_outlined;
      case DrawTool.rectangle:
        return Icons.crop_square_rounded;
    }
  }

  String _toolLabel(DrawTool tool) {
    switch (tool) {
      case DrawTool.freehand:
        return 'Freehand';
      case DrawTool.line:
        return 'Line';
      case DrawTool.arrow:
        return 'Arrow';
      case DrawTool.circle:
        return 'Circle';
      case DrawTool.rectangle:
        return 'Rectangle';
    }
  }
}
