import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';

abstract class BaseCalc extends HookWidget {
  const BaseCalc({super.key});

  String get title;

  String? get description => null;

  List<String> get tags => [];

  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  List<Widget> buildInputs(BuildContext context) {
    return [];
  }

  List<Widget> buildOutputs(BuildContext context) {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: buildActions(context),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ...buildInputs(context),
              const Divider(height: 1, thickness: 1),
              ...buildOutputs(context),
            ],
          ),
        ),
      );
    });
  }
}
