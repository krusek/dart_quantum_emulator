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
      expect(bank.toString(), "(0.49999999999999994, 0.0) |00> + (-0.49999999999999994, -0.0) |10> + (-0.0, 0.49999999999999994) |01> + (-0.0, -0.49999999999999994) |11>");
    });
  });
}