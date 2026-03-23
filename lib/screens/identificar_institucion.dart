import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';

class SeleccionEdificioScreen extends StatefulWidget {
  const SeleccionEdificioScreen({super.key});

  @override
  State<SeleccionEdificioScreen> createState() =>
      _SeleccionEdificioScreenState();
}

class _SeleccionEdificioScreenState extends State<SeleccionEdificioScreen> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _escaneando = true;
  bool _institucionEncontrada = false;
  String _mensaje = "Buscando señales BlueCharm...";
  String _nombreInstitucion = "";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _iniciarEscaneoBlueCharm();
    } else {
      setState(() {
        _mensaje = "El escaneo no está disponible en Web.";
        _escaneando = false;
      });
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // ================= 1. ESCANEO ESPECÍFICO =================
  Future<void> _iniciarEscaneoBlueCharm() async {
    try {
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          // OBTENEMOS LA ID
          String rawId = r.device.remoteId.str.toUpperCase();

          // FORZAMOS EL FORMATO CON DOS PUNTOS (Por si el celular no los trae)
          // Esto asegura que "DD34020C01ED" se convierta en "DD:34:02:0C:01:ED"
          String macFormateada = _formatearMAC(rawId);

          debugPrint("🔍 Escaneando: $macFormateada");

          if (!_institucionEncontrada) {
            _consultarSupabase(macFormateada);
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Función auxiliar para poner los dos puntos si faltan
  String _formatearMAC(String mac) {
    if (mac.contains(':')) return mac;
    // Si viene pegada "AABBCCDDEEFF", le ponemos los puntos cada 2 caracteres
    return mac
        .replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)}:")
        .substring(0, 17);
  }

  // ================= 2. CONSULTA A TU TABLA =================
  Future<void> _consultarSupabase(String mac) async {
    try {
      // Nota: He quitado el JOIN de 'instituciones' por ahora para
      // asegurar que encuentre el beacon primero.
      final data = await Supabase.instance.client
          .from('beacons')
          .select()
          .eq('mac_address', mac)
          .maybeSingle();

      if (data != null && mounted) {
        debugPrint("✅ COINCIDENCIA ENCONTRADA: ${data['nombre']}");

        setState(() {
          _institucionEncontrada = true;
          _escaneando = false;
          // Usamos la columna 'nombre' que veo en tu imagen (ej. 'Entrada principal')
          _nombreInstitucion = data['nombre'] ?? 'Ubicación Detectada';
          _mensaje = "¡Ubicación Identificada!";
        });

        FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint("Error Supabase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detector BlueCharm"),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _institucionEncontrada
                  ? const Icon(Icons.domain, size: 100, color: Colors.indigo)
                  : const CircularProgressIndicator(color: Colors.indigo),

              const SizedBox(height: 40),

              Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),

              if (_institucionEncontrada) ...[
                const SizedBox(height: 20),
                Text(
                  _nombreInstitucion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    /* Navegar a la siguiente pantalla */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "ENTRAR",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
