import 'package:complex/complex.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/quantum/bank.dart';

void main() {
  group("task 5", () {
    final bank = Bank.create();
    void task(List<Qubit> qubits) {
      bank.operate(target:qubits[0], operator: H);
      bank.operate(target:qubits[1], operator: H);
      bank.operate(target:qubits[0], controls: [qubits[1]], operator: Y);
      bank.operate(target:qubits[1], controls: [qubits[0]], operator: Z);
      bank.operate(target:qubits[0], operator: Z);
      bank.operate(target:qubits[1], operator: Z);
    }
    test("|00> -> (|00> + i|01> - |10> - i|11>)/2", () {
      final qubits = bank.borrowQubits(length: 2);
      task(qubits);
      expect([
        Complex(0.5),
        Complex(-0.5),
        Complex(0, 0.5),
        Complex(0, -0.5)
      ], bank);
    });
  });
}