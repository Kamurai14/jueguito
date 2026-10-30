abstract class AuthEvent {}

class VerificarSesion extends AuthEvent {}

class IniciarSesionEvent extends AuthEvent {
  final String usuario;
  IniciarSesionEvent(this.usuario);
}

class EntrarComoInvitado extends AuthEvent {}

class CerrarSesionEvent extends AuthEvent {}