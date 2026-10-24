import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/voice_mode_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/debug_tools_screen.dart';
import 'screens/device_test_center_screen.dart';
import 'services/database_service.dart';
import 'services/security_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  await SecurityService.instance.init();
  runApp(const JXApp());
}

class JXApp extends StatelessWidget {
  const JXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JX AI Companion',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C14),
        primaryColor: const Color(0xFF00F2FE),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFFFF007A),
          tertiary: Color(0xFF7000FF),
          surface: Color(0xFF121826),
          background: Color(0xFF080C14),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingFlowScreen(),
        '/chat': (context) => const ChatScreen(),
        '/voice': (context) => const VoiceModeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/debug-tools': (context) => const DebugToolsScreen(),
        '/device-test-center': (context) => const DeviceTestCenterScreen(),
      },
    );
  }
}
