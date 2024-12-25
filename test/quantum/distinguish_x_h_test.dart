import 'dart:math';

import 'package:complex/complex.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/quantum/bank.dart';
import 'package:quantum_emulator/quantum/measurable_operator.dart';
import 'package:quantum_emulator/quantum/operators.dart';

void main() {
  group(
      'Playground Qubits tests -- these tests assert nothing and will add assertions later',
      () {
    test('test', () {
      final bank = Bank.create();
      final qs = bank.borrowQubits(length: 2);
      bank.operate(target: qs[0], operator: X);
      bank.operate(target: qs[1], operator: H);
      bank.operate(target: qs[0], operator: H);
      bank.operate(target: qs[1], operator: X);
      print(bank);

      bank.operate(target: qs[1], operator: H);
      bank.operate(target: qs[0], operator: H);
      bank.operate(target: qs[1], operator: H);
      bank.operate(target: qs[0], operator: X);
      print(bank);

      bank.operate(target: qs[0], operator: X);
      bank.operate(target: qs[1], operator: X);
      bank.operate(target: qs[0], operator: X);
      bank.operate(target: qs[1], operator: X);
      print(bank);

      bank.release(qubits: qs);
    });
  });
}
