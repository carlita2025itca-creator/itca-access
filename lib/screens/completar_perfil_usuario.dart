import 'package:flutter/material.dart';
import 'identificar_institucion.dart';
import 'login_usuario.dart'; // Para poder regresar a la pantalla principal

class PantallaCompletarPerfil extends StatefulWidget {
  const PantallaCompletarPerfil({super.key});

  @override
  State<PantallaCompletarPerfil> createState() =>
      _PantallaCompletarPerfilState();
}

class _PantallaCompletarPerfilState extends State<PantallaCompletarPerfil> {
  final _cedulaCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();

  bool _aceptaTerminos = false;

  Future<void> guardarPerfilSimulado() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acepta los términos para continuar')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando perfil inclusivo...')),
    );
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SeleccionEdificioScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          tooltip: 'Volver al inicio',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaPrincipal(),
              ),
            );
          },
        ),
        title: const Text(
          "Completa tu Perfil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "¡Bienvenido! Te registraste con Google. Solo faltan estos datos:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _cedulaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cédula',
                prefixIcon: const Icon(Icons.badge, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Celular',
                prefixIcon: const Icon(
                  Icons.phone_android,
                  color: Color(0xFF0D47A1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _edadCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad',
                prefixIcon: const Icon(Icons.cake, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),

            InkWell(
              onTap: () {
                setState(() => _aceptaTerminos = !_aceptaTerminos);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 5.0,
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        value: _aceptaTerminos,
                        activeColor: const Color(0xFF0D47A1),
                        onChanged: (bool? valorNuevo) {
                          setState(() => _aceptaTerminos = valorNuevo ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Acepto los Términos, Condiciones y Políticas de Privacidad.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: guardarPerfilSimulado,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Finalizar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaPrincipal(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Cancelar y volver atrás',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
