class SesionUsuario {
  static int? idActual;
  static String? nombres;
  static String? apellidos;
  static String? cedula;
  static String? correo;
  static String? fotoUrl; // Para cuando agregues la foto de perfil

  // Una pequeña función para limpiar la memoria si el usuario "Cierra Sesión"
  static void cerrarSesion() {
    idActual = null;
    nombres = null;
    apellidos = null;
    cedula = null;
    correo = null;
    fotoUrl = null;
  }
}
