import 'package:complex/complex.dart';

import 'operators.dart';

class MeasurableOperator extends MeasureableOperator2 {
  // final Operator operator;
  final Complex eigenvalue1;
  final Complex eigenvalue2;

  MeasurableOperator({Operator operator, this.eigenvalue1, this.eigenvalue2}):
  super(operator: operator, eigenvalues: [eigenvalue1, eigenvalue2]);
}

class MeasureableOperator2 {
  final Operator operator;
  final List<Complex> eigenvalues;

  MeasureableOperator2({this.operator, this.eigenvalues});
}

final double pi = 3.141592653589793238462643383279502884197169399375105820974944;
final mx = MeasurableOperator(operator: X, eigenvalue1: Complex.ONE, eigenvalue2: -Complex.ONE);
final my = MeasurableOperator(operator: Y, eigenvalue1: Complex.ONE, eigenvalue2: -Complex.ONE);
final mz = MeasurableOperator(operator: Z, eigenvalue1: Complex.ONE, eigenvalue2: -Complex.ONE);
final mh = MeasurableOperator(operator: H, eigenvalue1: Complex.ONE, eigenvalue2: -Complex.ONE);
final mrx = (double theta) => MeasurableOperator(
  operator: rx(theta), 
  eigenvalue1: Complex.polar(1, theta / 2), 
  eigenvalue2: Complex.polar(1, -theta / 2)
);
final mry = (double theta) => MeasurableOperator(
  operator: ry(theta), 
  eigenvalue1: Complex.polar(1, theta / 2), 
  eigenvalue2: Complex.polar(1, -theta / 2)
);
final mrz = (double theta) => MeasurableOperator(
  operator: rz(theta), 
  eigenvalue1: Complex.polar(1, theta / 2), 
  eigenvalue2: Complex.polar(1, -theta / 2)
);

enum Measurement {
  Zero,
  One
}
