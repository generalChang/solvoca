import 'package:flutter/material.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/models.dart' show TodayPhase;

class TodayTab extends StatelessWidget {
  const TodayTab({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    final today = controller.today;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Solvoca',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '암기 완료 ${today.masteredCount}장',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final today = controller.today;

    return switch (today.phase) {
      TodayPhase.waiting => _WaitingView(
        remainingCount: today.remainingUngradedCount,
        onStart: controller.startOrResumeQueue,
      ),
      TodayPhase.inProgress => _QueuePlayer(
        front: today.currentFront ?? '',
        back: today.currentBack ?? '',
        backRevealed: controller.backRevealed,
        remainingCount: today.remainingUngradedCount,
        canUndo: today.canUndoLastGrade,
        onReveal: controller.revealBack,
        onKnew: controller.gradeKnew,
        onDidntKnow: controller.gradeDidntKnow,
        onUndo: controller.undoLastGrade,
      ),
      TodayPhase.dayComplete => _DayCompleteView(
        canUndo: today.canUndoLastGrade,
        onUndo: controller.undoLastGrade,
      ),
      TodayPhase.cleared => const _ClearedView(),
    };
  }
}

class _WaitingView extends StatelessWidget {
  const _WaitingView({
    required this.remainingCount,
    required this.onStart,
  });

  final int remainingCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '오늘 남은 카드 $remainingCount장',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onStart,
          child: const Text('시작'),
        ),
      ],
    );
  }
}

class _QueuePlayer extends StatelessWidget {
  const _QueuePlayer({
    required this.front,
    required this.back,
    required this.backRevealed,
    required this.remainingCount,
    required this.canUndo,
    required this.onReveal,
    required this.onKnew,
    required this.onDidntKnow,
    required this.onUndo,
  });

  final String front;
  final String back;
  final bool backRevealed;
  final int remainingCount;
  final bool canUndo;
  final VoidCallback onReveal;
  final VoidCallback onKnew;
  final VoidCallback onDidntKnow;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '남은 카드 $remainingCount장',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  front,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (backRevealed) ...[
                  const SizedBox(height: 24),
                  Text(
                    back,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (canUndo)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onUndo,
              child: const Text('마지막 채점 취소'),
            ),
          ),
        if (!backRevealed)
          FilledButton(
            onPressed: onReveal,
            child: const Text('뒷면 보기'),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDidntKnow,
                  child: const Text('몰랐다'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onKnew,
                  child: const Text('알았다'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _DayCompleteView extends StatelessWidget {
  const _DayCompleteView({
    this.canUndo = false,
    required this.onUndo,
  });

  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '오늘 학습을 마쳤어요.',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '내일 새 카드가 준비됩니다.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (canUndo) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onUndo,
              child: const Text('마지막 채점 취소'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClearedView extends StatelessWidget {
  const _ClearedView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '모든 카드를 암기했어요.',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '카드를 추가하거나 암기한 카드를 다시 학습 상태로 돌려보세요.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
