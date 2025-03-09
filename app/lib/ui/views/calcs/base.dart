import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

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

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...buildInputs(context),
          const Divider(height: 1, thickness: 1),
          ...buildOutputs(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: buildActions(context),
        ),
        body: buildBody(context),
      );
    });
  }
}

class GroupCalc extends BaseCalc {
  final List<BaseCalc> calcs;

  @override
  final String title;

  const GroupCalc({
    super.key,
    required this.title,
    required this.calcs,
  });

  @override
  Widget build(BuildContext context) {
    final index = useSignal(0);
    return Watch((context) {
      return DefaultTabController(
        initialIndex: index(),
        length: calcs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              ...buildActions(context),
              ...calcs[index()].buildActions(context),
            ],
            bottom: TabBar(
              onTap: index.set,
              tabs: [
                for (final calc in calcs) Tab(text: calc.title),
              ],
            ),
          ),
          body: calcs[index()].buildBody(context),
        ),
      );
    });
  }
}
