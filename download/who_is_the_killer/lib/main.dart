import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/lobby_screen.dart';

/// ────────────────────────────────────────────────────────────────
/// Who is the Killer? — Multiplayer Interactive Mystery Game
///
/// A real-time multiplayer murder mystery game where players
/// investigate crimes, analyze clues, vote to eliminate suspects,
/// and ultimately identify the Mafioso (Killers).
///
/// Architecture: Clean Architecture / Feature-Sliced Design (FSD)
/// State Management: Riverpod
/// Design System: Structured Rebellion (Swiss-style minimalist)
/// ────────────────────────────────────────────────────────────────
void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: WhoIsTheKillerApp(),
    ),
  );
}

/// ────────────────────────────────────────────────────────────────
/// WhoIsTheKillerApp — Root application widget
///
/// Configures the theme (Structured Rebellion dark theme),
/// sets the text direction for Arabic (RTL), and defines
/// the initial route to the Lobby screen.
/// ────────────────────────────────────────────────────────────────
class WhoIsTheKillerApp extends StatelessWidget {
  const WhoIsTheKillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'من هو القاتل؟',
      debugShowCheckedModeBanner: false,

      // ── Theme Configuration ──────────────────────────────────
      theme: AppTheme.darkTheme,

      // ── RTL Support for Arabic ───────────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ── Initial Route ────────────────────────────────────────
      home: const LobbyScreen(),
    );
  }
}
