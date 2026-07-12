import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/providers/map_provider.dart';
import 'package:ff_tactical_planner/providers/marker_provider.dart';
import 'package:ff_tactical_planner/providers/drawing_provider.dart';
import 'package:ff_tactical_planner/services/storage_service.dart';
import 'package:ff_tactical_planner/screens/home_screen.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for a consistent, predictable tactical-board layout.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await StorageService.init();

  runApp(const FFTacticalPlannerApp());
}

class FFTacticalPlannerApp extends StatelessWidget {
  const FFTacticalPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => MarkerProvider()),
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
      ],
      child: MaterialApp(
        title: 'FF Tactical Planner',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Roboto',
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
