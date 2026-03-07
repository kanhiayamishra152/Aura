import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_app/config/app_theme.dart';
import 'package:focus_app/config/app_routes.dart';
import 'package:focus_app/core/services/storage_service.dart';
import 'package:focus_app/core/services/audio_service.dart';
import 'package:focus_app/core/services/notification_service.dart';
import 'package:focus_app/core/services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = StorageService();
  await storageService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  final audioService = AudioService();

  runApp(
    FocusApp(
      storageService: storageService,
      audioService: audioService,
      notificationService: notificationService,
      connectivityService: connectivityService,
    ),
  );
}

class FocusApp extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final NotificationService notificationService;
  final ConnectivityService connectivityService;

  const FocusApp({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.notificationService,
    required this.connectivityService,
  });

  @override
  State<FocusApp> createState() => _FocusAppState();
}

class _FocusAppState extends State<FocusApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
    _playStartupSound();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.audioService.dispose();
    widget.connectivityService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        widget.audioService.releaseAll();
        break;
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (_themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  Future<void> _loadThemePreference() async {
    final savedTheme = widget.storageService.getString('theme_mode');
    if (savedTheme != null) {
      setState(() {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      });
    }
  }

  Future<void> _playStartupSound() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_isAppInForeground) {
      await widget.audioService.play('app_startup.mp3');
    }
  }

  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    widget.storageService.setString('theme_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
