import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'calculators/base_calc.dart';

class CalcView extends HookWidget {
  final BaseCalc calculator;
  const CalcView(this.calculator, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calculator.name),
      ),
      body: calculator,
    );
  }
}
