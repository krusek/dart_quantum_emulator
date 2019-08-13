
import 'dart:math';

import 'package:complex/complex.dart';
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
      expect([sqrt1_2, sqrt1_2], bank);
      bank.borrowQubits(length: 1);
      expect([sqrt1_2, sqrt1_2], bank);
      bank.borrowQubits(length: 1);
      expect([sqrt1_2, sqrt1_2], bank);
    });

    test('test Y', () {
      Bank bank = Bank.create();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Y);
      expect({1: Complex.I}, bank);
      
      bank = Bank.create();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Y);
      expect([-Complex.I], bank);
    });

    test('test Z', () {
      Bank bank = Bank.create();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Z);
      expect([Complex.ONE], bank);
      
      bank = Bank.create();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Z);
      expect([Complex.ZERO, -Complex.ONE], bank);
    });

    test('test operators', () {
      final bank = Bank.create();
      final qubits = bank.borrowQubits(length:3);
      bank.operate(target: qubits[0], operator: H);
      expect([sqrt1_2, sqrt1_2], bank);
      bank.operate(target: qubits[1], operator: X);
      expect({2: sqrt1_2, 3: sqrt1_2}, bank);
      bank.operate(target: qubits[1], operator: H);
      expect([0.5, 0.5, -0.5, -0.5], bank);
      bank.borrowQubits(length:2);
      expect([0.5, 0.5, -0.5, -0.5], bank);
    });

    test('test controlled operators', () {
      final bank = Bank.create();
      final qubits = bank.borrowQubits(length:3);
      expect([1.0], bank);
      bank.operate(target: qubits[0], controls: [qubits[1]], operator: H);
      expect([1.0], bank);
      bank.operate(target: qubits[0], operator: H);
      expect([sqrt1_2, sqrt1_2], bank);
      bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
      expect({0:sqrt1_2, 3:sqrt1_2}, bank);
      bank.operate(target: qubits[1], operator: H);
      expect({0:0.5, 1:0.5, 2:0.5, 3:-0.5}, bank);
      bank.borrowQubits(length:2);
      expect({0:0.5, 1:0.5, 2:0.5, 3:-0.5}, bank);
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
      for (final _ in list) {
        bank.operate(target: qubit, operator: H);
        bank.measure(target: qubit);
        expect([Complex.ONE], bank);
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
        expect([Complex.ONE,], bank);
      }
    });
  });

  group('rotation measurements', () {

    void assertOperation({MeasurableOperator measurable}) {
      final bank = Bank(debug: false, generator: Generator(elements: [0.0]).nextDouble);
      final qubits = bank.borrowQubits(length: 1);
      final m = bank.measurement(targets: qubits, operators: [measurable]);
      bank.operate(target: qubits[0], operator: measurable.operator);
      bank.operate(target: qubits[0], operator: ci(measurable.eigenvalue1));

      final bank2 = Bank(debug: false, generator: Generator(elements: [0.0]).nextDouble);
      final qubits2 = bank2.borrowQubits(length: 1);
      final m2 = bank2.measurement(targets: qubits2, operators: [measurable]);

      expect(m, m2);
      expect(bank, bank2);
    }

    test('Rx(theta) measurement', () {
      final theta = 3.1415926535/2;
      final measurable = mrx(theta);

      assertOperation(measurable: measurable);
    });
    test('Ry(theta) measurement', () {

      final theta = 3.1415926535/2;
      final measurable = mry(theta);

      assertOperation(measurable: measurable);
    });
    test('Rz(theta) measurement', () {

      final theta = 3.1415926535/2;
      final measurable = mrz(theta);

      assertOperation(measurable: measurable);
    });
  });

  group("Measurements", () {
    test("measurement playground", () {
      final bank = Bank.create(seed: 0);
      final qubits = bank.borrowQubits(length:2);

      bank.measure(target:qubits[0]);
      expect([1.0], bank);
      bank.operate(target: qubits[0], operator: H); 
      expect([sqrt1_2, sqrt1_2], bank);     
      var m = bank.measure(target:qubits[0]);
      expect({1:1.0}, bank);
      expect(m, Measurement.One);

      bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
      expect({3:1.0}, bank);
      
      m = bank.measure(target:qubits[1]);
      expect({3:1.0}, bank);
      expect(m, Measurement.One);
      
      m = bank.measurement(targets: qubits, operators: [mz, mz]);
      expect({3:1.0}, bank);
      expect(m, Measurement.Zero);

      m = bank.measurement(targets: qubits, operators: [mz, mx]);
      expect({1: sqrt1_2, 3: sqrt1_2}, bank);
      expect(m, Measurement.One);
    });
  });
}