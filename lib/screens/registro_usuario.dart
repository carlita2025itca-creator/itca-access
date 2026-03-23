import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'identificar_institucion.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _nombresCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();

  bool _aceptaTerminos = false;

  @override
  void dispose() {
    // Liberar memoria para que la app no se ponga lenta
    _nombresCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _cedulaCtrl.dispose();
    _telCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> registrarUsuarioSimulado() async {
    if (_nombresCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena los campos obligatorios'),
        ),
      );
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos para continuar'),
        ),
      );
      return;
    }

    // ENCRIPTAR ANTES DE GUARDAR (Igual que en el Login)
    var bytes = utf8.encode(_passCtrl.text);
    String passwordEncriptada = sha256.convert(bytes).toString();
    debugPrint("Password a guardar: $passwordEncriptada");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creando cuenta inclusiva...')),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SeleccionEdificioScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Ingresa tus datos para registrarte:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _crearInput(_nombresCtrl, 'Nombres y Apellidos', Icons.person),
            const SizedBox(height: 15),
            _crearInput(
              _emailCtrl,
              'Correo Electrónico',
              Icons.email,
              tipo: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _crearInput(_passCtrl, 'Contraseña', Icons.lock, ocultar: true),
            const SizedBox(height: 15),
            _crearInput(
              _cedulaCtrl,
              'Cédula',
              Icons.badge,
              tipo: TextInputType.number,
            ),
            const SizedBox(height: 15),
            _crearInput(
              _telCtrl,
              'Celular',
              Icons.phone_android,
              tipo: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _crearInput(
              _edadCtrl,
              'Edad',
              Icons.cake,
              tipo: TextInputType.number,
            ),
            const SizedBox(height: 30),

            // Checkbox de términos
            InkWell(
              onTap: () => setState(() => _aceptaTerminos = !_aceptaTerminos),
              child: Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    activeColor: const Color(0xFF0D47A1),
                    onChanged: (val) =>
                        setState(() => _aceptaTerminos = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto los Términos, Condiciones y Políticas.',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: registrarUsuarioSimulado,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Registrarme',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool ocultar = false,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: ocultar,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
