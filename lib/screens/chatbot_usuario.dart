import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // PAQUETE DE VOZ (Offline)
import 'dart:async'; // Necesario para la respuesta simulada

class ChatBotUsuarioScreen extends StatefulWidget {
  const ChatBotUsuarioScreen({super.key});

  @override
  State<ChatBotUsuarioScreen> createState() => _ChatBotUsuarioScreenState();
}

class _ChatBotUsuarioScreenState extends State<ChatBotUsuarioScreen> {
  final TextEditingController _controladorMensaje = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts(); // Instancia del lector de voz
  final List<Map<String, dynamic>> _mensajes = [];

  bool _estaEscribiendo = false;
  bool _estaEscuchando = false; // Simulación para el micrófono

  @override
  void initState() {
    super.initState();
    _configurarVoz(); // Iniciamos configuración de voz (Offline)

    // MENSAJE DE BIENVENIDA DEL BOT
    String bienvenida =
        "¡Hola! Soy tu asistente de ITCA Access. ¿A qué institución o área deseas ir hoy?";
    _mensajes.add({"texto": bienvenida, "esUsuario": false});

    // El bot también saluda por voz al iniciar
    Future.delayed(const Duration(milliseconds: 500), () {
      _flutterTts.speak(bienvenida);
    });
  }

  // ================= CONFIGURACIÓN DE VOZ OFFLINE =================
  Future<void> _configurarVoz() async {
    // Configuraciones básicas para español
    await _flutterTts.setLanguage("es-ES"); // Español
    await _flutterTts.setSpeechRate(0.5); // Velocidad normal (0.0 a 1.0)
    await _flutterTts.setVolume(1.0); // Volumen al máximo
    await _flutterTts.setPitch(1.0); // Tono de voz normal
  }

  // ================= 1. ENVIAR MENSAJE A LA PANTALLA =================
  void _enviarMensaje(String texto) {
    if (texto.trim().isEmpty) return;

    setState(() {
      // 1. Agregamos lo que el usuario escribió a la pantalla
      _mensajes.add({"texto": texto, "esUsuario": true});
      _controladorMensaje.clear();
      _estaEscribiendo = false;
    });

    // 2. Simulamos que el bot procesa
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // 3. Llamamos a nuestro "Cerebro Offline" (Reglas del ITCA)
        String respuestaDelBot = _cerebroOfflineITCA(texto);

        setState(() {
          _mensajes.add({"texto": respuestaDelBot, "esUsuario": false});
        });

        // 🔊 ✨ ¡MAGIA HÍBRIDA! ✨
        // El celular lee la respuesta en voz alta al mismo tiempo que muestra el texto.
        // Esto sirve tanto para personas ciegas (audio) como sordas (texto).
        _flutterTts.speak(respuestaDelBot);
      }
    });
  }

  // ================= 2. EL CEREBRO OFFLINE (Reglas del ITCA) =================
  String _cerebroOfflineITCA(String mensajeUsuario) {
    // 1. Pasamos todo a minúsculas para que sea más fácil buscar las palabras
    String msj = mensajeUsuario.toLowerCase();

    // 2. Creamos nuestras reglas con palabras clave
    if (msj.contains("baño") ||
        msj.contains("sanitario") ||
        msj.contains("baños")) {
      return "Los baños están ubicados en la planta baja. Sigue recto por el pasillo principal y los encontrarás a tu derecha.";
    } else if (msj.contains("biblioteca") ||
        msj.contains("libro") ||
        msj.contains("estudiar")) {
      return "La biblioteca se encuentra en el segundo piso. Utiliza las gradas principales y gira a la izquierda.";
    } else if (msj.contains("secretaria") ||
        msj.contains("información") ||
        msj.contains("recepcion") ||
        msj.contains("registro")) {
      return "La secretaría está en la entrada principal del edificio, frente a la puerta de cristal.";
    } else if (msj.contains("rectorado") || msj.contains("director")) {
      return "El rectorado está en el tercer piso. Por favor, solicita asistencia en secretaría primero.";
    } else if (msj.contains("hola") ||
        msj.contains("buenos") ||
        msj.contains("saludos")) {
      return "¡Hola! Bienvenido al ITCA. Dime, ¿a qué lugar necesitas ir?";
    } else if (msj.contains("gracias") || msj.contains("amable")) {
      return "¡De nada! Es un placer ayudarte. ¿Hay algo más en lo que te pueda guiar?";
    } else {
      // 3. El mensaje de "No entendí" (El Plan de Respaldo)
      return "Lo siento, no te entendí muy bien. ¿Podrías usar palabras clave como 'baño', 'biblioteca' o 'secretaría'?";
    }
  }

  // Simulación de escuchar por micrófono
  void _alternarMicrofono() {
    setState(() {
      _estaEscuchando = !_estaEscuchando;
      if (_estaEscuchando) {
        // Aquí luego conectaremos el paquete speech_to_text real
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 Escuchando... Di algo (Simulación)'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el color azul corporativo
    const Color azulITCA = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ================= C) DISEÑO DEL APPBAR SOLICITADO =================
      appBar: AppBar(
        backgroundColor: azulITCA,
        automaticallyImplyLeading:
            false, // Quitamos la flecha de "atrás" automática
        elevation: 0,

        // 1. TÍTULO: ITCA Access
        title: const Text(
          "ITCA Access",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        // 2. ACCIONES: Bolita de perfil a la derecha
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2), // Fondo sutil
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ), // Icono por defecto
              // Si tienes una imagen real, usa:
              // backgroundImage: AssetImage('assets/tu_foto_perfil.png'),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // A) ZONA DE CHAT (Burbujas)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              reverse: true, // Empezamos a ver el chat desde abajo
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                // Invertimos el índice por usar reverse:true
                final msjReverse = _mensajes[_mensajes.length - 1 - index];
                final esUsuario = msjReverse['esUsuario'];
                return _construirBurbuja(
                  msjReverse['texto'],
                  esUsuario,
                  azulITCA,
                );
              },
            ),
          ),

          // B) ZONA DE ESCRITURA (Minimalista)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // CAJA DE TEXTO
                Expanded(
                  child: TextField(
                    controller: _controladorMensaje,
                    onChanged: (texto) {
                      setState(() {
                        _estaEscribiendo = texto.trim().isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: _estaEscuchando
                          ? "Escuchando..."
                          : "Escribe un mensaje...",
                      hintStyle: TextStyle(
                        color: _estaEscuchando ? Colors.orange : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // EL BOTÓN INTELIGENTE (Cambia entre Micrófono y Enviar)
                GestureDetector(
                  onTap: () {
                    if (_estaEscribiendo) {
                      _enviarMensaje(_controladorMensaje.text);
                    } else {
                      _alternarMicrofono();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _estaEscribiendo
                          ? azulITCA
                          : (_estaEscuchando
                                ? Colors.red
                                : Colors.orange.shade700),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _estaEscribiendo
                          ? Icons.send
                          : (_estaEscuchando ? Icons.mic_off : Icons.mic),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Diseño de las burbujitas de chat
  Widget _construirBurbuja(String texto, bool esUsuario, Color colorUsuario) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15), // Solo para el espacio
        constraints: const BoxConstraints(
          maxWidth: 300,
        ), // Solo para el ancho máximo
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: esUsuario ? colorUsuario : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(esUsuario ? 20 : 0),
            bottomRight: Radius.circular(esUsuario ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
