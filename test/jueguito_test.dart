import 'package:test/test.dart';
import 'package:jueguito/jueguito.dart';

void main() {
  group('Validación de canInsertUnique', () {
    
    test('1. Lista vacía permite insertar un número nuevo', () {
      expect(canInsertUnique([], 5), isTrue);
    });

    test('2. Lista única y número nuevo devuelve verdadero', () {
      expect(canInsertUnique([1, 2, 3], 4), isTrue);
    });

    test('3. Número que ya existe en la lista devuelve falso', () {
      expect(canInsertUnique([1, 2, 3], 3), isFalse);
    });

    test('4. Lista original con duplicados devuelve falso', () {
      expect(canInsertUnique([1, 2, 2], 4), isFalse);
    });

    test('5. Duplicados en lista original y número a insertar duplicado devuelve falso', () {
      expect(canInsertUnique([1, 99, 99], 99), isFalse);
    });
  
  });

  group('Validación de color Rojo (RedValidator)', () {
    final redRule = RedValidator();

    test('1. Lista vacía permite insertar un número nuevo', () {
      expect(redRule.canInsert([], 5), isTrue);
    });

    test('2. Lista única y número nuevo devuelve verdadero', () {
      expect(redRule.canInsert([1, 2, 3], 4), isTrue);
    });

    test('3. Número que ya existe en la lista devuelve falso', () {
      expect(redRule.canInsert([1, 2, 3], 3), isFalse);
    });

    test('4. Lista original con duplicados devuelve falso', () {
      expect(redRule.canInsert([1, 2, 2], 4), isFalse);
    });
  });

  group('Validación de color Amarillo (YellowValidator)', () {
    final yellowRule = YellowValidator();

    test('1. Lista vacía permite insertar un número nuevo', () {
      expect(yellowRule.canInsert([], 9), isTrue);
    });

    test('2. Lista única y número nuevo devuelve verdadero', () {
      expect(yellowRule.canInsert([7, 8], 9), isTrue);
    });

    test('3. Número que ya existe en la lista devuelve falso', () {
      expect(yellowRule.canInsert([7, 8, 9], 9), isFalse);
    });

    test('4. Lista original con duplicados devuelve falso', () {
      expect(yellowRule.canInsert([7, 7], 9), isFalse);
    });
  });
  group('Validación de color Azul (BlueValidator)', () {
    
    test('1. Acepta el primer número que entra y lo recuerda', () {
      final blueRule = BlueValidator();
      
      expect(blueRule.canInsert([1, 2, 3], 5), isTrue);
    });

    test('2. Acepta el número en turnos siguientes si es igual al primero', () {
      final blueRule = BlueValidator();
      
      blueRule.canInsert([1, 2, 3], 5);
      
      expect(blueRule.canInsert([9, 8, 7], 5), isTrue);
    });

    test('3. Rechaza el número en turnos siguientes si es diferente al primero', () {
      final blueRule = BlueValidator();
      
      blueRule.canInsert([1, 2, 3], 5);
      
      expect(blueRule.canInsert([4, 5, 6], 4), isFalse);
    });

    test('4. El reset permite aceptar un número nuevo', () {
      final blueRule = BlueValidator();
      
      blueRule.canInsert([], 5);
      
      blueRule.reset();
      
      expect(blueRule.canInsert([], 10), isTrue);
    });

  });

  group('Validación de color Verde (GreenValidator)', () {
    
    test('1. Acepta un número en una lista vacía', () {
      final greenRule = GreenValidator();
      
      expect(greenRule.canInsert([], 5), isTrue);
    });

    test('2. Acepta un número nuevo que no está en la lista', () {
      final greenRule = GreenValidator();
      
      expect(greenRule.canInsert([1, 2, 3], 4), isTrue);
    });

    test('3. Acepta un número repetido (que ya existe en la lista)', () {
      final greenRule = GreenValidator();
      
      expect(greenRule.canInsert([1, 2, 3], 3), isTrue);
    });

    test('4. Acepta un número en una lista que ya tiene múltiples duplicados', () {
      final greenRule = GreenValidator();
      
      expect(greenRule.canInsert([99, 99, 99], 99), isTrue);
    });

  });

  group('Validación del color morado', (){

    test('1. Acepta el primer numero', (){
      final PurpleRule = PurpleValidator();

      expect(PurpleRule.canInsert([], 3), isTrue);
    });

    test('2. Acepta el primer número repetidas veces', (){
      final PurpleRule = PurpleValidator();

      PurpleRule.canInsert([], 3);
      expect(PurpleRule.canInsert([], 3), isTrue);
      expect(PurpleRule.canInsert([1,2], 3), isTrue);
    });

    test('3. Acepta un segundo número diferente', (){
      final PurpleRule = PurpleValidator();

      PurpleRule.canInsert([], 3);
      expect(PurpleRule.canInsert([], 5), isTrue);
    });

    test('4. Rechaza un tercer número diferente pero sigue aceptando los primeros dos', () {
      final purpleRule = PurpleValidator();
      
      purpleRule.canInsert([], 3); 
      purpleRule.canInsert([], 5); 

      expect(purpleRule.canInsert([], 8), isFalse);
      expect(purpleRule.canInsert([], 3), isTrue);
      expect(purpleRule.canInsert([], 5), isTrue);
    });

    test('5. El reset limpia la memoria y permite empezar de nuevo', () {
      final purpleRule = PurpleValidator();
      
      purpleRule.canInsert([], 3);
      purpleRule.canInsert([], 5);
      
      expect(purpleRule.canInsert([], 8), isFalse); 

      purpleRule.reset();

      expect(purpleRule.canInsert([], 8), isTrue); 
    });
  });

  group('Extracción por Regiones (StatusGridData)', () {
    late StatusGridData gridData;

    setUp(() {
      gridData = StatusGridData();
    });

    test('1. Extrae correctamente los valores de una región (Ej. red1)', () {
      final red1Values = gridData.getValuesByRegion(GridRegion.red1);
      expect(red1Values, equals([99, 42]));
    });

    test('2. Extrae correctamente cuando solo hay un valor en la región', () {
      final yellow5Values = gridData.getValuesByRegion(GridRegion.yellow5);
      expect(yellow5Values, equals([15]));
    });

    test('3. Devuelve lista vacía si la región no tiene celdas', () {
      final yellow2Values = gridData.getValuesByRegion(GridRegion.yellow2);
      expect(yellow2Values, isEmpty);
    });
  });
}