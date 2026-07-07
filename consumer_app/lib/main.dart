import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/ui/map_screen.dart';

void main() {
  runApp(const ProviderScope(child: KejaApp()));
}

class KejaApp extends StatelessWidget {
  const KejaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B6E4F),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
