import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/servicios/servicio_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ServicioAuth _servicioAuth = ServicioAuth();

  AuthBloc() : super(AuthInicial()) {
    on<VerificarSesion>(_onVerificarSesion);
    on<IniciarSesionEvent>(_onIniciarSesion);
    on<EntrarComoInvitado>(_onEntrarComoInvitado);
    on<CerrarSesionEvent>(_onCerrarSesion);
  }

  void _onVerificarSesion(VerificarSesion event, Emitter<AuthState> emit) async {
    // Simulamos un pequeño tiempo de carga para que se vea el logo
    await Future.delayed(const Duration(milliseconds: 800));
    
    final tieneSesion = await _servicioAuth.tieneSesionActiva();
    if (tieneSesion) {
      final usuario = await _servicioAuth.obtenerUsuarioActual() ?? 'Jugador';
      emit(AuthAutenticado(usuario));
    } else {
      emit(AuthNoAutenticado());
    }
  }

  void _onIniciarSesion(IniciarSesionEvent event, Emitter<AuthState> emit) {
    emit(AuthAutenticado(event.usuario));
  }

  void _onEntrarComoInvitado(EntrarComoInvitado event, Emitter<AuthState> emit) {
    emit(AuthInvitado());
  }

  void _onCerrarSesion(CerrarSesionEvent event, Emitter<AuthState> emit) async {
    await _servicioAuth.cerrarSesion();
    emit(AuthNoAutenticado());
  }
}