
import 'dart:math';

import 'package:complex/complex.dart';

class Vector {
  List<Complex> elements;
  Vector(this.elements);
  Vector.zero(int length): this([]);
  Vector.double(List<double> doubles):
    this(doubles.map((d) {return Complex(d);}).toList());
  
  double norm() {
    return pow(normSquared(), 0.5);
  }

  double normSquared() {
    return this.elements
      .map((c){return c*c.conjugate();})
      .reduce((c,d){return c+d;}).abs();
  }

  Vector normalized() {
    final n = norm();
    assert(n > 0);

    return this * (1.0 / norm());
  }

  String toString() {
    final strings = elements.map((c) {return c.toString();});
    final joined = strings.join(", ");
    return "[$joined]";
  }

  operator  +(Vector v) {
    assert(v.elements.length == this.elements.length, "vectors must be the same size for operations, ${this.elements.length} vs ${v.elements.length}");
    
    final result = zip(v.elements, this.elements).map((t) {
      return t.one + t.zero;
    }).toList();
    return Vector(result);
  }
  operator  -(Vector v) {
    assert(v.elements.length == this.elements.length, "vectors must be the same size for operations, ${this.elements.length} vs ${v.elements.length}");
    
    final result = zip(v.elements, this.elements).map((t) {
      return t.one - t.zero;
    }).toList();
    return Vector(result);
  }

  operator *(Object d) {
    final result = this.elements.map((t) {
      return t*d;
    }).toList();
    return Vector(result);
  }

  operator /(Object d) {
    final result = this.elements.map((t) {
      return t/d;
    }).toList();
    return Vector(result);
  }
}

class Tuple<T,U> {
  T zero;
  U one;

  Tuple({this.zero, this.one});
}

Iterable<Tuple<T,U>> zip<T, U>(Iterable<T> left, Iterable<U> right) sync* {
  final lefti = left.iterator;
  final righti = right.iterator;
  while (lefti.moveNext() && righti.moveNext()) {
    yield Tuple<T,U>(zero: lefti.current, one: righti.current);
  }
}