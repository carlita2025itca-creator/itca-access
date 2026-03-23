import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✨ 1. Agregamos esta importación
import 'package:itca_access/screens/login_usuario.dart';

// ✨ 2. Convertimos el main en un Future asíncrono
Future<void> main() async {
  // Esto asegura que Flutter esté listo antes de conectar a internet
  WidgetsFlutterBinding.ensureInitialized();

  // ✨ 3. AQUÍ ESTÁ LA MAGIA: Conectamos la app a tu base de datos
  await Supabase.initialize(
    url:
        'https://btbzggtbnbkqgyhbdsqx.supabase.co', // 👈 Pega tu URL de Supabase aquí
    anonKey:
        'sb_publishable_LC69zVXpoIOoSG3BZcO9vw_H_rSlP0H', // 👈 Pega tu Anon Key aquí
  );

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
      home: const PantallaPrincipal(), // Arranca directo en el Login
    );
  }
}
