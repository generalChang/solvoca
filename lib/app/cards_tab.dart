import 'package:flutter/material.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/models.dart';

class CardsTab extends StatelessWidget {
  const CardsTab({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    final lists = controller.listLists();

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lists.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final list = lists[index];
          final cards = controller.listCards(list.id);

          return ListTile(
            title: Text(list.name),
            subtitle: Text('${cards.length}장'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ListDetailScreen(
                    controller: controller,
                    list: list,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ListDetailScreen extends StatelessWidget {
  const ListDetailScreen({
    super.key,
    required this.controller,
    required this.list,
  });

  final StudyController controller;
  final StudyList list;

  @override
  Widget build(BuildContext context) {
    final cards = controller.listCards(list.id);

    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final card = cards[index];

          return ListTile(
            title: Text(card.front),
            subtitle: Text('${card.back} · ${_progressLabel(card.progress)}'),
          );
        },
      ),
    );
  }

  String _progressLabel(CardProgress progress) {
    return switch (progress) {
      CardProgress.cardNew => '신규',
      CardProgress.learning => '학습',
      CardProgress.mastered => '암기',
    };
  }
}
