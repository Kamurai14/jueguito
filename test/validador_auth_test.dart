import 'package:flutter_test/flutter_test.dart';
import 'package:jueguito/utils/validador_auth.dart';

void main() {
  group('Pruebas de Seguridad en Registro', () {
    test('Falla si hay campos vacíos', () {
      expect(ValidadorAuth.validarRegistro('', '123456', '123456'), 
          'Por favor, llena todos los campos obligatorios.');
    });

    test('Falla si el usuario tiene menos de 3 o más de 15 caracteres', () {
      expect(ValidadorAuth.validarRegistro('ab', '123456', '123456'), 
          'El usuario debe tener entre 3 y 15 caracteres.');
      expect(ValidadorAuth.validarRegistro('este_usuario_es_demasiado_largo', '123456', '123456'), 
          'El usuario debe tener entre 3 y 15 caracteres.');
    });

    test('Falla si el usuario tiene espacios o símbolos especiales', () {
      expect(ValidadorAuth.validarRegistro('juan perez', '123456', '123456'), 
          'El usuario no puede contener espacios ni símbolos especiales.');
      expect(ValidadorAuth.validarRegistro('juan@', '123456', '123456'), 
          'El usuario no puede contener espacios ni símbolos especiales.');
    });

    test('Falla si la contraseña tiene menos de 6 caracteres', () {
      expect(ValidadorAuth.validarRegistro('juan_123', '12345', '12345'), 
          'La contraseña debe tener al menos 6 caracteres.');
    });

    test('Falla si las contraseñas no coinciden', () {
      expect(ValidadorAuth.validarRegistro('juan_123', '123456', '654321'), 
          'Las contraseñas no coinciden.');
    });

    test('Pasa la validación (retorna null) con datos correctos', () {
      expect(ValidadorAuth.validarRegistro('juan_123', '123456', '123456'), null);
    });
  });
}