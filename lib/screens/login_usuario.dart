import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert'; // Para convertir el texto
import 'package:crypto/crypto.dart'; // Para el algoritmo SHA-256
import 'package:supabase_flutter/supabase_flutter.dart'; // Para la base de datos

import 'identificar_institucion.dart';
import 'registro_usuario.dart';
import 'completar_perfil_usuario.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pedirPermisosAutomaticos();
  }

  Future<void> pedirPermisosAutomaticos() async {
    await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.microphone,
      Permission.camera,
    ].request();
  }

  // ================= LOGIN CON BASE DE DATOS =================
  Future<void> loginManual() async {
    final correo = _correoController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // 1. Validación visual básica
    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor llena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificando credenciales...')),
    );

    try {
      // 2. Encriptar la contraseña que escribió el usuario para poder compararla
      var bytes = utf8.encode(password);
      String passwordEncriptada = sha256.convert(bytes).toString();

      // 3. Preguntarle a Supabase si existe alguien con ese correo Y esa contraseña exacta
      final respuesta = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('email', correo)
          .eq('password', passwordEncriptada)
          .maybeSingle();

      if (mounted) {
        if (respuesta != null) {
          // ✨ ¡El usuario existe y la clave es correcta!

          // 4. Revisar si un administrador ya le dio acceso
          if (respuesta['estado'] == 'pendiente') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⏳ Tu cuenta aún está en revisión por un administrador.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return; // Bloqueamos el paso
          }

          // 5. Todo en orden, le damos la bienvenida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Bienvenido, ${respuesta['nombres']}'),
              backgroundColor: Colors.green,
            ),
          );

          // Lo enviamos a la pantalla de edificios (puedes pasarle los datos del usuario si los necesitas allá)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SeleccionEdificioScreen(),
            ),
          );
        } else {
          // No se encontró el usuario o la contraseña no coincide
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Correo o contraseña incorrectos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error en Login: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Error al conectar con el servidor. Revisa tu internet.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> loginConGoogleSimulado() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conectando con Google...')));
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaCompletarPerfil(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.accessibility_new,
                  size: 80,
                  color: Color(0xFF0D47A1),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ITCA Access',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const Text(
                  'Navegación Inclusiva',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF0D47A1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF0D47A1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loginManual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: loginConGoogleSimulado,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 35,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Continuar con Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: Colors.grey, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaRegistro(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarTerminosYCondiciones(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // El usuario no puede cerrar haciendo clic afuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Términos y Condiciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Al utilizar ITCA Access, usted acepta el uso de su ubicación en segundo plano y la activación del Bluetooth para detectar los Beacons instalados en el campus. \n\n'
                    'Estos datos son utilizados exclusivamente para verificar su presencia en los edificios y mejorar la seguridad institucional. No compartimos su información con terceros.',
                    textAlign:
                        TextAlign.justify, // ✨ CORREGIDO: Ahora sí funcionará
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el modal
                // Navega a la siguiente pantalla
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeleccionEdificioScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), // Rojo ITCA
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ACEPTO',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
