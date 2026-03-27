import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart'; // Librería nativa de Flutter
// import 'package:vibration/vibration.dart'; // Descomenta si usas el paquete de vibración

class ChatBotUsuarioScreen extends StatefulWidget {
  const ChatBotUsuarioScreen({super.key});

  @override
  State<ChatBotUsuarioScreen> createState() => _ChatBotUsuarioScreenState();
}

class _ChatBotUsuarioScreenState extends State<ChatBotUsuarioScreen> {
  // ================= 1. CONFIGURACIÓN DEL SISTEMA =================
  final FlutterTts _tts = FlutterTts();

  // TUS DATOS REALES
  final String macEntrada = "DD:34:02:0C:00:DF"; // Beacon a -64
  final String macPasillo = "DD:34:02:0C:01:ED"; // Beacon a -58
  final int rssiAlMetro = -59; // Rssi@1m de tu imagen

  // CONFIGURACIÓN DE NAVEGACIÓN
  final double anguloIdealNorte =
      0.0; // Cambia esto por los grados reales del pasillo
  final double margenError = 20.0;

  // ================= 2. VARIABLES DE ESTADO =================
  List<Map<String, String>> mensajesChat = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  bool enRuta = false;
  bool haLlegado = false;
  double distanciaActual = 100.0;
  double _rssiSuavizado = -100.0; // Filtro para estabilizar señal

  // Controladores de Spam para el Chat
  DateTime? _ultimoAvisoBrujula;
  DateTime? _ultimoAvisoDistancia;

  @override
  void initState() {
    super.initState();
    _configurarVoz();
    _saludoInicial();
    _iniciarSensores();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _compassSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _tts.stop();
    super.dispose();
  }

  // ================= 3. MOTOR DEL ASISTENTE (VOZ + CHAT) =================
  Future<void> _configurarVoz() async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.5);
  }

  void _botHabla(String texto) {
    if (!mounted) return;
    setState(() {
      mensajesChat.insert(0, {'emisor': 'bot', 'texto': texto});
    });
    _tts.speak(texto);
  }

  void _saludoInicial() {
    _botHabla(
      "Hola. Soy tu asistente del ITCA. Acércate a la Entrada Principal para comenzar.",
    );
  }

  // ================= 4. CÁLCULO DE DISTANCIA =================
  double _calcularMetros(double rssi) {
    if (rssi == 0) return 100.0;
    return math.pow(10.0, ((rssiAlMetro - rssi) / (10.0 * 2.5))).toDouble();
  }

  // ================= 5. LÓGICA DE SENSORES (EL CEREBRO) =================
  void _iniciarSensores() async {
    // ---- A. ENCENDER BLUETOOTH ----
    // ---- A. ENCENDER BLUETOOTH ----
    await FlutterBluePlus.startScan(continuousUpdates: true);
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (haLlegado) return;

      for (ScanResult r in results) {
        String mac = r.device.remoteId.str;

        // SOLO MONITOREAMOS EL DESTINO PARA EL "RIEL"
        if (mac == macPasillo) {
          // Filtro para suavizar saltos de señal
          if (_rssiSuavizado == -100.0) _rssiSuavizado = r.rssi.toDouble();
          _rssiSuavizado = (_rssiSuavizado * 0.8) + (r.rssi * 0.2);

          double metros = _calcularMetros(_rssiSuavizado);
          if (mounted) setState(() => distanciaActual = metros);

          // INICIO DE RUTA
          if (!enRuta && r.rssi > -70) {
            enRuta = true;
            _botHabla(
              "Señal del pasillo detectada. Gira sobre tu eje hasta que te indique caminar.",
            );
          }

          // LLEGADA A LA META
          if (enRuta && metros < 1.5) {
            haLlegado = true;
            enRuta = false;
            _botHabla("Excelente. Has llegado al pasillo uno. Detente aquí.");
            HapticFeedback.heavyImpact(); // <--- Vibración nativa fuerte
            FlutterBluePlus.stopScan();
          }
        }
      }
    });

    // ---- B. ENCENDER BRÚJULA (EL RIEL) ----
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (!enRuta || haLlegado || event.heading == null) return;

      double anguloActual = event.heading!;
      double diff = (anguloActual - anguloIdealNorte);

      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;

      final ahora = DateTime.now();

      // ESTÁ DESVIADO
      if (_ultimoAvisoBrujula == null ||
          ahora.difference(_ultimoAvisoBrujula!).inSeconds > 5) {
        if (diff > 0) {
          _botHabla("Te desvías. Gira un poco a la izquierda.");
        } else {
          _botHabla("Te desvías. Gira un poco a la derecha.");
        }
        _ultimoAvisoBrujula = ahora;
        HapticFeedback.vibrate(); // <--- Vibración nativa normal
      }
      // ESTÁ ALINEADO
      else {
        if (_ultimoAvisoDistancia == null ||
            ahora.difference(_ultimoAvisoDistancia!).inSeconds > 12) {
          if (distanciaActual > 2.0 && distanciaActual < 20.0) {
            _botHabla(
              "Vas en línea recta. Faltan ${distanciaActual.toStringAsFixed(0)} metros.",
            );
            _ultimoAvisoDistancia = ahora;
          }
        }
      }
    });
  }

  // ================= 6. INTERFAZ GRÁFICA (DISEÑO DEL CHAT) =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente ITCA Access'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ZONA DE BURBUJAS DE CHAT
          Expanded(
            child: ListView.builder(
              reverse: true, // Lo más nuevo abajo
              padding: const EdgeInsets.all(15),
              itemCount: mensajesChat.length,
              itemBuilder: (context, index) {
                final msg = mensajesChat[index];
                final esBot = msg['emisor'] == 'bot';

                return Align(
                  alignment: esBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: esBot ? Colors.blue.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomLeft: esBot
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                        bottomRight: !esBot
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                      ),
                      border: Border.all(
                        color: esBot
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (esBot)
                          const Icon(
                            Icons.support_agent,
                            color: Color(0xFF1A237E),
                            size: 24,
                          ),
                        if (esBot) const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            msg['texto']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BARRA INFERIOR DE ESTADO VISUAL
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      enRuta
                          ? Icons.navigation
                          : (haLlegado
                                ? Icons.check_circle
                                : Icons.bluetooth_searching),
                      color: enRuta
                          ? Colors.blue
                          : (haLlegado ? Colors.green : Colors.grey),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enRuta
                              ? "Navegando..."
                              : (haLlegado
                                    ? "Destino Alcanzado"
                                    : "Buscando..."),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (enRuta && !haLlegado)
                          Text(
                            "Faltan: ${distanciaActual.toStringAsFixed(1)} metros",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
