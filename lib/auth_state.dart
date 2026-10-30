abstract class AuthState {}

// Pantalla de carga buscando el token
class AuthInicial extends AuthState {}

// No hay sesión, mostramos el Login
class AuthNoAutenticado extends AuthState {}

// Hay sesión con un usuario real
class AuthAutenticado extends AuthState {
  final String usuario;
  AuthAutenticado(this.usuario);
}

// Modo sin cuenta (Invitado)
class AuthInvitado extends AuthState {}