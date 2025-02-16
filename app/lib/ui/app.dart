import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../data/signals/saved_signal.dart';
import 'home.dart';

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = useExistingSignal(EnumSignal(
      'app/brightness',
      Brightness.light,
      Brightness.values,
    ));
    final themeMode = useComputed(() {
      return brightness.value == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark;
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(brightness: brightness),
      themeMode: themeMode.value,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
