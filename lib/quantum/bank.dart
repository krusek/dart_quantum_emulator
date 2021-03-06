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

import 'measurable_operator.dart';
import 'operators.dart';

class Qubit {
  int _index;
  Qubit({int index}): _index = index;

  int index(int length) {
    return length - _index - 1;
  }
}

class Bank {
  final bool _debugForLearning;
  final double Function() _generator;
  List<Qubit> _qubits = List<Qubit>.filled(0, Qubit(index: 0), growable: true);
  List<Complex> _data = List<Complex>.generate(1, (i) => i == 0 ? Complex.ONE : Complex.ZERO);

  static Bank create({int seed, bool debug = false}) {
    final Random random = Random(seed);
    return Bank(generator: random.nextDouble, debug: debug);
  }

  Bank({double Function() generator, bool debug = false}) : 
    _generator = generator,
    _debugForLearning = debug;

  /// Returns a list of unused qubits of the given [length].
  List<Qubit> borrowQubits({int length}) {
    print("acquiring $length qubits.");
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

  String toString() {
    final monomials = range(0, _data.length).map((i) {
      final d = _data[i];
      if (d != Complex.ZERO) {
        final binary = i.toRadixString(2).padLeft(_qubits.length, "0").split('').reversed.join();
        if (this._debugForLearning) 
          return "${d.abs() * d.abs()} |$binary>";
        else
          return "${d} |$binary>";
      }
      return null;
    }).where((x) => x != null);
    return monomials.join(" + ");
  }

  void release({List<Qubit> qubits}) {} // Not necessarily needed, but can be implemented for memory reasons.

  /// Performs the given [operator] on the [target] qubit.
  /// 
  /// If [controls] are specified then those qubits will be used as controls.
  /// The [target] qubit cannot be contained in the [controls] list. When the 
  /// additional array [controlModifiers] is not supplied then the operation
  /// will be controlled on [controls] being |1>. Otherwise [controlModifiers]
  /// can be used to decide whether the respective [controls] qubits are |1>
  /// where [controlModifiers] is true and |0> where [controlModifiers] is
  /// false.
  void operate({@required Qubit target, @required Operator operator, List<Qubit> controls = const [], List<bool> controlModifiers,}) {
    _operate(target: target, operator: operator, controls: controls, controlModifiers: controlModifiers, data: _data);
    if (_debugForLearning) {
      final vector = Vector(this._data);
      final normalized = vector.normalized();
      this._data = normalized.elements;
      print("$this");
    }
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

  /// Measures the [target] qubit with respect to the Z Pauli operator.
  Measurement measure({@required Qubit target}) {
    return measurement(targets: [target], operators: [mz]);
  }

  /// Measures the qubit array, [targets] with respect to the
  /// input [paulis].
  /// The two arrays must be the same length.
  Measurement measurement({@required List<Qubit> targets, @required List<MeasurableOperator> operators}) {
    assert(targets.length == operators.length);
    assert(targets.length > 0);

    final List<Complex> copy = List<Complex>.from(_data);
    for (final pair in zip(targets, operators)) {
      _operate(target: pair.zero, operator: pair.one.operator, data: copy);
    }
    final Vector evaluated = Vector(copy);
    final Vector original = Vector(_data);

    final zeroEigenvalue = _zeroEigenvalue(operators);
    final oneEigenvalue = _oneEigenvalue(operators);

    final zeroVector = (original - evaluated * oneEigenvalue) / (zeroEigenvalue - oneEigenvalue);
    final oneVector = (original - evaluated * zeroEigenvalue) / (zeroEigenvalue - oneEigenvalue);

    final zeroProbability = zeroVector.normSquared();

    final r = _generator();
    if (r < zeroProbability) {
      _data = zeroVector.normalized().elements;
      return Measurement.Zero;
    } else {
      oneVector.normalized();
      _data = oneVector.normalized().elements;
      return Measurement.One;
    }
  }

  Complex _zeroEigenvalue(List<MeasurableOperator> operators) {
    if (operators.length == 1) {
      return operators[0].eigenvalue1;
    }
    final allSimple = operators.map((f) => f.eigenvalue1 == Complex.ONE).reduce((a, b) => a && b);
    assert(allSimple);
    return Complex.ONE;
  }

  Complex _oneEigenvalue(List<MeasurableOperator> operators) {
    if (operators.length == 1) {
      return operators[0].eigenvalue2;
    }
    final allSimple = operators.map((f) => f.eigenvalue2 == -Complex.ONE).reduce((a, b) => a && b);
    assert(allSimple);
    return -Complex.ONE;
  }

  @visibleForTesting
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Bank) {
      return _listEquality(other._data);
    } else if (other is List<Complex>) { 
      return _listEquality(other);
    } else if (other is List<double>) { 
      final List<double> data = other;
      final norm = zip(data, this._data).map((tuple) {
        return (Complex(tuple.zero) - tuple.one).abs();
      }).reduce((a, b) => a + b);
      return norm < 1e-6;
    } else if (other is Map<String, Complex>) {
      var comp = Map<int, Complex>();
      for (final key in other.keys) {
        final value = int.tryParse(key, radix: 2);
        if (value == null) return false;
        comp[value] = other[key];
      }
      return _mapEquality(comp);
    } else if (other is Map<int, Complex>) {
      return _mapEquality(other);
    } else if (other is Map<int, double>) {
      var comp = other.map((ix, db) {
        return MapEntry<int, Complex>(ix, Complex(db));
      });
      return _mapEquality(comp);
    } else {
      return false;
    }
  }

  bool _listEquality(List<Complex> other) {
    final List<Complex> data = other;
      final norm = zip(data, this._data).map((tuple) {
        return (tuple.zero - tuple.one).abs();
      }).reduce((a, b) => a + b);
      return norm < 1e-6;
  }

  bool _mapEquality(Map<int, Complex> other) {
    final norm = other.keys.map((key) {
      return (other[key] - this._data[key]).abs();
    }).reduce((a,b) => a+b);
    return norm < 1e-6;
  }

  @visibleForTesting
  int get hashCode {
    if (this._data.length == 0) { return 0; }
    return this._data.map((f) => f.hashCode).reduce((i,j) => i+j);
  }
}

/// Creates an iterator over boolean integers.
/// 
/// This method returns all integers of boolean [length]
/// paired up with the [target] index being |0> or |1>.
/// For example, when [target] = 1 and [length] = 3 you get
/// (the order is not guaranteed):
/// ```
/// [
///   (0x000, 0x010),
///   (0x001, 0x011),
///   (0x100, 0x110),
///   (0x101, 0x111)
/// ]
/// ```
/// 
/// The indexes are zero based and start from the left. That means
/// when [target]=0 and [length]=3 you get:
/// ```
/// [
///   (0x000, 0x100),
///   (0x001, 0x101),
///   (0x010, 0x110),
///   (0x011, 0x111)
/// ]
/// ```
/// 
/// The other parameters can be used to remove some pairs from the
/// iterator. For each integer in [controls] we restrict the tuples
/// to pairs where those indexes are 1. For example when
/// [length]=3, [target]=0, and [controls] contains only 1 then we cut
/// the list in half and have:
/// ```
/// [
///   (0x010, 0x110),
///   (0x011, 0x111)
/// ]
/// ```
/// 
/// In a similar fashion [anticontrols] can be used to limit to
/// tuples where the output pairs are zero at the given indices.
/// 
/// It is an error for [target] to be contained in either [controls]
/// or [anticontrols].
Iterable<IntTuple> indexes({@required int target, @required int length, List<int> controls = const [], List<int> anticontrols = const [],}) sync* {
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


