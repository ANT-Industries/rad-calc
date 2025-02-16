import 'package:rational/rational.dart';

extension RationalUtils on double {
  Rational toRational() {
    if (this == 0) return Rational.zero;
    if (this == 1) return Rational.one;
    return Rational.parse(toString());
  }
}

Rational safeRational(Rational Function() cb) {
  try {
    final value = cb();
    return value;
  } catch (e) {
    return Rational.zero;
  }
}
