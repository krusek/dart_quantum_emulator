
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/quantum/bank.dart';

void main() {
  group('basic gates', () {
    Bank bank;
    setUp(() {
      bank = Bank.create();
    });
    group("task 1 -- |0> -> |1>, |1> -> |0>", () {
      Qubit qubit;
      setUp(() {
        qubit = bank.borrowQubits(length: 1)[0];
      });

      void task(Qubit qubit) {
        bank.operate(target: qubit, operator: X);
      }

      test("|0> -> |1>", () {
        task(qubit);
        expect(bank.toString(), "(1.0, 0.0) |1>");
      });
      test("|1> -> |0>", () {
        task(qubit);
        task(qubit);
        expect(bank.toString(), "(1.0, 0.0) |0>");
      });
    });
    group("task 2 -- |0> -> |+>, |1> -> |->", () {
      Qubit qubit;
      setUp(() {
        qubit = bank.borrowQubits(length: 1)[0];
      });
      
      void task(Qubit qubit) {
        bank.operate(target: qubit, operator: H);
      }

      test("task 2 -- |0> -> |+>,", () {
        task(qubit);
        expect(bank.toString(), "(0.7071067811865475, 0.0) |0> + (0.7071067811865475, 0.0) |1>");
      });

      test("task 2 -- |1> -> |->", () {
        bank.operate(target: qubit, operator: X);
        task(qubit);
        expect(bank.toString(), "(0.7071067811865475, 0.0) |0> + (-0.7071067811865475, 0.0) |1>");
      });
    });

    group("task 3 - sign flip", () {
      Qubit qubit;
      setUp(() {
        qubit = bank.borrowQubits(length: 1)[0];
      });

      void task(Qubit qubit) {
        bank.operate(target: qubit, operator: Z);
      }

      test("|+> -> |->", () {
        bank.operate(target: qubit, operator: H);
        task(qubit);
        expect(bank.toString(), "(0.7071067811865475, 0.0) |0> + (-0.7071067811865475, -0.0) |1>");
      });

      test("|+> -> |->", () {
        bank.operate(target: qubit, operator: H);
        task(qubit);
        task(qubit);
        expect(bank.toString(), "(0.7071067811865475, 0.0) |0> + (0.7071067811865475, 0.0) |1>");
      });
    });

    group("task 2.3 - ", () {
      void task(List<Qubit> qubits) {
        bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
        bank.operate(target: qubits[0], controls: [qubits[1]], operator: X);
        bank.operate(target: qubits[1], controls: [qubits[0]], operator: X);
      }
      
      test("swap |01> and |10>", () {
        List<Qubit> qubits = bank.borrowQubits(length: 2);
        task(qubits);
        expect(bank.toString(), "(1.0, 0.0) |00>");

        bank.operate(target: qubits[0], operator: X);
        task(qubits);
        expect(bank.toString(), "(1.0, 0.0) |01>");
        task(qubits);
        expect(bank.toString(), "(1.0, 0.0) |10>");


        bank.operate(target: qubits[1], operator: X);
        task(qubits);
        expect(bank.toString(), "(1.0, 0.0) |11>");
      });
    });
  });
}