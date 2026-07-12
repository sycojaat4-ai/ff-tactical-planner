import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';
import 'package:ff_tactical_planner/models/strategy_model.dart';
import 'package:ff_tactical_planner/providers/drawing_provider.dart';
import 'package:ff_tactical_planner/providers/map_provider.dart';
import 'package:ff_tactical_planner/providers/marker_provider.dart';
import 'package:ff_tactical_planner/services/export_service.dart';
import 'package:ff_tactical_planner/services/storage_service.dart';
import 'package:ff_tactical_planner/utils/constants.dart';
import 'package:ff_tactical_planner/widgets/drawing_canvas.dart';
import 'package:ff_tactical_planner/widgets/map_toolbar.dart';
import 'package:ff_tactical_planner/widgets/marker_inspector.dart';
import 'package:ff_tactical_planner/widgets/marker_widget.dart';

/// The main tactical planning board for a single map.
/// Wraps the untouched official map image in an InteractiveViewer for
/// smooth pinch-zoom/pan, overlays markers + drawings in the *same*
/// coordinate space, and exposes the bottom toolbar for placing content.
///
/// If [strategyId] is provided, the board loads that saved strategy;
/// otherwise it starts fresh on [initialMap].
class MapScreen extends StatefulWidget {
  final GameMap initialMap;
  final String? strategyId;

  const MapScreen({super.key, required this.initialMap, this.strategyId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey _boardKey = GlobalKey(); // for export capture
  MarkerType? _armedMarker;
  bool _exporting = false;
  late String _currentStrategyId;
  late String _strategyName;

  @override
  void initState() {
    super.initState();
    final mapProvider = context.read<MapProvider>();
    mapProvider.setMap(widget.initialMap);

    if (widget.strategyId != null) {
      _loadStrategy(widget.strategyId!);
    } else {
      _currentStrategyId = '';
      _strategyName = 'Untitled Strategy';
    }
  }

  void _loadStrategy(String id) {
    final strategy = StorageService.getById(id);
    if (strategy == null) return;
    _currentStrategyId = strategy.id;
    _strategyName = strategy.name;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().setMap(strategy.map);
      context.read<MapProvider>().restoreTransform(strategy.transformMatrix);
      context.read<MarkerProvider>().loadMarkers(strategy.markers);
      context.read<DrawingProvider>().loadStrokes(strategy.drawings);
    });
  }

  Future<void> _saveStrategy() async {
    if (_currentStrategyId.isEmpty) {
      final created = await StorageService.create(
        name: _strategyName,
        map: context.read<MapProvider>().activeMap,
      );
      _currentStrategyId = created.id;
    }

    await StorageService.save(
      id: _currentStrategyId,
      markers: context.read<MarkerProvider>().markers,
      drawings: context.read<DrawingProvider>().strokes,
      transformMatrix: context.read<MapProvider>().captureTransform(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Strategy saved'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportPng() async {
    setState(() => _exporting = true);
    try {
      final bytes = await ExportService.captureUltraHD(_boardKey, pixelRatio: 4.0);
      if (bytes != null) {
        await ExportService.saveToGallery(bytes, name: _strategyName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exported Ultra HD PNG to gallery'),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _handleMapTap(TapUpDetails details, Size mapSize) {
    if (_armedMarker == null) {
      // Tapping empty space deselects the current marker.
      context.read<MarkerProvider>().select(null);
      return;
    }
    final dx = (details.localPosition.dx / mapSize.width).clamp(0.0, 1.0);
    final dy = (details.localPosition.dy / mapSize.height).clamp(0.0, 1.0);
    context.read<MarkerProvider>().addMarker(_armedMarker!, dx, dy);
    HapticFeedback.mediumImpact();
    // Keep marker armed for rapid multi-placement; tap toolbar icon again to disarm.
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final activeMap = mapProvider.activeMap;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(_strategyName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded),
            tooltip: 'Reset view',
            onPressed: mapProvider.resetView,
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save strategy',
            onPressed: _saveStrategy,
          ),
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                : const Icon(Icons.ios_share_rounded),
            tooltip: 'Export Ultra HD PNG',
            onPressed: _exporting ? null : _exportPng,
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- The board itself: map + markers + drawings, captured as one
          // RepaintBoundary for pixel-perfect export.
          RepaintBoundary(
            key: _boardKey,
            child: Container(
              color: AppColors.bg,
              child: InteractiveViewer(
                transformationController: mapProvider.transformController,
                minScale: 1.0,
                maxScale: 8.0, // maximum zoom without quality loss on 4K assets
                boundaryMargin: const EdgeInsets.all(400),
                panEnabled: true,
                scaleEnabled: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.asset(
                      activeMap.assetPath,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        return _MapStack(
                          imageChild: child,
                          onTapUp: _handleMapTap,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // --- Marker inspector (appears above toolbar when something is selected)
          const MarkerInspector(),

          // --- Bottom toolbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: MapToolbar(
                  armedMarker: _armedMarker,
                  onArmMarker: (type) {
                    setState(() {
                      _armedMarker = _armedMarker == type ? null : type;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Measures the actually-rendered image size (post BoxFit.contain) so
/// marker/drawing overlays align pixel-for-pixel with the map beneath them,
/// and wires up tap-to-place + renders the marker/drawing layers.
class _MapStack extends StatelessWidget {
  final Widget? imageChild;
  final void Function(TapUpDetails details, Size mapSize) onTapUp;

  const _MapStack({required this.imageChild, required this.onTapUp});

  @override
  Widget build(BuildContext context) {
    if (imageChild == null) {
      return const SizedBox(
        width: 400,
        height: 400,
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final box = context.findRenderObject() as RenderBox;
            onTapUp(details, box.size);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              imageChild!,
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    final size = Size(innerConstraints.maxWidth, innerConstraints.maxHeight);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        DrawingCanvas(mapSize: size),
                        Consumer<MarkerProvider>(
                          builder: (context, provider, _) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: provider.markers
                                  .map((m) => MarkerWidget(marker: m, mapSize: size))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
