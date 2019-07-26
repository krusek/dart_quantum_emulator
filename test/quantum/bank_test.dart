
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/quantum/bank.dart';

void main() {
  group('Playground Qubits tests -- these tests assert nothing and will add assertions later', () {
    test('test', () {
      final bank = Bank();
      bank.borrowQubits(length: 1);
      bank.H();
      print("1: " + bank.toString());
      bank.borrowQubits(length: 1);
      print("2: " + bank.toString());
      bank.borrowQubits(length: 1);
      print("3: " + bank.toString());
    });

    test('test Y', () {
      Bank bank = Bank();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Y);
      print("|0> -> " + bank.toString());
      
      bank = Bank();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Y);
      print("|1> -> " + bank.toString());
    });

    test('test Z', () {
      Bank bank = Bank();
      Qubit qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: Z);
      print("|0> -> " + bank.toString());
      
      bank = Bank();
      qubit = bank.borrowQubits(length: 1)[0];
      bank.operate(target: qubit, operator: X);
      bank.operate(target: qubit, operator: Z);
      print("|1> -> " + bank.toString());
    });

    test('test operators', () {
      final bank = Bank();
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
      final bank = Bank();
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
}