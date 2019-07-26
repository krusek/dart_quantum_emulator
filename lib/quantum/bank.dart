/*
 * This will contain my "bank" of qubits. Internally it will contain
 * a single vector (or maybe I can get away with an array) of
 * 2^n Complex numbers, where n is the number of qubits we have.
 * 
 * We may include a Qubit class, but it would have no public 
 * fields and interally all it would have is an integer letting
 * the bank know which qubit we are referring to.
 * 
 * For each qubit you request the length of the internal
 * vector will double. The new elements will be a copy of the 
 * old elements.
 * 
 * Quantum operations can be handled with matrix multiplication,
 * but I have found that that can be incredibly slow. Internally
 * quantum operations can actually be represented by rather simple
 * vector operations. Internally we will use that.
*/

import 'dart:math';

import 'package:complex/complex.dart';
import 'package:flutter/foundation.dart';
import 'package:quantum_emulator/linear_algebra/vector.dart';

class Qubit {
  int _index;
  Qubit({int index}): _index = index;

  int index(int length) {
    return length - _index - 1;
  }
}

class Bank {
  List<Qubit> _qubits = List<Qubit>.filled(0, Qubit(index: 0), growable: true);
  List<Complex> _data = List<Complex>.generate(1, (i) => i == 0 ? Complex.ONE : Complex.ZERO);
  List<Qubit> borrowQubits({int length}) {
    assert(length > 0);
    final l = _qubits.length;
    
    final int newLength = pow(2, l + length);
    final oldLength = _data.length;
    _data.length = newLength;
    for (final int i in range(oldLength, newLength)) {
      _data[i] = Complex.ZERO;
    }
    _qubits.length += length;
    for (final int i in range(l, l + length)) {
      _qubits[i] = Qubit(index: i);
    }
    return _qubits.sublist(l);
  }

  void H() {
    _data[0] = Complex(1.0 / sqrt(2));
    _data[1] = Complex(1.0 / sqrt(2));
  }

  String toString() {
    final monomials = range(0, _data.length).map((i) {
      final d = _data[i];
      if (d != Complex.ZERO) {
        final binary = i.toRadixString(2).padLeft(_qubits.length, "0").split('').reversed.join();
        return "$d |$binary>";
      }
      return null;
    }).where((x) => x != null);
    return monomials.join(" + ");
  }

  void release({List<Qubit> qubits}) {} // Not necessarily needed, but can be implemented for memory reasons.
  void operate({@required Qubit target, @required Operator operator, List<Qubit> controls = const [], List<bool> controlModifiers,}) {
    _operate(target: target, operator: operator, controls: controls, controlModifiers: controlModifiers, data: _data);
  }

  void _operate({@required Qubit target, @required Operator operator, @required List<Complex> data, List<Qubit> controls = const [], List<bool> controlModifiers,}) {
    if (controlModifiers == null) {
      controlModifiers = controls.map((_) => true).toList();
    }
    assert(controls.length == controlModifiers.length);
    final length = _qubits.length;
    final oneControls = zip(controls, controlModifiers)
      .where((tuple) => tuple.one)
      .map((tuple) => tuple.zero.index(length)).toList();
    final zeroControls = zip(controls, controlModifiers)
      .where((tuple) => !tuple.one)
      .map((tuple) => tuple.zero.index(length)).toList();
    for (final tuple in indexes(target: target.index(length), length: length, controls: oneControls, anticontrols: zeroControls)) {
      final input = ComplexTuple(zero: data[tuple.zero], one:data[tuple.one]);
      final newData = operator(input);
      data[tuple.zero] = newData.zero;
      data[tuple.one] = newData.one;
    }
  }

  Measurement measure({@required Qubit target}) {
    return measurement(targets: [target], operators: [Z]);
  }

  Measurement measurement({@required List<Qubit> targets, @required List<Operator> operators}) {
    assert(targets.length == operators.length);

    final List<Complex> copy = List<Complex>.from(_data);
    for (final pair in zip(targets, operators)) {
      _operate(target: pair.zero, operator: pair.one, data: copy);
    }
    final Vector evaluated = Vector(copy);
    final Vector original = Vector(_data);

    final zeroVector = (original + evaluated) * 0.5;
    final oneVector = (original - evaluated) * 0.5;

    final zeroProbability = zeroVector.normSquared();
    final oneProbability = oneVector.normSquared();

    print("zeroProb: $zeroProbability, oneProb: $oneProbability");
    
    return Measurement.Zero;
  }
}

Iterable<IntTuple> indexes({List<int> controls = const [], List<int> anticontrols = const [], @required int target, @required int length}) sync* {
  for (final i in range(0, pow(2, length-1))) {
    final s = i.toRadixString(2).padLeft(length - 1, "0");
    
    final zero = length == 1 ? "0" : s.substring(0, target) + "0" + s.substring(target);
    final one = length == 1 ? "1" : s.substring(0, target) + "1" + s.substring(target);
    final controlled = controls.every((ix) {
      return zero[ix] == "1";
    });
    if (controlled == false) continue;
    final anti = anticontrols.every((ix) {
      return zero[ix] == "0";
    });
    if (anti == false) continue;
    yield IntTuple(one: int.parse(one, radix: 2), zero: int.parse(zero, radix: 2));
  }
}

class IntTuple extends Tuple<int, int> {
  IntTuple({int one, int zero}): super(one: one, zero: zero);

  @override
  String toString() {
    return "(${zero.toRadixString(2)}, ${one.toRadixString(2)})";
  }

  int get hashCode {
    return one.hashCode + zero.hashCode;
  }

  operator==(dynamic o) {
    if (o is IntTuple) {
      final IntTuple other = o;
      if (other == null) return false;
      return this.one == other.one && this.zero == other.zero;
    }
    return false;
  }
}

Iterable<int> range(int start, int end) sync* {
  for (int i = start; i < end; i++) {
    yield i;
  }
}

typedef Operator = ComplexTuple Function(ComplexTuple);

final Operator X = (input) => ComplexTuple(zero: input.one, one: input.zero);
final Operator Y = (input) => ComplexTuple(zero: -Complex.I * input.one, one: Complex.I * input.zero);
final Operator Z = (input) => ComplexTuple(zero: input.zero, one: -input.one);
final Operator H = (input) => ComplexTuple(zero: (input.zero + input.one) / sqrt(2.0), one: (input.zero - input.one) / sqrt(2.0));
final Operator I = (input) => ComplexTuple(zero: input.zero, one: input.one);

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

class ComplexTuple extends Tuple<Complex, Complex> {
  ComplexTuple({Complex one, Complex zero}): super(one: one, zero: zero);
}

enum Measurement {
  Zero,
  One
}



