import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers.dart';
import 'src/ui/home_screen.dart';
import 'src/ui/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: KejaAgentApp()));
}

class KejaAgentApp extends StatelessWidget {
  const KejaAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keja Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B6E4F),
        useMaterial3: true,
      ),
      home: const _Gate(),
    );
  }
}

/// Sends the agent to Home if a session restores, else to Login.
class _Gate extends ConsumerWidget {
  const _Gate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
      data: (token) => token == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
