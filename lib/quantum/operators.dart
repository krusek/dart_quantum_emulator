import 'dart:math';

import 'package:complex/complex.dart';
import 'package:quantum_emulator/linear_algebra/vector.dart';

final Operator Function(int) ospecial = (n) {
  return (input) => ComplexTuple(zero: input.zero, one: Complex.polar(1, 2 * pi / (n+1)) * input.one);
};

typedef Operator = ComplexTuple Function(ComplexTuple);

final Operator X = (input) => ComplexTuple(zero: input.one, one: input.zero);
final Operator Y = (input) => ComplexTuple(zero: -Complex.I * input.one, one: Complex.I * input.zero);
final Operator Z = (input) => ComplexTuple(zero: input.zero, one: -input.one);
final Operator H = (input) => ComplexTuple(zero: (input.zero + input.one) / sqrt(2.0), one: (input.zero - input.one) / sqrt(2.0));
final Operator I = (input) => ComplexTuple(zero: input.zero, one: input.one);
final Operator Function(double) ri = (theta) {
  return (input) {
    return ComplexTuple(
      zero: input.zero * Complex.polar(1, theta), 
      one: input.one * Complex.polar(1, theta),
    );
  };
};

final Operator Function(Complex) ci = (complex) {
  assert((complex.abs() - 1) < 1e-6);
  return (input) {
    return ComplexTuple(
      zero: input.zero * complex, 
      one: input.one * complex,
    );
  };

};

final Operator Function(double) rx = (theta) {
  return (input) {
    return ComplexTuple(
      zero: input.zero * cos(theta / 2) - input.one * Complex.I * sin(theta / 2), 
      one: input.one * cos(theta / 2) - input.zero * Complex.I * sin(theta / 2),
    );
  };
};

final Operator Function(double) ry = (theta) {
  return (input) {
    return ComplexTuple(
      zero: input.zero * cos(theta / 2) - input.one * sin(theta / 2), 
      one: input.one * cos(theta / 2) + input.zero * sin(theta / 2),
    );
  };
};

final Operator Function(double) rz = (theta) {
  return (input) {
    return ComplexTuple(
      zero: input.zero * (Complex.ONE * cos(theta / 2) - Complex.I * sin(theta / 2)), 
      one: input.one * (Complex.ONE * cos(theta / 2) + Complex.I * sin(theta / 2)),
    );
  };
};