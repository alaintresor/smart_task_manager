import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_task_manager/core/services/background_service.dart';
import 'package:smart_task_manager/core/services/firebase_service.dart';
import 'package:smart_task_manager/core/services/notification_service.dart';
import 'package:smart_task_manager/data/providers/auth_provider.dart';
import 'package:smart_task_manager/presentation/screens/login_screen.dart';
import 'package:smart_task_manager/presentation/screens/notification_test_screen.dart';
import 'package:smart_task_manager/presentation/screens/signup_screen.dart';
import 'package:smart_task_manager/presentation/screens/task_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:workmanager/workmanager.dart';

// Global navigator key to access context from outside of build
final globalNavigatorKey = GlobalKey<NavigatorState>();

// Create a provider for the NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(notificationsPlugin: FlutterLocalNotificationsPlugin());
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = prefs.getString('themeMode') ?? 'system';

  // Initialize notification service
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(notificationsPlugin: notificationsPlugin);
  await notificationService.initialize();

  // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // // Run every 15 mins (min allowed on Android)
  // Workmanager().registerPeriodicTask(
  //   'check-tasks-periodic',
  //   checkTasksBackgroundTask,
  //   frequency: const Duration(minutes: 15),
  //   constraints: Constraints(networkType: NetworkType.connected),
  // );

  runApp(
    ProviderScope(
      overrides: [
        // Override the notificationServiceProvider with our initialized instance
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: MyApp(initialThemeMode: _stringToThemeMode(savedThemeMode)),
    ),
  );
}

// Helper function to convert string to ThemeMode
ThemeMode _stringToThemeMode(String themeMode) {
  switch (themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

class MyApp extends ConsumerStatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, this.initialThemeMode = ThemeMode.system});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  // Change the app theme and save preference
  Future<void> _changeTheme(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });

    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(themeMode));
  }

  // Helper function to convert ThemeMode to string
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Helper method to handle logout
  Future<void> _handleLogout() async {
    await ref.read(authRepositoryProvider).logout();
    if (mounted) {
      globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    print('Auth state------------: $authState');
    return MaterialApp(
      title: 'Smart Task Manager',
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,

      // Light theme configuration
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      // Dark theme configuration
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: Colors.grey[850],
        ),
      ),

      // Current theme mode (system, light, or dark)
      themeMode: _themeMode,

      home: authState.when(
        data:
            (user) =>
                user != null
                    ? TaskScreen(
                      onThemeChanged: _changeTheme,
                      currentThemeMode: _themeMode,
                      onLogout: _handleLogout,
                    )
                    : const LoginScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('Error: $error'))),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/task':
            (context) => TaskScreen(
              onThemeChanged: _changeTheme,
              currentThemeMode: _themeMode,
              onLogout: _handleLogout,
            ),
        '/notification_test': (context) => const NotificationTestScreen(),
      },
    );
  }
}
