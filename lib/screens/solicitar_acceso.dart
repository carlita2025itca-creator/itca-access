import 'package:flutter/material.dart';
import 'package:itca_access/screens/chatbot_usuario.dart';
import 'package:itca_access/screens/sesion_usuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // ✨ 1. IMPORTANTE: Agregar esta librería para el Timer

class SolicitarAccesoScreen extends StatefulWidget {
  final String institucionId;
  final String nombreInstitucion;

  const SolicitarAccesoScreen({
    super.key,
    required this.institucionId,
    required this.nombreInstitucion,
  });

  @override
  State<SolicitarAccesoScreen> createState() => _SolicitarAccesoScreenState();
}

class _SolicitarAccesoScreenState extends State<SolicitarAccesoScreen> {
  String _estado = "enviando";
  String _detalleDelError = "";

  Timer? _timerVerificacion; // ✨ 2. Creamos la variable del temporizador

  @override
  void initState() {
    super.initState();
    _procesarSolicitudAutomatica();
  }

  // ✨ 3. IMPORTANTE: Matar el temporizador si el usuario sale de la pantalla
  @override
  void dispose() {
    _timerVerificacion?.cancel();
    super.dispose();
  }

  Future<void> _procesarSolicitudAutomatica() async {
    try {
      final int? myIdNum = SesionUsuario.idActual;

      if (myIdNum == null) {
        if (mounted) {
          setState(() {
            _estado = "error";
            _detalleDelError = "Sesión no encontrada.";
          });
        }
        return;
      }

      // Insertar la solicitud en la base de datos
      final response = await Supabase.instance.client
          .from('registro_accesos')
          .insert({
            'usuario_id': myIdNum,
            'institucion_id': widget.institucionId,
            'estado': 'pendiente',
          })
          .select()
          .single();

      // Guardamos el ID de esta solicitud específica
      final solicitudId = response['id'];

      setState(() {
        _estado = "pendiente";
        _detalleDelError = "";
      });

      // ✨ 4. En lugar de Realtime, iniciamos el ciclo de búsqueda constante
      _iniciarBusquedaConstante(solicitudId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _estado = "error";
          _detalleDelError = "Error de conexión: $e";
        });
      }
    }
  }

  // ✨ 5. LA FUNCIÓN QUE PREGUNTA CONSTANTEMENTE A LA BASE DE DATOS
  void _iniciarBusquedaConstante(dynamic idSolicitud) {
    // Configurado para buscar cada 5 segundos (puedes cambiarlo a 120 para 2 minutos)
    _timerVerificacion = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      try {
        // Hacemos una consulta normal a Supabase para ver el estado actual
        final respuestaActual = await Supabase.instance.client
            .from('registro_accesos')
            .select('estado')
            .eq('id', idSolicitud)
            .single();

        final estadoEnBaseDeDatos = respuestaActual['estado'];
        debugPrint("🔍 Revisando estado... Actual: $estadoEnBaseDeDatos");

        // Si el estado en la nube es diferente al que vemos en pantalla, lo actualizamos
        if (mounted && estadoEnBaseDeDatos != _estado) {
          setState(() => _estado = estadoEnBaseDeDatos);

          // Si nos aprobaron, hacemos el viaje al Chatbot
          if (estadoEnBaseDeDatos == 'aprobado') {
            _timerVerificacion?.cancel(); // 🛑 Apagamos el temporizador

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatBotUsuarioScreen(),
                  ),
                );
              }
            });
          }
          // Si nos rechazan, también apagamos el temporizador para no gastar internet
          else if (estadoEnBaseDeDatos == 'rechazado') {
            _timerVerificacion?.cancel();
          }
        }
      } catch (e) {
        debugPrint("❌ Error consultando estado: $e");
        // No cambiamos el estado a error aquí para que siga intentando en el siguiente ciclo
        // por si fue solo un fallo de internet temporal de un segundo.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcono(),
              const SizedBox(height: 30),
              Text(
                widget.nombreInstitucion,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getMensaje(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (_estado == "enviando" || _estado == "pendiente")
                const CircularProgressIndicator(color: Color(0xFF1A237E)),
              if (_estado == "error")
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Regresar e intentar de nuevo"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcono() {
    if (_estado == "aprobado")
      return const Icon(Icons.check_circle, color: Colors.green, size: 100);
    if (_estado == "rechazado")
      return const Icon(Icons.cancel, color: Colors.red, size: 100);
    if (_estado == "error")
      return const Icon(Icons.error_outline, color: Colors.orange, size: 100);
    return const Icon(
      Icons.mark_email_read_outlined,
      color: Colors.blue,
      size: 100,
    );
  }

  String _getMensaje() {
    if (_estado == "enviando") return "Enviando solicitud a recepción...";
    if (_estado == "pendiente")
      return "Solicitud recibida. Por favor, espera a que el personal autorice tu entrada.";
    if (_estado == "aprobado")
      return "¡Acceso autorizado! Entrando al sistema...";
    if (_estado == "rechazado")
      return "Tu acceso ha sido denegado por seguridad.";

    return "Error detectado:\n$_detalleDelError";
  }
}
