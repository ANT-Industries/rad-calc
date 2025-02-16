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
      buildHalfLife(),
    ]);
    final searchController = useTextEditingController();
    final query = useExistingSignal(searchController.toSignal());
    final filtered = useComputed(() {
      final q = query.value.text.toLowerCase();
      return calculators.value.where((e) {
        return e.name.toLowerCase().contains(q);
      }).toList();
    });
    final selectedCalc = useSignal<BaseCalc?>(null);
    final hideList = useSignal(false);
    final size = MediaQuery.of(context).size;
    final canShowDetails = size.width > 600;
    final showOnlyList = !canShowDetails || hideList.value;
    // final showList = (canShowDetails && !hideList.value) || !canShowDetails;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rad Calc'),
        leading: canShowDetails
            ? IconButton(
                icon: Icon(hideList.value ? Icons.view_sidebar : Icons.close),
                onPressed: () {
                  hideList.value = !hideList.value;
                },
              )
            : null,
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
      body: () {
        final Widget list = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: () {
                if (filtered.value.isEmpty) {
                  return const Center(child: Text('No calculators found'));
                }
                return ListView.builder(
                  itemCount: filtered.value.length,
                  itemBuilder: (context, index) {
                    final calc = filtered.value[index];
                    return ListTile(
                      title: Text(calc.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final nav = Navigator.of(context);
                        if (showOnlyList) {
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => calc,
                            ),
                          );
                        } else {
                          selectedCalc.value = calc;
                        }
                      },
                    );
                  },
                );
              }(),
            ),
          ],
        );
        if (canShowDetails && !showOnlyList) {
          return Row(
            children: [
              SizedBox(
                width: 280,
                child: list,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: selectedCalc.value ??
                    const Center(child: Text('Select a calculator')),
              ),
            ],
          );
        }
        return list;
      }(),
    );
  }
}
