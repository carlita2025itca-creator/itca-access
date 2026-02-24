import 'package:flutter/material.dart';
import 'package:itca_access/screens/registro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ItcaAccessApp());
}

class ItcaAccessApp extends StatelessWidget {
  const ItcaAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITCA Access',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}
