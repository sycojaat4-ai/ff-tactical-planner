import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

/// Captures the tactical board (map + markers + drawings, all inside a
/// RepaintBoundary) and exports it as a lossless, Ultra HD PNG.
///
/// `pixelRatio` is deliberately high (up to 4.0, i.e. true 4K-class output
/// relative to the board's logical size) and PNG encoding is lossless by
/// format, so there is zero quality loss versus what's on screen.
class ExportService {
  /// Renders the given [boundaryKey]'s RepaintBoundary to PNG bytes.
  /// Returns null if the boundary isn't currently attached/painted.
  static Future<Uint8List?> captureUltraHD(
    GlobalKey boundaryKey, {
    double pixelRatio = 4.0,
  }) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    // Wait a frame to guarantee the latest marker/drawing state is painted.
    await Future.delayed(const Duration(milliseconds: 20));

    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  /// Saves exported PNG bytes to the device gallery/photos app.
  static Future<void> saveToGallery(Uint8List bytes, {String? name}) async {
    await Gal.putImageBytes(bytes, name: name ?? 'ff_strategy_${DateTime.now().millisecondsSinceEpoch}');
  }
}
