import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import 'calcs/base.dart';
import 'calcs/half_life/half_life.dart';
import 'calcs/half_life/final_activity.dart';
import 'calcs/half_life/initial_activity.dart';
import 'calcs/half_life/time.dart';

class Home extends HookWidget {
  const Home({
    super.key,
    required this.brightness,
    required this.theme,
  });

  final Signal<Brightness> brightness;
  final Signal<Color> theme;

  @override
  Widget build(BuildContext context) {
    final calculators = useSignal(<BaseCalc>[
      GroupCalc(
        title: 'Half Life',
        calcs: [
          HalfLifeHalfLife(),
          HalfLifeInitialActivity(),
          HalfLifeFinalActivity(),
          HalfLifeTime(),
        ],
      ),
    ]);
    final searchController = useTextEditingController();
    final query = useExistingSignal(searchController.toSignal());
    final filtered = useComputed(() {
      final q = query.value.text.toLowerCase();
      return calculators.value.where((e) {
        return e.title.toLowerCase().contains(q);
      }).toList();
    });
    final selectedCalc = useSignal<BaseCalc?>(null);
    final hideList = useSignal(false);
    final size = MediaQuery.of(context).size;
    final canShowDetails = size.width > 600;
    final showOnlyList = !canShowDetails || hideList.value;
    final allColors = useComputed<List<Color>>(() {
      return [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
        Colors.amber,
        Colors.cyan,
      ];
    });
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
          IconButton(
            icon: const Icon(Icons.palette),
            color: theme.value,
            onPressed: () {
              final index = allColors.value.indexOf(theme.value);
              final next =
                  allColors.value[(index + 1) % allColors.value.length];
              theme.value = next;
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
                      title: Text(calc.title),
                      // subtitle: Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Wrap(
                      //     runSpacing: 8,
                      //     spacing: 8,
                      //     children: [
                      //       for (final tag in calc.tags) Chip(label: Text(tag)),
                      //     ],
                      //   ),
                      // ),
                      trailing: const Icon(Icons.chevron_right),
                      selected: selectedCalc.value == calc,
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
