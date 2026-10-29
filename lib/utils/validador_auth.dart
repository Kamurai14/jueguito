class ValidadorAuth {
  static String? validarRegistro(String usuario, String password, String confirmarPassword) {
    if (usuario.isEmpty || password.isEmpty) return 'Por favor, llena todos los campos obligatorios.';
    
    if (usuario.length < 3 || usuario.length > 15) {
      return 'El usuario debe tener entre 3 y 15 caracteres.';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usuario)) {
      return 'El usuario no puede contener espacios ni símbolos especiales.';
    }
    
    if (password.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    
    if (password != confirmarPassword) return 'Las contraseñas no coinciden.';
    
    return null; // null significa que todo está correcto
  }
}