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
      child: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
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
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddCardSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('카드 추가'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCardSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: AddCardSheet(controller: controller),
        );
      },
    );
  }
}

class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key, required this.controller, this.initialListId});

  final StudyController controller;
  final String? initialListId;

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  late String? _selectedListId;

  @override
  void initState() {
    super.initState();
    final lists = widget.controller.listLists();
    _selectedListId = widget.initialListId ?? lists.firstOrNull?.id;
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _submit() {
    final listId = _selectedListId;
    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (listId == null || front.isEmpty || back.isEmpty) {
      return;
    }

    try {
      widget.controller.addCard(listId: listId, front: front, back: back);
      Navigator.of(context).pop();
    } on DuplicateCardPairException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('같은 앞면과 뒷면을 가진 카드가 이미 있어요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = widget.controller.listLists();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '카드 추가',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedListId,
            decoration: const InputDecoration(
              labelText: '목록',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final list in lists)
                DropdownMenuItem(
                  value: list.id,
                  child: Text(list.name),
                ),
            ],
            onChanged: (value) => setState(() => _selectedListId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _frontController,
            decoration: const InputDecoration(
              labelText: '앞면 (영어)',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _backController,
            decoration: const InputDecoration(
              labelText: '뒷면 (한국어)',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('추가'),
          ),
        ],
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: AddCardSheet(
                      controller: controller,
                      initialListId: list.id,
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('카드 추가'),
          ),
        );
      },
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
