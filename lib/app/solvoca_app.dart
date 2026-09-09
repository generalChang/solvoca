import 'package:flutter/material.dart';
import 'package:solvoca/app/cards_tab.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/app/today_tab.dart';

class SolvocaApp extends StatelessWidget {
  const SolvocaApp({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6B8CAE);

    return MaterialApp(
      title: 'Solvoca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: '카드',
          ),
        ],
      ),
    );
  }
}
