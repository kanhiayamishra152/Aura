import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/app_routes.dart';

// Services
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/task_service.dart';
import 'core/services/native_bridge_service.dart';
import 'core/services/gamification_service.dart';

// Providers
import 'core/providers/auth_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/app_blocker_provider.dart';
import 'core/providers/gamification_provider.dart';
import 'core/providers/audio_provider.dart';

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

  // Initialize Core Services
  final storageService = StorageService();
  await storageService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  final audioService = AudioService();

  // Initialize Database Service (Crucial for new features)
  final databaseService = DatabaseService();
  await databaseService.database; // Force initialization

  // Initialize New Feature Services
  final authService = AuthService();
  final taskService = TaskService(databaseService);
  final nativeBridgeService = NativeBridgeService();
  final gamificationService = GamificationService(); // Assumed pre-existing implementation

  runApp(
    // Wrapping the entire app in MultiProvider for State Management
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskService)),
        ChangeNotifierProvider(create: (_) => GamificationProvider(gamificationService)),
        ChangeNotifierProvider(create: (_) => AppBlockerProvider(nativeBridgeService, databaseService)),
        ChangeNotifierProvider(create: (_) => AudioProvider(audioService)),
      ],
      child: FocusApp(
        storageService: storageService,
        audioService: audioService,
        notificationService: notificationService,
        connectivityService: connectivityService,
        databaseService: databaseService,
      ),
    ),
  );
}

class FocusApp extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final NotificationService notificationService;
  final ConnectivityService connectivityService;
  final DatabaseService databaseService;

  const FocusApp({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.notificationService,
    required this.connectivityService,
    required this.databaseService,
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
        // Commenting out releaseAll() temporarily so focus music can play in background if needed
        // widget.audioService.releaseAll(); 
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
      initialRoute: AppRoutes.splash, // Starts at Splash Screen for Auth routing
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
