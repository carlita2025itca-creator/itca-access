import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class SeleccionEdificioScreen extends StatefulWidget {
  const SeleccionEdificioScreen({super.key});

  @override
  State<SeleccionEdificioScreen> createState() =>
      _SeleccionEdificioScreenState();
}

class _SeleccionEdificioScreenState extends State<SeleccionEdificioScreen> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _btStateSubscription;

  bool _isBluetoothOn = false;
  bool _escaneando = false;
  bool _institucionEncontrada = false;

  String _mensaje =
      "Por favor, escanea para buscar un punto de identificación y así iniciar tu recorrido en la app.";
  String _nombreInstitucion = "";

  @override
  void initState() {
    super.initState();
    // Escuchamos en tiempo real si el usuario apaga o prende el Bluetooth
    if (!kIsWeb) {
      _btStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          setState(() {
            _isBluetoothOn = state == BluetoothAdapterState.on;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _btStateSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // ================= 1. ACCIÓN DEL BOTÓN ESCANEAR =================
  void _botonEscanearPresionado() async {
    if (kIsWeb) {
      _mostrarAlerta(
        "Atención",
        "El escaneo Bluetooth no está disponible en la versión web.",
      );
      return;
    }

    // --- PEDIR PERMISOS A ANDROID ANTES DE ESCANEAR ---
    if (defaultTargetPlatform == TargetPlatform.android) {
      Map<Permission, PermissionStatus> estados = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      // Si el usuario denegó los permisos, detenemos el proceso
      if (estados[Permission.location]!.isDenied ||
          estados[Permission.bluetoothScan]!.isDenied) {
        _mostrarAlerta(
          "Permisos necesarios",
          "Necesitamos acceso a la ubicación y dispositivos cercanos para detectar la entrada. Por favor, acéptalos.",
        );
        return;
      }
    }
    // ---------------------------------------------------------

    if (!_isBluetoothOn) {
      _mostrarAlerta(
        "Bluetooth apagado",
        "Para poder ubicarte en el edificio, necesitamos que enciendas tu Bluetooth. ¡Prometemos no gastar mucha batería!",
      );
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint("El usuario debe encenderlo manualmente.");
      }
      return;
    }

    // Si tiene permisos y el Bluetooth está encendido, iniciamos la búsqueda
    setState(() {
      _escaneando = true;
      _mensaje = "Buscando señal cercana... Acércate a un punto de acceso.";
    });

    _iniciarEscaneo();
  }

  // ================= 2. LÓGICA DE ESCANEO (MODO RAYOS X) =================
  Future<void> _iniciarEscaneo() async {
    try {
      // 1. Apagamos el radar y le damos MEDIO SEGUNDO a Android para respirar
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Configuramos qué hacer cuando encuentre algo
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          String rawId = r.device.remoteId.str.toUpperCase();
          String macFormateada = _formatearMAC(rawId);

          // RAYOS X: Imprimimos en la consola de VS Code TODO lo que el Bluetooth atrapa
          debugPrint("📡 Viendo MAC: $macFormateada | Señal: ${r.rssi}");

          if (!_institucionEncontrada) {
            // Hacemos la consulta
            _consultarSupabase(macFormateada);
          }
        }
      });

      // 3. ¡Arrancamos el escaneo!
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      // 4. ¡EL TRUCO ESTÁ AQUÍ!
      // Le decimos al código que ESPERE hasta que el escáner se apague de verdad
      await FlutterBluePlus.isScanning.where((val) => val == false).first;

      // 5. Una vez que se detiene el escaneo, revisamos si encontró algo
      if (!_institucionEncontrada && mounted) {
        setState(() {
          _escaneando = false;
          _mensaje =
              "No encontramos un punto cerca. Por favor, acércate a la entrada y vuelve a intentar.";
        });
      }
    } catch (e) {
      debugPrint("Error catastrófico de Bluetooth: $e");
      if (mounted) {
        setState(() {
          _escaneando = false;
          _mensaje = "Hubo un error al usar el Bluetooth. Intenta de nuevo.";
        });
      }
    }
  }

  // --- FUNCIÓN RECUPERADA ---
  String _formatearMAC(String mac) {
    if (mac.contains(':')) return mac;
    return mac
        .replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)}:")
        .substring(0, 17);
  }

  // --------------------------
  // ---------------------------------------------------
  // ================= 3. CONSULTA A SUPABASE (DOBLE PASO) =================
  Future<void> _consultarSupabase(String mac) async {
    try {
      debugPrint("🔍 Consultando Supabase por la MAC: $mac");

      // PASO 1: Buscamos SOLAMENTE en la tabla 'beacons'
      final beaconData = await Supabase.instance.client
          .from('beacons')
          .select() // Quitamos el JOIN problemático
          .eq('mac_address', mac)
          .maybeSingle();

      if (beaconData != null && mounted) {
        // ¡Encontramos el pasillo/entrada! Apagamos el radar.
        FlutterBluePlus.stopScan();
        debugPrint("✅ Beacon encontrado: ${beaconData['nombre']}");

        // PASO 2: Extraemos el ID y buscamos el nombre de la institución
        String idDeLaInstitucion = beaconData['institucion_id'];
        String nombreFinal = "Institución Identificada"; // Nombre por defecto

        try {
          final instData = await Supabase.instance.client
              .from('instituciones')
              .select('nombre')
              .eq('id', idDeLaInstitucion) // Buscamos en la otra tabla
              .maybeSingle();

          if (instData != null) {
            nombreFinal = instData['nombre'];
          }
        } catch (errorRelacion) {
          debugPrint(
            "⚠️ No se pudo obtener el nombre de la institución: $errorRelacion",
          );
        }

        // Actualizamos la pantalla
        setState(() {
          _institucionEncontrada = true;
          _escaneando = false;
          _nombreInstitucion = nombreFinal;
          _mensaje = "¡Te hemos ubicado con éxito!";
        });
      } else {
        debugPrint("⚠️ La MAC $mac no está registrada en la tabla beacons.");
      }
    } catch (e) {
      // ESTO ES VITAL: Si hay un error, lo imprimimos en rojo en la consola
      debugPrint("❌ ERROR CRÍTICO SUPABASE: $e");
    }
  }

  // ================= WIDGET DE ALERTAS (RECUPERADO) =================
  void _mostrarAlerta(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(contenido, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // ================= 4. INTERFAZ VISUAL =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Punto de Acceso",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono gigante
              Icon(
                _institucionEncontrada
                    ? Icons.domain_verification
                    : Icons.bluetooth_searching,
                size: 120,
                color: _institucionEncontrada
                    ? Colors.green
                    : const Color(0xFF1A237E),
              ),

              const SizedBox(height: 30),

              // Mensaje empático
              Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  height: 1.5, // Hace que el texto sea más fácil de leer
                ),
              ),

              const SizedBox(height: 50),

              // VISTAS DINÁMICAS
              if (_institucionEncontrada) ...[
                Text(
                  "Bienvenido a:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
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
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a la siguiente pantalla (Ej: Mapa o Menú)
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "INGRESAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ] else if (_escaneando) ...[
                // Cargando
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1A237E),
                    strokeWidth: 5,
                  ),
                ),
              ] else ...[
                // Botón Gigante de Escaneo
                ElevatedButton.icon(
                  onPressed: _botonEscanearPresionado,
                  icon: const Icon(Icons.radar, color: Colors.white, size: 28),
                  label: const Text(
                    "ESCANEAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
