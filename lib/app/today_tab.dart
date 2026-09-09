import 'package:flutter/material.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/models.dart' show TodayPhase;
import 'package:solvoca/ui/buttons.dart';
import 'package:solvoca/ui/study_card_surface.dart';
import 'package:solvoca/ui/tokens.dart';

class TodayTab extends StatelessWidget {
  const TodayTab({super.key, required this.controller});

  final StudyController controller;

  @override
  Widget build(BuildContext context) {
    final today = controller.today;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Solvoca',
              style: TextStyle(
                fontFamily: SolvocaTokens.fontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: SolvocaTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '암기 완료 ${today.masteredCount}장',
              style: const TextStyle(
                fontFamily: SolvocaTokens.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: SolvocaTokens.textSecondary,
              ),
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

class _PhaseCopy extends StatelessWidget {
  const _PhaseCopy({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: SolvocaTokens.accent),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: SolvocaTokens.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SolvocaTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: SolvocaTokens.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: SolvocaTokens.textSecondary,
          ),
        ),
      ],
    );
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: SolvocaTokens.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SolvocaTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 28),
        SolvocaPrimaryButton(label: '시작', onPressed: onStart),
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
      children: [
        Text(
          '남은 카드 $remainingCount장',
          style: const TextStyle(
            fontFamily: SolvocaTokens.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: SolvocaTokens.textSecondary,
          ),
        ),
        const Spacer(),
        StudyCardSurface(front: front, back: back, revealed: backRevealed),
        const SizedBox(height: 20),
        if (canUndo)
          Align(
            alignment: Alignment.centerRight,
            child: SolvocaTextAction(label: '마지막 채점 취소', onPressed: onUndo),
          ),
        if (!backRevealed)
          SolvocaPrimaryButton(
            label: '뒷면 보기',
            onPressed: onReveal,
            expand: true,
          )
        else
          Row(
            children: [
              Expanded(
                child: SolvocaSecondaryButton(
                  label: '몰랐다',
                  onPressed: onDidntKnow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SolvocaPrimaryButton(label: '알았다', onPressed: onKnew),
              ),
            ],
          ),
        const Spacer(),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _PhaseCopy(
            icon: Icons.nightlight_outlined,
            title: '오늘 학습을 마쳤어요.',
            body: '내일 새 카드가 준비됩니다.',
          ),
          if (canUndo) ...[
            const SizedBox(height: 24),
            SolvocaTextAction(label: '마지막 채점 취소', onPressed: onUndo),
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
    return const Center(
      child: _PhaseCopy(
        icon: Icons.check_circle_outline,
        title: '모든 카드를 암기했어요.',
        body: '카드를 추가하거나 암기한 카드를 다시 학습 상태로 돌려보세요.',
      ),
    );
  }
}
