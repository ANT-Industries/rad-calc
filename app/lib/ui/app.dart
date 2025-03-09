import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../data/signals/saved_signal.dart';
import 'views/home.dart';

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
    final themeColor = useSignal<Color>(Colors.red);
    final lightColorScheme = useComputed(() {
      return ColorScheme.fromSeed(
        seedColor: themeColor.value,
        brightness: Brightness.light,
      );
    });
    final lightTheme = useComputed(() {
      return ThemeData.from(
        colorScheme: lightColorScheme.value,
      ).copyWith(
        scaffoldBackgroundColor: lightColorScheme.value.surface,
      );
    });
    final darkColorScheme = useComputed(() {
      return ColorScheme.fromSeed(
        seedColor: themeColor.value,
        brightness: Brightness.dark,
      );
    });
    final darkTheme = useComputed(() {
      return ThemeData.from(
        colorScheme: darkColorScheme.value,
      );
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(
        brightness: brightness,
        theme: themeColor,
      ),
      themeMode: themeMode.value,
      theme: lightTheme.value,
      darkTheme: darkTheme.value,
    );
  }
}
