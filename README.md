# FF Tactical Planner

A dark-themed, glassmorphic Flutter app for Free Fire esports teams to plan
strategies directly on top of the **official, untouched** game maps.

---

## ✅ What's included

- **5 official maps**, bundled at full original resolution, byte-for-byte
  unmodified (`assets/maps/`): Bermuda, Kalahari, NeXTerra, Purgatory, Solara.
- Smooth pinch-zoom / pan (`InteractiveViewer`, up to 8x zoom, no quality loss
  since maps are rendered from their native ultra-HD source files).
- **17 marker types** across 3 categories: Map Objects (Vending Machine, Coin
  Machine, Launch Pad, Arsenal, Zipline), Player Roles (Rusher 1/2, Assaulter,
  Sniper — each color-coded), and Tactics (Waypoint, Enemy, Safe Position,
  Danger, Vehicle, Camp, Loot, Rotation Arrow).
- Full marker manipulation: **move** (drag), **rotate** + **resize** (pinch
  gesture), **duplicate**, **delete**, **lock position**.
- Drawing tools: **Freehand, Line, Arrow, Circle, Rectangle**, 6-color
  palette, adjustable stroke width, **Undo/Redo**, **Clear All**.
- **Save / Load / Rename / Delete strategies** (Hive local database) — every
  save captures the map, every marker (position, rotation, scale, lock
  state), every drawing stroke, and the exact zoom/pan transform, so
  reopening a strategy restores the board pixel-for-pixel.
- **Ultra HD PNG export** (up to 4x pixel ratio, lossless PNG encoding) saved
  straight to the device gallery.
- Modern esports dark UI: glassmorphism panels, rounded corners, smooth
  `AnimatedSize` / `AnimatedScale` transitions throughout.

---

## 🏗 Architecture

```
lib/
  models/          # MarkerModel, DrawingStroke, StrategyModel (+ Hive adapters)
  providers/        # MapProvider, MarkerProvider, DrawingProvider (ChangeNotifier)
  services/         # StorageService (Hive), ExportService (RepaintBoundary -> PNG)
  screens/          # HomeScreen (map picker + saved strategies), MapScreen (board)
  widgets/          # MapToolbar, MarkerWidget, MarkerInspector, DrawingCanvas
  utils/            # constants.dart — theme tokens, marker icon/color map
assets/maps/         # The 5 official map images, untouched
android/             # Manifest with gallery-write permission for export
```

**Why this stays smooth at 60fps+:**
- Marker drag/rotate/resize updates only call `notifyListeners()` on the
  lightweight `MarkerProvider` — the map image itself never rebuilds.
- Drawing strokes are stored as normalized (0–1) points and painted via a
  single `CustomPainter` inside its own `RepaintBoundary`, so live freehand
  strokes repaint independently of the marker layer.
- The whole board (map + markers + drawings) sits inside one outer
  `RepaintBoundary`, which doubles as the export capture target.

---

## 🚀 Getting started

This archive ships the full `lib/`, `assets/`, `pubspec.yaml`, and a
reference `android/app/src/main/AndroidManifest.xml` (with the gallery-write
permission already added). Since native Android/iOS build folders are
platform-generated and large, scaffold them first, then this manifest will
merge in:

```bash
flutter create . --project-name ff_tactical_planner --org com.warewolf.strategy
# (confirm "yes" if asked to overwrite — it will not touch lib/, assets/, or pubspec.yaml)

flutter pub get

# Regenerate Hive adapters if you change any model
# (hand-written .g.dart files are already included and match hive_generator's
# output format, so this step is optional unless you edit the models):
flutter packages pub run build_runner build --delete-conflicting-outputs

flutter run
```

Minimum Flutter SDK: 3.3+ (Dart 3.3+). Tested against the latest stable
Flutter channel.

---

## 📦 Key dependencies

| Package | Purpose |
|---|---|
| `provider` | State management for map/marker/drawing state |
| `hive` / `hive_flutter` | Local, binary, near-instant strategy persistence |
| `gal` | Save exported PNG to the Android/iOS gallery |
| `uuid` | Unique IDs for markers, strokes, strategies |
| `image` | Available for any future server-side/PNG post-processing |

---

## ⚠️ Important note on map assets

The map images in `assets/maps/` are the exact files provided for this
project, embedded at full resolution with **no recompression, resizing,
redrawing, or edits of any kind**. These are Free Fire game assets; ensure
you have the appropriate rights/permissions from the IP holder before
distributing this app publicly or commercially — this build is intended for
internal team/scrim tactical planning use.

---

## 🔧 Extending

- To add a new map: drop the image in `assets/maps/`, add an enum value to
  `GameMap` in `lib/models/strategy_model.dart`, wire its `assetPath` and
  `displayName`, and add it to `pubspec.yaml`'s asset list.
- To add a new marker type: add it to `MarkerType` in
  `lib/models/marker_model.dart` and give it an icon/color/label entry in
  `kMarkerStyles` (`lib/utils/constants.dart`).
