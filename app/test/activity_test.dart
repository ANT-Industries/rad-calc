import 'package:app/data/numbers/rational.dart';
import 'package:app/ui/widgets/activity_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rational/rational.dart';

void main() {
  group("convert type to curries", () {
    test("dps to curries", () {
      final values = <double, double>{
        3.7e10: 1.0,
        0.0: 0.0,
        20000: 5.41e-7,
        5: 1.35e-10,
      };
      for (final entry in values.entries) {
        final result =
            convertToCuries(ActivityType.dps, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
    test("dpm to curries", () {
      final values = <double, double>{
        2.22e12: 1.0,
        0.0: 0.0,
        100: 4.50e11,
        5: 2.25e12,
      };
      for (final entry in values.entries) {
        final result =
            convertToCuries(ActivityType.dps, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
    test("curries to curries", () {
      final values = <double, double>{
        1.0: 1.0,
        0.0: 0.0,
        0.5: 0.5,
        0.1: 0.1,
      };
      for (final entry in values.entries) {
        final result = convertToCuries(ActivityType.ci, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
    test("mCi to curries", () {
      final values = <double, double>{
        1000: 1,
        1: 1e-3,
        0.0: 0.0,
        1000000: 1000,
      };
      for (final entry in values.entries) {
        final result =
            convertToCuries(ActivityType.mCi, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
    test("bq to curries", () {
      final values = <double, double>{
        3.7e10: 1.0,
        0.0: 0.0,
        1: 3.7e-10,
        5: 1.35e-10,
      };
      for (final entry in values.entries) {
        final result = convertToCuries(ActivityType.bq, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
    test("mBq to curries", () {
      final values = <double, double>{
        3.7e4: 1.0,
        0.0: 0.0,
        1: 3.7e-4,
        5: 1.35e-4,
      };
      for (final entry in values.entries) {
        final result =
            convertToCuries(ActivityType.mBq, entry.key.toRational());
        expect(isSame(result, entry.value.toRational(), 10), true);
      }
    });
  });
}

bool isSame(Rational a, Rational b, int precision) {
  return ((a - b).abs() < (1 / (10 ^ precision)).toRational());
}
