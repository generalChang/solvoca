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
        onReveal: controller.revealBack,
        onKnew: controller.gradeKnew,
        onDidntKnow: controller.gradeDidntKnow,
      ),
      TodayPhase.dayComplete => const _DayCompleteView(),
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
    required this.onReveal,
    required this.onKnew,
    required this.onDidntKnow,
  });

  final String front;
  final String back;
  final bool backRevealed;
  final int remainingCount;
  final VoidCallback onReveal;
  final VoidCallback onKnew;
  final VoidCallback onDidntKnow;

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
  const _DayCompleteView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '오늘 학습을 마쳤어요.',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ClearedView extends StatelessWidget {
  const _ClearedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '학습할 카드가 없어요.',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
