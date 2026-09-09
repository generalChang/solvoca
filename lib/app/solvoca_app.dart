import 'package:flutter/material.dart';
import 'package:solvoca/app/cards_tab.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/app/today_tab.dart';
import 'package:solvoca/ui/tab_bar.dart';
import 'package:solvoca/ui/theme.dart';
import 'package:solvoca/ui/tokens.dart';

class SolvocaApp extends StatelessWidget {
  const SolvocaApp({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solvoca',
      theme: buildSolvocaTheme(),
      themeMode: ThemeMode.light,
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _HomeShell(controller: controller),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({required this.controller});

  final StudyController controller;

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayTab(controller: widget.controller),
      CardsTab(controller: widget.controller),
    ];

    return Scaffold(
      backgroundColor: SolvocaTokens.background,
      body: pages[_index],
      bottomNavigationBar: Material(
        color: SolvocaTokens.background,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SafeArea(
            top: false,
            child: SolvocaTabBar(
              selectedIndex: _index,
              onSelect: (value) => setState(() => _index = value),
            ),
          ),
        ),
      ),
    );
  }
}
