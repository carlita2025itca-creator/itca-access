import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:itca_access/screens/menu_principal_screen.dart';

// Aquí después importaremos Firebase para que los botones de Google funcionen
////////////////////////////// PANTALLA PRINCIPAL (LOGIN DIRECTO) //////////////////////////////
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Controladores para el login manual
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pedirPermisosAutomaticos();
  }

  Future<void> pedirPermisosAutomaticos() async {
    // Pedimos todos los sensores críticos para la app inclusiva
    await [
      // 📍 Para detectar los Beacons
      Permission.location,
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,

      // 🎤 Para el dictado por voz (El micrófono gigante)
      Permission.microphone,

      // 📷 Para futuras funciones de reconocimiento visual
      Permission.camera,
    ].request();
  }

  // Simulación de Login Manual
  Future<void> loginManualSimulado() async {
    if (_correoController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena los campos')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificando credenciales...')),
    );
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenu()),
      );
    }
  }

  // Simulación de Login con Google
  Future<void> loginConGoogleSimulado() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conectando con Google...')));
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Simulamos que es nuevo y lo mandamos a completar los datos inclusivos
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
                // 1. Logo y Título
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

                // 2. Formulario de Login Manual
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

                // Botón Entrar
                ElevatedButton(
                  onPressed: loginManualSimulado,
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

                // 3. Divisor visual
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

                // 4. Botón de Google Inclusivo y Grande
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

                // 5. Enlace a Registro
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
}

////////////////////////////// PANTALLA INICIAR SESIÓN //////////////////////////////
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginManualSimulado() async {
    // Simulación visual
    if (_correoController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena los campos')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificando credenciales...')),
    );
    await Future.delayed(const Duration(seconds: 1)); // Espera falsa

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Color(0xFF0D47A1),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loginManualSimulado,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ingresar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Solo dejamos el login manual en esta pantalla para no duplicar botones
          ],
        ),
      ),
    );
  }
}

////////////////////////////// PANTALLA REGISTRO MANUAL //////////////////////////////
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Controladores visuales
  final _nombresCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();

  bool _aceptaTerminos = false;

  Future<void> registrarUsuarioSimulado() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos para continuar'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creando cuenta inclusiva...')),
    );
    await Future.delayed(const Duration(seconds: 1)); // Espera falsa

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenu()),
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

            // Campos de texto con íconos
            TextField(
              controller: _nombresCtrl,
              decoration: InputDecoration(
                labelText: 'Nombres y Apellidos',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
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

            const SizedBox(height: 30),

            // 👇 TÉRMINOS Y CONDICIONES INCLUSIVOS
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
                      scale: 1.3, // Hace el cuadrito un 30% más grande
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Botón de cancelar
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Volver al inicio',
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

////////////////////////////// PANTALLA COMPLETAR PERFIL (GOOGLE) //////////////////////////////
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
    await Future.delayed(const Duration(seconds: 1)); // Espera falsa

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenu()),
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

            // Inputs con íconos y bordes claros
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

            const SizedBox(height: 40), // Más espacio para respirar
            // Checkbox Términos y Condiciones Inclusivo
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
