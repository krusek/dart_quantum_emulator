// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'dart:math';

import 'package:complex/complex.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_emulator/linear_algebra/vector.dart';

void main() {
  group('vector operations', () {
    test('Test vector equivalent of H gate followed by H gate', () {
      final v = Vector.double([1, 1]).normalized();
      final c1 = (v.elements[0] + v.elements[1]) / pow(2, 0.5);
      final c2 = (v.elements[0] - v.elements[1]) / pow(2, 0.5);
      // renormalizing replaces 0.99999999 with 1
      final v2 = Vector([c1, c2]).normalized();
      final elements = v2.elements;
      assert(elements[0].real == 1.0);
      assert(elements[1] == Complex.ZERO);
    });

    test('Test vector addition', () {
      final v = Vector.double([2,4]);
      final v2 = Vector.double([3,6]);
      final a = v + v2;
      assert(a.elements[0].real == 5);
      assert(a.elements[1].real == 10);
    });

    test('Test vector subtraction', () {
      final v = Vector.double([2,4]);
      final v2 = Vector.double([3,6]);
      final a = v - v2;
      expect(a.elements[0].real, -1);
      expect(a.elements[1].real, -2);
    });

    test('test vector and double multiplication', () {
      final v = Vector.double([2,4]);
      final a = v * 0.5;
      expect(a.elements[0].real, 1);
      expect(a.elements[1].real, 2);
    });
  });

  test('complex zero', () {
    final zero = Complex.ZERO;
    expect(zero, zero * -1);
  });
}
