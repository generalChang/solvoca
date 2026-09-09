import 'package:flutter/material.dart' hide Card;
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/models.dart';
import 'package:solvoca/ui/buttons.dart';
import 'package:solvoca/ui/fab.dart';
import 'package:solvoca/ui/list_row.dart';
import 'package:solvoca/ui/sheet.dart';
import 'package:solvoca/ui/tokens.dart';

class CardsTab extends StatelessWidget {
  const CardsTab({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    final lists = controller.listLists();

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    SolvocaTextAction(
                      label: '목록 추가',
                      tooltip: '목록 추가',
                      icon: Icons.create_new_folder_outlined,
                      onPressed: () => _showCreateListDialog(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final cards = controller.listCards(list.id);

                    return SolvocaListRow(
                      title: list.name,
                      subtitle: '${cards.length}장',
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
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 16,
            child: SolvocaFab(
              label: '카드 추가',
              onPressed: () => _showAddCardSheet(context),
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
    await showSolvocaSheet<void>(
      context: context,
      builder: (context) => AddCardSheet(controller: controller),
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
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        SolvocaTextAction(
          label: '취소',
          onPressed: () => Navigator.of(context).pop(),
        ),
        SolvocaPrimaryButton(
          label: '추가',
          onPressed: _submit,
          compact: true,
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
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        SolvocaTextAction(
          label: '취소',
          onPressed: () => Navigator.of(context).pop(),
        ),
        SolvocaPrimaryButton(
          label: '저장',
          onPressed: _submit,
          compact: true,
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

    return SolvocaSheetBody(
      title: '카드 추가',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedListId,
            decoration: const InputDecoration(
              labelText: '목록',
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
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _backController,
            decoration: const InputDecoration(
              labelText: '뒷면 (한국어)',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          SolvocaPrimaryButton(
            label: '추가',
            onPressed: _submit,
            expand: true,
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
          backgroundColor: SolvocaTokens.background,
          appBar: AppBar(
            title: Text(currentList.name),
            actions: [
              SolvocaIconButton(
                tooltip: '목록 이름 바꾸기',
                onPressed: () => _showRenameListDialog(context, currentList),
                icon: Icons.edit_outlined,
              ),
              if (canDeleteList)
                SolvocaIconButton(
                  tooltip: '목록 삭제',
                  onPressed: () => _confirmDeleteList(context, currentList),
                  icon: Icons.delete_outline,
                ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return SolvocaListRow(
                title: card.front,
                subtitle: '${card.back} · ${_progressLabel(card.progress)}',
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
          floatingActionButton: SolvocaFab(
            label: '카드 추가',
            onPressed: () async {
              await showSolvocaSheet<void>(
                context: context,
                builder: (context) => AddCardSheet(
                  controller: controller,
                  initialListId: currentList.id,
                ),
              );
            },
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
            SolvocaTextAction(
              label: '취소',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            SolvocaPrimaryButton(
              label: '삭제',
              onPressed: () => Navigator.of(context).pop(true),
              compact: true,
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
    return SolvocaSheetBody(
      title: '뒷면 수정',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _backController,
            decoration: const InputDecoration(
              labelText: '뒷면 (한국어)',
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          SolvocaPrimaryButton(
            label: '저장',
            onPressed: _submit,
            expand: true,
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
          backgroundColor: SolvocaTokens.background,
          appBar: AppBar(title: Text(current.front)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                '앞면',
                style: TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SolvocaTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current.front,
                style: const TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SolvocaTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '뒷면',
                style: TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SolvocaTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current.back,
                style: const TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: SolvocaTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _progressLabel(current.progress),
                style: const TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: SolvocaTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              SolvocaPrimaryButton(
                label: '뒷면 수정',
                onPressed: () => _showEditBackSheet(context, current),
                expand: true,
              ),
              const SizedBox(height: 12),
              SolvocaSecondaryButton(
                label: '목록 이동',
                icon: Icons.drive_file_move_outline,
                onPressed: () => _showMoveSheet(context, current),
                expand: true,
              ),
              if (current.progress == CardProgress.mastered) ...[
                const SizedBox(height: 12),
                SolvocaSecondaryButton(
                  label: '학습으로 돌리기',
                  icon: Icons.replay_outlined,
                  onPressed: () => _confirmReturnToLearning(context, current),
                  expand: true,
                ),
              ],
              const SizedBox(height: 12),
              SolvocaSecondaryButton(
                label: '카드 삭제',
                icon: Icons.delete_outline,
                onPressed: () => _confirmDeleteCard(context, current),
                expand: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditBackSheet(BuildContext context, Card current) async {
    await showSolvocaSheet<void>(
      context: context,
      builder: (context) => EditBackSheet(controller: controller, card: current),
    );
  }

  Future<void> _showMoveSheet(BuildContext context, Card current) async {
    final lists = controller.listLists().where((list) => list.id != current.listId);
    if (lists.isEmpty) {
      return;
    }

    await showSolvocaSheet<void>(
      context: context,
      builder: (context) {
        return SolvocaSheetBody(
          title: '목록 이동',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final list in lists)
                SolvocaListRow(
                  title: list.name,
                  subtitle: '${controller.listCards(list.id).length}장',
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
            SolvocaTextAction(
              label: '취소',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            SolvocaPrimaryButton(
              label: '돌리기',
              onPressed: () => Navigator.of(context).pop(true),
              compact: true,
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
            SolvocaTextAction(
              label: '취소',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            SolvocaPrimaryButton(
              label: '삭제',
              onPressed: () => Navigator.of(context).pop(true),
              compact: true,
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
