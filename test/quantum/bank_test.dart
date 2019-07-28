
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/quantum/bank.dart';

class Generator {
  final List<double> elements;
  int _index = -1;
  Generator({this.elements});

  double nextDouble() {
    _index = (_index + 1) % elements.length;
    return elements[_index];
  }
}

void main() {
  group('Playground Qubits tests -- these tests assert nothing and will add assertions later', () {
    test('test', () {
      final bank = Bank.create();
      final qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: H);
      print("1: " + bank.toString());
      bank.borrowQubits(length: 1);
      print("2: " + bank.toString());
      bank.borrowQubits(length: 1);
      print("3: " + bank.toString());
    });

    test('test Y', () {
      Bank bank = Bank.create();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Y);
      expect(bank.toString(), "(0.0, 1.0) |1>");
      
      bank = Bank.create();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Y);
      expect(bank.toString(), "(0.0, -1.0) |0>");
    });

    test('test Z', () {
      Bank bank = Bank.create();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Z);
      expect(bank.toString(), "(1.0, 0.0) |0>");
      
      bank = Bank.create();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Z);
      expect(bank.toString(), "(-1.0, -0.0) |1>");
    });

    test('test operators', () {
      final bank = Bank.create();
      final qubits = bank.borrowQubits(length:3);
      print(bank.toString());
      bank.operate(target: qubits[0], operator: H);
      print(bank.toString());
      bank.operate(target: qubits[1], operator: X);
      print(bank.toString());
      bank.operate(target: qubits[1], operator: H);
      print(bank.toString());
      bank.borrowQubits(length:2);
      print(bank.toString());
    });

    test('test controlled operators', () {
      final bank = Bank.create();
      final qubits = bank.borrowQubits(length:3);
      print(bank.toString());
      bank.operate(target: qubits[0], controls: [qubits[1]], operator: H);
      print(bank.toString());
      bank.operate(target: qubits[0], operator: H);
      print(bank.toString());
      bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
      print(bank.toString());
      bank.operate(target: qubits[1], operator: H);
      print(bank.toString());
      bank.borrowQubits(length:2);
      print(bank.toString());
    });
  });

  group('index iterable tests', () {

    test('index iterable creation length 1', () {
      final indexes01 = indexes(target: 0, length: 1);
      expect(indexes01, [IntTuple(zero: 0, one: 1)]);
    });
    test('index iterable creation length 3', () {
      final indexes03 = indexes(target: 0, length: 3);
      expect(indexes03, [IntTuple(zero: 0, one: 4),IntTuple(zero: 1, one: 5),IntTuple(zero: 2, one: 6),IntTuple(zero: 3, one: 7),]);

      expect(
        indexes(target: 1, length: 3), 
        [IntTuple(zero: 0, one: 2),IntTuple(zero: 1, one: 3),IntTuple(zero: 4, one: 6),IntTuple(zero: 5, one: 7),])
      ;
      expect(
        indexes(target: 2, length: 3), 
        [IntTuple(zero: 0, one: 1),IntTuple(zero: 2, one: 3),IntTuple(zero: 4, one: 5),IntTuple(zero: 6, one: 7),]
      );

      expect(
        indexes(controls: [1], target: 2, length: 3),
        [IntTuple(zero: 2, one: 3), IntTuple(zero: 6, one: 7), ]
      );
      expect(
        indexes(controls: [0], target: 2, length: 3),
        [IntTuple(zero: 4, one: 5), IntTuple(zero: 6, one: 7), ]
      );
      expect(
        indexes(controls: [0,1], target: 2, length: 3),
        [IntTuple(zero: 6, one: 7),]
      );
      expect(
        indexes(controls: [0,2], target: 1, length: 3),
        [IntTuple(zero: 5, one: 7),]
      );
    });

    test('index iterable creation length 4', () {
      expect(
        indexes(controls: [0,2], target: 1, length: 4),
        [IntTuple(zero: 10, one: 14),IntTuple(zero: 11, one: 15),]
      );
    });
  });

  group('H measurements', () {
    test('zero measurement', () {
      final list = range(0, 499).map((f) => f / 1000.0).toList();
      final generator = Generator(elements: list);

      final bank = Bank(generator: generator.nextDouble);
      final qubit = bank.borrowQubits(length: 1)[0];
      for (final ix in list) {
        bank.operate(target: qubit, operator: H);
        bank.measure(target: qubit);
        expect(bank.toString(), "(1.0, 0.0) |0>");
      }
    });

    test('zero measurement', () {
      final list = range(501, 1000).map((f) => f / 1000.0).toList();
      final generator = Generator(elements: list);

      final bank = Bank(generator: generator.nextDouble);
      final qubit = bank.borrowQubits(length: 1)[0];
      for (final _ in list) {
        bank.operate(target: qubit, operator: H);
        bank.measure(target: qubit);
        bank.operate(target: qubit, operator: X);
        expect(bank.toString(), "(1.0, 0.0) |0>");
      }
    });
  });

  group("Measurements", () {
    test("measurement playground", () {
      final bank = Bank.create(0);
      final qubits = bank.borrowQubits(length:2);

      print(bank.toString());
      bank.measure(target:qubits[0]);
      print(bank.toString());
      bank.operate(target: qubits[0], operator: H);  
      print(bank.toString());    
      bank.measure(target:qubits[0]);
      print(bank.toString());

      bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
      print(bank.toString());
      bank.measure(target:qubits[1]);
      print(bank.toString());

      bank.measurement(targets: qubits, operators: [Z, Z]);
      print(bank.toString());

      bank.measurement(targets: qubits, operators: [Z, X]);
      print(bank.toString());
    });
  });
}