import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Para el micro
import 'package:flutter/services.dart'; // Para la vibración

////////////////////////////// PANTALLA GUÍA ESPECÍFICA //////////////////////////////
class PantallaGuiaEspecifica extends StatefulWidget {
  const PantallaGuiaEspecifica({super.key});

  @override
  State<PantallaGuiaEspecifica> createState() => _PantallaGuiaEspecificaState();
}

class _PantallaGuiaEspecificaState extends State<PantallaGuiaEspecifica> {
  final TextEditingController _buscadorCtrl = TextEditingController();

  // Variables para el micrófono
  final SpeechToText _speechToText = SpeechToText();
  bool _elMicrofonoEstaListo = false;
  bool _escuchando = false;

  @override
  void initState() {
    super.initState();
    _inicializarMicrofono();
  }

  // Función para encender el motor de voz
  void _inicializarMicrofono() async {
    _elMicrofonoEstaListo = await _speechToText.initialize(
      onError: (error) => print('Error de voz: $error'),
      onStatus: (status) => print('Estado de voz: $status'),
    );
    setState(() {}); // Actualiza la pantalla si ya está listo
  }

  /// Función que se ejecuta al mantener presionado el botón
  void _empezarAEscuchar() async {
    if (_elMicrofonoEstaListo) {
      HapticFeedback.heavyImpact(); // 📳 ¡VIBRA FUERTE AL EMPEZAR!
      setState(() => _escuchando = true);

      // Mensaje más directo y universal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escuchando destino...')));

      await _speechToText.listen(
        onResult: (resultado) {
          setState(() {
            _buscadorCtrl.text = resultado.recognizedWords;
          });
        },
        localeId: 'es_ES',
      );
    }
  }

  // Función para detener la grabación
  void _detenerEscucha() async {
    HapticFeedback.lightImpact(); // 📳 ¡VIBRA SUAVE AL TERMINAR!
    await _speechToText.stop();
    setState(() => _escuchando = false);

    if (_buscadorCtrl.text.isNotEmpty) {
      // Mensaje claro y directo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destino seleccionado: ${_buscadorCtrl.text}')),
      );
    }
  }

  Widget _construirDestinoRapido(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          _buscadorCtrl.text = titulo;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calculando ruta hacia $titulo...')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF0D47A1), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icono, size: 35, color: const Color(0xFF0D47A1)),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF0D47A1)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '¿A dónde vamos?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _buscadorCtrl,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Escribe tu destino',
                labelStyle: const TextStyle(fontSize: 18),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Color(0xFF0D47A1),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 30, color: Colors.grey),
                  onPressed: () => _buscadorCtrl.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF0D47A1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 👇 DISEÑO MEJORADO: Todo en un solo bloque visual
            Semantics(
              label: 'Botón de dictado por voz. Requiere internet.',
              hint: 'Mantén presionado para decir tu destino',
              button: true,
              child: GestureDetector(
                onTapDown: (_) => _empezarAEscuchar(),
                onTapUp: (_) => _detenerEscucha(),
                onTapCancel: () => _detenerEscucha(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Cambia a rojo cuando escuchas, si no, es azul ITCA
                    color: _escuchando ? Colors.red : const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: _escuchando
                            ? Colors.red.withOpacity(0.4)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _escuchando ? Icons.mic : Icons.mic_none,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dictar destino por voz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Mantén presionado (Requiere internet)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Destinos Frecuentes:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            _construirDestinoRapido('Secretaría', Icons.business_center),
            _construirDestinoRapido('Laboratorio de Sistemas', Icons.computer),
            _construirDestinoRapido('Baños Principales', Icons.wc),
            _construirDestinoRapido('Biblioteca', Icons.menu_book),
          ],
        ),
      ),
    );
  }
}
