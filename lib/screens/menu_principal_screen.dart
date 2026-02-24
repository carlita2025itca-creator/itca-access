import 'package:flutter/material.dart';
// 👇 Asegúrate de que el nombre del proyecto coincida con el tuyo
import 'package:itca_access/screens/guia_especifica_screen.dart';

////////////////////////////// PANTALLA MENÚ PRINCIPAL //////////////////////////////
class PantallaMenu extends StatelessWidget {
  const PantallaMenu({super.key});

  Widget _construirTarjetaOpcion(
    BuildContext context, {
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color colorFondo,
    required Color colorTexto,
    required VoidCallback alPresionar,
  }) {
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 45, color: colorTexto),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              descripcion,
              style: TextStyle(
                fontSize: 16,
                color: colorTexto.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'ITCA Access',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Cómo deseas navegar por el instituto hoy? Elige una opción:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // 1. TARJETA DE GUÍA GENERAL
            _construirTarjetaOpcion(
              context,
              titulo: 'Guía General',
              descripcion:
                  'Modo exploración. Mientras caminas, la aplicación te irá indicando en voz alta por qué pasillos, laboratorios o lugares estás pasando.',
              icono: Icons.explore,
              colorFondo: const Color(0xFF00796B),
              colorTexto: Colors.white,
              alPresionar: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iniciando radar de Guía General...'),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // 2. TARJETA DE GUÍA ESPECÍFICA
            _construirTarjetaOpcion(
              context,
              titulo: 'Guía Específica',
              descripcion:
                  'Ruta directa. Escribe o dicta a qué lugar exacto del instituto deseas ir, y te guiaremos paso a paso hasta tu destino.',
              icono: Icons.directions_walk,
              colorFondo: const Color(0xFFF0C14B),
              colorTexto: Colors.black87,
              alPresionar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // 👇 AQUÍ CAMBIAMOS EL NOMBRE PARA QUE COINCIDA
                    builder: (context) => const PantallaGuiaEspecifica(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // 3. BOTÓN: CONFIGURACIÓN DE PERFIL
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo configuración...')),
                );
              },
              icon: const Icon(
                Icons.settings,
                color: Color(0xFF0D47A1),
                size: 28,
              ),
              label: const Text(
                'Configuración de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
