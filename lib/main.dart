import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_task_manager/presentation/screens/login_screen.dart';
import 'package:smart_task_manager/presentation/screens/signup_screen.dart';
import 'package:smart_task_manager/presentation/screens/task_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
// );
  
  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = prefs.getString('themeMode') ?? 'system';
  
  runApp(MyApp(initialThemeMode: _stringToThemeMode(savedThemeMode)));
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

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  
  const MyApp({super.key, this.initialThemeMode = ThemeMode.system});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      debugShowCheckedModeBanner: false,
      
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
      
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/task': (context) => _buildTaskScreen(),
      },
    );
  }
  
  // Helper method to build TaskScreen with theme change callback
  Widget _buildTaskScreen() {
    return TaskScreen(
      onThemeChanged: _changeTheme,
      currentThemeMode: _themeMode,
      onLogout: () {
        Navigator.of(_globalNavigatorKey.currentContext!).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      },
    );
  }
  
  // Global navigator key to access context from outside of build
  static final GlobalKey<NavigatorState> _globalNavigatorKey = GlobalKey<NavigatorState>();
}