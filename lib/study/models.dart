enum CardProgress { cardNew, learning, mastered }

enum TodayPhase { waiting, inProgress, dayComplete, cleared }

class StudyList {
  const StudyList({required this.id, required this.name});

  final String id;
  final String name;
}

class Card {
  const Card({
    required this.id,
    required this.listId,
    required this.front,
    required this.back,
    required this.progress,
    required this.streak,
    this.lastKnewDate,
  });

  final String id;
  final String listId;
  final String front;
  final String back;
  final CardProgress progress;
  final int streak;
  final DateTime? lastKnewDate;

  Card copyWith({
    CardProgress? progress,
    int? streak,
    DateTime? lastKnewDate,
    bool clearLastKnewDate = false,
  }) {
    return Card(
      id: id,
      listId: listId,
      front: front,
      back: back,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      lastKnewDate: clearLastKnewDate ? null : (lastKnewDate ?? this.lastKnewDate),
    );
  }
}

class TodaySnapshot {
  const TodaySnapshot({
    required this.phase,
    required this.remainingUngradedCount,
    required this.masteredCount,
    required this.queuedCardIds,
    this.currentCardId,
    this.currentFront,
    this.currentBack,
    this.canUndoLastGrade = false,
  });

  final TodayPhase phase;
  final int remainingUngradedCount;
  final int masteredCount;
  final List<String> queuedCardIds;
  final String? currentCardId;
  final String? currentFront;
  final String? currentBack;
  final bool canUndoLastGrade;
}

class GradeUndoSnapshot {
  const GradeUndoSnapshot({
    required this.cardId,
    required this.cardBefore,
    required this.cardIds,
    required this.gradedCardIds,
    required this.didntKnowCounts,
  });

  final String cardId;
  final Card cardBefore;
  final List<String> cardIds;
  final List<String> gradedCardIds;
  final Map<String, int> didntKnowCounts;
}

class DayQueue {
  const DayQueue({
    required this.date,
    required this.cardIds,
    required this.gradedCardIds,
    this.didntKnowCounts = const {},
    this.lastGradeUndo,
  });

  final DateTime date;
  final List<String> cardIds;
  final List<String> gradedCardIds;
  final Map<String, int> didntKnowCounts;
  final GradeUndoSnapshot? lastGradeUndo;

  DayQueue copyWith({
    List<String>? cardIds,
    List<String>? gradedCardIds,
    Map<String, int>? didntKnowCounts,
    GradeUndoSnapshot? lastGradeUndo,
    bool clearLastGradeUndo = false,
  }) {
    return DayQueue(
      date: date,
      cardIds: cardIds ?? this.cardIds,
      gradedCardIds: gradedCardIds ?? this.gradedCardIds,
      didntKnowCounts: didntKnowCounts ?? this.didntKnowCounts,
      lastGradeUndo:
          clearLastGradeUndo ? null : (lastGradeUndo ?? this.lastGradeUndo),
    );
  }
}

class StoreData {
  const StoreData({
    required this.lists,
    required this.cards,
    this.queueByDate = const {},
    this.startedDates = const {},
  });

  final List<StudyList> lists;
  final List<Card> cards;
  final Map<String, DayQueue> queueByDate;
  final Set<String> startedDates;

  StoreData copyWith({
    List<StudyList>? lists,
    List<Card>? cards,
    Map<String, DayQueue>? queueByDate,
    Set<String>? startedDates,
  }) {
    return StoreData(
      lists: lists ?? this.lists,
      cards: cards ?? this.cards,
      queueByDate: queueByDate ?? this.queueByDate,
      startedDates: startedDates ?? this.startedDates,
    );
  }

  bool get isEmpty => lists.isEmpty && cards.isEmpty;
}
