import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import 'calculators/base_calc.dart';
import 'calculators/half_life.dart';

class Home extends HookWidget {
  const Home({super.key, required this.brightness});

  final Signal<Brightness> brightness;

  @override
  Widget build(BuildContext context) {
    final calculators = useSignal(<BaseCalc>[
      HalfLife(),
    ]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rad Calc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: () {
              brightness.value = brightness.value == Brightness.light
                  ? Brightness.dark
                  : Brightness.light;
            },
          ),
        ],
      ),
      body: calculators.value.isEmpty
          ? const Center(child: Text('No calculators found'))
          : ListView.builder(
              itemCount: calculators.value.length,
              itemBuilder: (context, index) {
                final calc = calculators.value[index];
                return ListTile(
                  title: Text(calc.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final nav = Navigator.of(context);
                    nav.push(
                      MaterialPageRoute(
                        builder: (context) => calc,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
