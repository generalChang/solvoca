import 'package:flutter/material.dart' hide Card;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'add-list',
                  onPressed: () => _showCreateListDialog(context),
                  tooltip: '목록 추가',
                  child: const Icon(Icons.create_new_folder_outlined),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add-card',
                  onPressed: () => _showAddCardSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('카드 추가'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CreateListDialog(controller: controller),
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

class _CreateListDialog extends StatefulWidget {
  const _CreateListDialog({required this.controller});

  final StudyController controller;

  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    widget.controller.createList(name: name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('목록 추가'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: '목록 이름',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('추가'),
        ),
      ],
    );
  }
}

class _RenameListDialog extends StatefulWidget {
  const _RenameListDialog({
    required this.controller,
    required this.list,
  });

  final StudyController controller;
  final StudyList list;

  @override
  State<_RenameListDialog> createState() => _RenameListDialogState();
}

class _RenameListDialogState extends State<_RenameListDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    widget.controller.renameList(listId: widget.list.id, name: name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('목록 이름 바꾸기'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: '목록 이름',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('저장'),
        ),
      ],
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
        final currentList = controller
            .listLists()
            .firstWhere((entry) => entry.id == list.id, orElse: () => list);
        final cards = controller.listCards(currentList.id);
        final canDeleteList =
            controller.listLists().length > 1 && cards.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentList.name),
            actions: [
              IconButton(
                tooltip: '목록 이름 바꾸기',
                onPressed: () => _showRenameListDialog(context, currentList),
                icon: const Icon(Icons.edit_outlined),
              ),
              if (canDeleteList)
                IconButton(
                  tooltip: '목록 삭제',
                  onPressed: () => _confirmDeleteList(context, currentList),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final card = cards[index];

              return ListTile(
                title: Text(card.front),
                subtitle: Text('${card.back} · ${_progressLabel(card.progress)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CardDetailScreen(
                        controller: controller,
                        card: card,
                      ),
                    ),
                  );
                },
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
                      initialListId: currentList.id,
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

  Future<void> _showRenameListDialog(
    BuildContext context,
    StudyList currentList,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _RenameListDialog(
        controller: controller,
        list: currentList,
      ),
    );
  }

  Future<void> _confirmDeleteList(
    BuildContext context,
    StudyList currentList,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('목록 삭제'),
          content: Text('\'${currentList.name}\' 목록을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      controller.deleteList(listId: currentList.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } on ListDeleteRefusedException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비어 있는 목록만 삭제할 수 있어요.')),
      );
    }
  }

  String _progressLabel(CardProgress progress) {
    return switch (progress) {
      CardProgress.cardNew => '신규',
      CardProgress.learning => '학습',
      CardProgress.mastered => '암기',
    };
  }
}

class EditBackSheet extends StatefulWidget {
  const EditBackSheet({
    super.key,
    required this.controller,
    required this.card,
  });

  final StudyController controller;
  final Card card;

  @override
  State<EditBackSheet> createState() => _EditBackSheetState();
}

class _EditBackSheetState extends State<EditBackSheet> {
  late final TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    _backController = TextEditingController(text: widget.card.back);
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  void _submit() {
    final back = _backController.text.trim();
    if (back.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    try {
      widget.controller.editCard(cardId: widget.card.id, back: back);
      Navigator.of(context).pop();
    } on DuplicateCardPairException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('같은 앞면과 뒷면을 가진 카드가 이미 있어요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '뒷면 수정',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _backController,
            decoration: const InputDecoration(
              labelText: '뒷면 (한국어)',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({
    super.key,
    required this.controller,
    required this.card,
  });

  final StudyController controller;
  final Card card;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = _tryFindCard(controller, card.id);
        if (current == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          appBar: AppBar(title: Text(current.front)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('앞면', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(current.front, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Text('뒷면', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(current.back, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Text(
                _progressLabel(current.progress),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.tonalIcon(
                onPressed: () => _showEditBackSheet(context, current),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('뒷면 수정'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _showMoveSheet(context, current),
                icon: const Icon(Icons.drive_file_move_outline),
                label: const Text('목록 이동'),
              ),
              if (current.progress == CardProgress.mastered) ...[
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _confirmReturnToLearning(context, current),
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('학습으로 돌리기'),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteCard(context, current),
                icon: const Icon(Icons.delete_outline),
                label: const Text('카드 삭제'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditBackSheet(BuildContext context, Card current) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditBackSheet(controller: controller, card: current);
      },
    );
  }

  Future<void> _showMoveSheet(BuildContext context, Card current) async {
    final lists = controller.listLists().where((list) => list.id != current.listId);
    if (lists.isEmpty) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  '목록 이동',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final list in lists)
                ListTile(
                  title: Text(list.name),
                  onTap: () {
                    controller.moveCard(cardId: current.id, listId: list.id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReturnToLearning(BuildContext context, Card current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('학습으로 돌리기'),
          content: Text(
            '\'${current.front}\' 카드를 다시 학습 상태로 돌릴까요? 오늘 큐에는 들어가지 않고 내일부터 다시 나옵니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('돌리기'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    controller.returnMasteredToLearning(cardId: current.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카드를 학습 상태로 돌렸어요.')),
      );
    }
  }

  Future<void> _confirmDeleteCard(BuildContext context, Card current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카드 삭제'),
          content: Text('\'${current.front}\' 카드를 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final cardId = current.id;
    Navigator.of(context).pop();
    controller.deleteCard(cardId: cardId);
  }

  String _progressLabel(CardProgress progress) {
    return switch (progress) {
      CardProgress.cardNew => '신규',
      CardProgress.learning => '학습',
      CardProgress.mastered => '암기',
    };
  }
}

Card? _tryFindCard(StudyController controller, String cardId) {
  for (final list in controller.listLists()) {
    for (final card in controller.listCards(list.id)) {
      if (card.id == cardId) {
        return card;
      }
    }
  }
  return null;
}
