import 'dart:math';

import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/models.dart';
import 'package:solvoca/study/seed.dart';
import 'package:solvoca/study/store.dart';

class Study {
  Study({
    required Store store,
    required Clock clock,
    Random? random,
  })  : _store = store,
        _clock = clock,
        _random = random ?? Random() {
    _load();
  }

  final Store _store;
  final Clock _clock;
  final Random _random;
  late StoreData _data;

  void _load() {
    final stored = _store.read();
    if (stored == null || stored.isEmpty) {
      _data = buildSeedData();
      _ensureQueueForToday();
      _persist();
      return;
    }

    _data = stored;
    _ensureQueueForToday();
  }

  void _persist() {
    _store.write(_data);
  }

  DateTime get _today => _clock.now.localDate;

  String get _todayKey => _today.dateKey;

  void _ensureQueueForToday() {
    if (_data.queueByDate.containsKey(_todayKey)) {
      return;
    }

    final queue = _buildFirstFillQueue();
    _data = _data.copyWith(
      queueByDate: {
        ..._data.queueByDate,
        _todayKey: DayQueue(
          date: _today,
          cardIds: queue,
          gradedCardIds: const [],
        ),
      },
    );
  }

  List<String> _buildFirstFillQueue() {
    const cap = 10;
    final learningCards =
        _data.cards.where((card) => card.progress == CardProgress.learning);
    final learningIds = learningCards.map((card) => card.id).toList();

    if (learningIds.length > cap) {
      final shuffled = List<String>.from(learningIds)..shuffle(_random);
      return shuffled.take(cap).toList();
    }

    final queue = <String>[...learningIds];
    if (queue.length >= cap) {
      return queue;
    }

    final newByList = <String, List<Card>>{};
    for (final list in _data.lists) {
      final newCards = _data.cards
          .where(
            (card) =>
                card.listId == list.id && card.progress == CardProgress.cardNew,
          )
          .toList();
      if (newCards.isNotEmpty) {
        newByList[list.id] = newCards;
      }
    }

    final listOrder = _data.lists
        .map((list) => list.id)
        .where(newByList.containsKey)
        .toList();

    while (queue.length < cap && listOrder.isNotEmpty) {
      var added = false;
      for (final listId in listOrder) {
        if (queue.length >= cap) {
          break;
        }

        final available = newByList[listId]!
            .where((card) => !queue.contains(card.id))
            .toList();
        if (available.isEmpty) {
          continue;
        }

        final pick = available[_random.nextInt(available.length)];
        queue.add(pick.id);
        added = true;
      }

      if (!added) {
        break;
      }
    }

    return queue;
  }

  Card? _cardById(String id) {
    for (final card in _data.cards) {
      if (card.id == id) {
        return card;
      }
    }
    return null;
  }

  DayQueue? get _todayQueue => _data.queueByDate[_todayKey];

  TodaySnapshot inspectToday() {
    final queue = _todayQueue;
    if (queue == null) {
      return TodaySnapshot(
        phase: TodayPhase.cleared,
        remainingUngradedCount: 0,
        masteredCount: _masteredCount,
        queuedCardIds: const [],
      );
    }

    final remainingIds = _remainingCardIds(queue);
    final remainingCount = remainingIds.length;
    final started = _data.startedDates.contains(_todayKey);

    TodayPhase phase;
    String? currentId;
    String? currentFront;
    String? currentBack;

    if (remainingCount == 0) {
      phase = TodayPhase.dayComplete;
    } else if (started) {
      phase = TodayPhase.inProgress;
      currentId = remainingIds.first;
      final card = _cardById(currentId);
      currentFront = card?.front;
      currentBack = card?.back;
    } else {
      phase = TodayPhase.waiting;
    }

    return TodaySnapshot(
      phase: phase,
      remainingUngradedCount: remainingCount,
      masteredCount: _masteredCount,
      queuedCardIds: List.unmodifiable(queue.cardIds),
      currentCardId: currentId,
      currentFront: currentFront,
      currentBack: currentBack,
    );
  }

  int get _masteredCount =>
      _data.cards.where((card) => card.progress == CardProgress.mastered).length;

  List<String> _remainingCardIds(DayQueue queue) {
    return queue.cardIds
        .where((id) => !queue.gradedCardIds.contains(id))
        .toList();
  }

  void startOrResumeQueue() {
    final queue = _todayQueue;
    if (queue == null) {
      return;
    }

    if (_remainingCardIds(queue).isEmpty) {
      return;
    }

    _data = _data.copyWith(
      startedDates: {..._data.startedDates, _todayKey},
    );
    _persist();
  }

  void gradeKnew() {
    final queue = _todayQueue;
    if (queue == null) {
      return;
    }

    final remaining = _remainingCardIds(queue);
    if (remaining.isEmpty) {
      return;
    }

    final cardId = remaining.first;
    final card = _cardById(cardId);
    if (card == null) {
      return;
    }

    final updatedCard = _applyKnewGrade(card);
    final updatedCards = _data.cards
        .map((existing) => existing.id == cardId ? updatedCard : existing)
        .toList();

    final updatedQueue = queue.copyWith(
      gradedCardIds: [...queue.gradedCardIds, cardId],
    );

    _data = _data.copyWith(
      cards: updatedCards,
      queueByDate: {..._data.queueByDate, _todayKey: updatedQueue},
      startedDates: {..._data.startedDates, _todayKey},
    );
    _persist();
  }

  Card _applyKnewGrade(Card card) {
    final today = _today;
    final newStreak = card.progress == CardProgress.cardNew
        ? 1
        : _nextStreakAfterKnew(card, today);
    final newProgress = newStreak >= 3 ? CardProgress.mastered : CardProgress.learning;

    return card.copyWith(
      progress: newProgress,
      streak: newStreak,
      lastKnewDate: today,
    );
  }

  int _nextStreakAfterKnew(Card card, DateTime today) {
    final last = card.lastKnewDate?.localDate;
    if (last == null) {
      return 1;
    }

    final difference = today.difference(last).inDays;
    if (difference == 0) {
      return card.streak;
    }
    if (difference == 1) {
      return card.streak + 1;
    }
    return 1;
  }

  List<StudyList> listLists() {
    return List.unmodifiable(_data.lists);
  }

  List<Card> listCards(String listId) {
    return List.unmodifiable(
      _data.cards.where((card) => card.listId == listId),
    );
  }
}
