import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/models.dart';
import 'package:solvoca/study/store.dart';
import 'package:solvoca/study/study.dart';

void main() {
  group('Study', () {
    late MemoryStore store;
    late FixedClock clock;
    late Random random;
    late Study study;

    setUp(() {
      store = MemoryStore();
      clock = FixedClock(DateTime(2026, 9, 8));
      random = Random(42);
      study = Study(store: store, clock: clock, random: random);
    });

    Study studyFrom(StoreData data) {
      return Study(
        store: MemoryStore()..write(data),
        clock: clock,
        random: random,
      );
    }

    test('seeds five Lists and about two hundred Cards on empty Store', () {
      final lists = study.listLists();

      expect(lists.length, 5);
      expect(lists.map((list) => list.name).toSet(), {
        '일상',
        '사람',
        '일',
        '이동',
        '생각',
      });

      final cardCount = lists
          .map((list) => study.listCards(list.id).length)
          .fold<int>(0, (sum, count) => sum + count);
      expect(cardCount, greaterThanOrEqualTo(190));
      expect(cardCount, lessThanOrEqualTo(210));
    });

    test('Today waiting with ten New Cards spread across Lists', () {
      final today = study.inspectToday();

      expect(today.phase, TodayPhase.waiting);
      expect(today.remainingUngradedCount, 10);

      final queuedListIds = <String>{};
      for (final cardId in today.queuedCardIds) {
        queuedListIds.add(_findCard(study, cardId).listId);
      }

      expect(queuedListIds.length, greaterThan(1));
    });

    test('start shows front, gradeKnew makes Card Learning with Streak 1', () {
      study.startOrResumeQueue();
      final before = study.inspectToday();

      expect(before.phase, TodayPhase.inProgress);
      expect(before.currentFront, isNotNull);
      expect(before.currentBack, isNotNull);

      final cardId = before.currentCardId!;
      study.gradeKnew();

      final card = _findCard(study, cardId);
      expect(card.progress, CardProgress.learning);
      expect(card.streak, 1);
      expect(card.progress, isNot(CardProgress.mastered));

      final after = study.inspectToday();
      expect(after.remainingUngradedCount, 9);
      expect(after.currentCardId, isNot(cardId));
    });

    test('ten Knew Grades finish today with zero remaining', () {
      study.startOrResumeQueue();

      for (var i = 0; i < 10; i++) {
        study.gradeKnew();
      }

      final today = study.inspectToday();
      expect(today.remainingUngradedCount, 0);
      expect(today.phase, TodayPhase.dayComplete);
    });

    test('same local date keeps the same Queue', () {
      final firstDayQueue = study.inspectToday().queuedCardIds;

      study.startOrResumeQueue();
      study.gradeKnew();

      final reopened = Study(
        store: store,
        clock: clock,
        random: Random(99),
      );
      final secondView = reopened.inspectToday();

      expect(secondView.queuedCardIds, firstDayQueue);
      expect(secondView.remainingUngradedCount, 9);
    });

    test("Didn't know appends the current Card to the end of remaining Queue", () {
      final localStudy = studyFrom(_twoNewCards());

      localStudy.startOrResumeQueue();
      final before = localStudy.inspectToday();
      final currentId = before.currentCardId!;
      final otherId = before.queuedCardIds.firstWhere((id) => id != currentId);

      localStudy.gradeDidntKnow();

      final after = localStudy.inspectToday();
      expect(after.currentCardId, otherId);
      expect(after.queuedCardIds.last, currentId);
      expect(after.remainingUngradedCount, 2);
    });

    test("fourth Didn't know the same day does not reinsert; Card stays Learning", () {
      final localStudy = studyFrom(_oneNewCard());

      localStudy.startOrResumeQueue();
      final cardId = localStudy.inspectToday().currentCardId!;

      localStudy.gradeDidntKnow();
      localStudy.gradeDidntKnow();
      localStudy.gradeDidntKnow();

      expect(localStudy.inspectToday().remainingUngradedCount, 0);
      expect(localStudy.inspectToday().phase, TodayPhase.dayComplete);
      expect(_findCard(localStudy, cardId).progress, CardProgress.learning);

      localStudy.gradeDidntKnow();

      expect(localStudy.inspectToday().remainingUngradedCount, 0);
      expect(_findCard(localStudy, cardId).progress, CardProgress.learning);
    });

    test("Didn't know sets Streak to zero", () {
      final localStudy = studyFrom(
        StoreData(
          lists: const [StudyList(id: 'list-1', name: '일상')],
          cards: [
            Card(
              id: 'card-a',
              listId: 'list-1',
              front: 'hello',
              back: '안녕',
              progress: CardProgress.learning,
              streak: 2,
              lastKnewDate: DateTime(2026, 9, 7),
            ),
          ],
        ),
      );

      localStudy.startOrResumeQueue();
      localStudy.gradeDidntKnow();

      final card = _findCard(localStudy, 'card-a');
      expect(card.streak, 0);
      expect(card.progress, CardProgress.learning);
    });

    test('pause and resume same day keeps remaining ungraded Cards and Grades', () {
      study.startOrResumeQueue();
      final firstCardId = study.inspectToday().currentCardId!;
      study.gradeKnew();
      final secondCardId = study.inspectToday().currentCardId!;

      final reopened = Study(store: store, clock: clock, random: Random(99));
      final snapshot = reopened.inspectToday();

      expect(snapshot.phase, TodayPhase.inProgress);
      expect(snapshot.remainingUngradedCount, 9);
      expect(snapshot.queuedCardIds.length, 10);
      expect(snapshot.currentCardId, secondCardId);
      expect(_findCard(reopened, firstCardId).progress, CardProgress.learning);
      expect(_findCard(reopened, firstCardId).streak, 1);
    });

    test('undoLastGrade reverses Knew: Card returns to Queue and Streak restores', () {
      final localStudy = studyFrom(_twoNewCards());

      localStudy.startOrResumeQueue();
      final cardId = localStudy.inspectToday().currentCardId!;
      localStudy.gradeKnew();

      expect(localStudy.inspectToday().canUndoLastGrade, isTrue);
      localStudy.undoLastGrade();

      final card = _findCard(localStudy, cardId);
      expect(card.progress, CardProgress.cardNew);
      expect(card.streak, 0);
      expect(localStudy.inspectToday().currentCardId, cardId);
      expect(localStudy.inspectToday().remainingUngradedCount, 2);
      expect(localStudy.inspectToday().canUndoLastGrade, isFalse);
    });

    test('undoLastGrade reverses Didnt know: Queue place and Streak restore', () {
      final localStudy = studyFrom(
        StoreData(
          lists: const [StudyList(id: 'list-1', name: '일상')],
          cards: [
            Card(
              id: 'card-a',
              listId: 'list-1',
              front: 'hello',
              back: '안녕',
              progress: CardProgress.learning,
              streak: 2,
              lastKnewDate: DateTime(2026, 9, 7),
            ),
            Card(
              id: 'card-b',
              listId: 'list-1',
              front: 'world',
              back: '세계',
              progress: CardProgress.cardNew,
              streak: 0,
            ),
          ],
        ),
      );

      localStudy.startOrResumeQueue();
      final firstId = localStudy.inspectToday().currentCardId!;
      localStudy.gradeDidntKnow();

      expect(localStudy.inspectToday().currentCardId, isNot(firstId));
      expect(localStudy.inspectToday().canUndoLastGrade, isTrue);

      localStudy.undoLastGrade();

      expect(localStudy.inspectToday().currentCardId, firstId);
      expect(_findCard(localStudy, firstId).streak, 2);
      expect(localStudy.inspectToday().canUndoLastGrade, isFalse);
    });

    test('after a later Grade, earlier Grade cannot be undone', () {
      final localStudy = studyFrom(_twoNewCards());

      localStudy.startOrResumeQueue();
      final firstId = localStudy.inspectToday().currentCardId!;
      localStudy.gradeKnew();
      localStudy.gradeKnew();

      expect(localStudy.inspectToday().canUndoLastGrade, isTrue);
      localStudy.undoLastGrade();

      expect(_findCard(localStudy, firstId).progress, CardProgress.learning);
      expect(_findCard(localStudy, firstId).streak, 1);
      expect(localStudy.inspectToday().canUndoLastGrade, isFalse);
    });

    test('undo survives pause and resume on the same date', () {
      final memoryStore = MemoryStore()..write(_twoNewCards());
      final localStudy = Study(
        store: memoryStore,
        clock: clock,
        random: random,
      );

      localStudy.startOrResumeQueue();
      final cardId = localStudy.inspectToday().currentCardId!;
      localStudy.gradeKnew();

      final reopened = Study(
        store: memoryStore,
        clock: clock,
        random: random,
      );
      expect(reopened.inspectToday().canUndoLastGrade, isTrue);

      reopened.undoLastGrade();
      expect(_findCard(reopened, cardId).progress, CardProgress.cardNew);
      expect(reopened.inspectToday().currentCardId, cardId);
    });

    test('undoLastGrade on day complete restores the last Card to the Queue', () {
      final localStudy = studyFrom(_oneNewCard());

      localStudy.startOrResumeQueue();
      final cardId = localStudy.inspectToday().currentCardId!;
      localStudy.gradeKnew();

      expect(localStudy.inspectToday().phase, TodayPhase.dayComplete);
      expect(localStudy.inspectToday().canUndoLastGrade, isTrue);

      localStudy.undoLastGrade();

      expect(localStudy.inspectToday().phase, TodayPhase.inProgress);
      expect(localStudy.inspectToday().currentCardId, cardId);
      expect(localStudy.inspectToday().remainingUngradedCount, 1);
    });

    test("Day complete is reachable after Didn't know reinserts and the daily cap", () {
      final localStudy = studyFrom(_twoNewCards());

      localStudy.startOrResumeQueue();
      final firstId = localStudy.inspectToday().currentCardId!;

      localStudy.gradeDidntKnow();
      final secondId = localStudy.inspectToday().currentCardId!;
      expect(secondId, isNot(firstId));

      localStudy.gradeDidntKnow();
      localStudy.gradeDidntKnow();
      localStudy.gradeKnew();
      expect(localStudy.inspectToday().currentCardId, firstId);

      localStudy.gradeDidntKnow();

      final today = localStudy.inspectToday();
      expect(today.remainingUngradedCount, 0);
      expect(today.phase, TodayPhase.dayComplete);
      expect(_findCard(localStudy, firstId).progress, CardProgress.learning);
      expect(_findCard(localStudy, secondId).progress, CardProgress.learning);
    });

    test('reopening same day after Day complete stays Day complete', () {
      final memoryStore = MemoryStore()..write(_oneNewCard());
      final localStudy = Study(
        store: memoryStore,
        clock: clock,
        random: random,
      );

      localStudy.startOrResumeQueue();
      localStudy.gradeKnew();

      expect(localStudy.inspectToday().phase, TodayPhase.dayComplete);

      final reopened = Study(
        store: memoryStore,
        clock: clock,
        random: Random(99),
      );
      expect(reopened.inspectToday().phase, TodayPhase.dayComplete);
      expect(reopened.inspectToday().remainingUngradedCount, 0);

      reopened.startOrResumeQueue();
      expect(reopened.inspectToday().phase, TodayPhase.dayComplete);
    });

    test('next local date builds a fresh Queue; yesterday pause does not leak', () {
      final memoryStore = MemoryStore();
      final dayOne = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 8)),
        random: Random(42),
      );

      dayOne.startOrResumeQueue();
      final dayOneRemainingBeforePause = dayOne.inspectToday().remainingUngradedCount;
      final dayOneQueue = dayOne.inspectToday().queuedCardIds;
      dayOne.gradeKnew();

      final paused = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 8)),
        random: Random(99),
      );
      expect(paused.inspectToday().phase, TodayPhase.inProgress);
      expect(paused.inspectToday().remainingUngradedCount, dayOneRemainingBeforePause - 1);

      final dayTwo = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 9)),
        random: Random(99),
      );
      final snapshot = dayTwo.inspectToday();

      expect(snapshot.phase, TodayPhase.waiting);
      expect(snapshot.queuedCardIds, isNot(dayOneQueue));
      expect(snapshot.remainingUngradedCount, 10);
    });

    test('three consecutive Knew days on a Learning Card makes it Mastered', () {
      final memoryStore = MemoryStore()..write(_oneNewCard());

      for (final (day, expectedStreak, expectedProgress) in [
        (8, 1, CardProgress.learning),
        (9, 2, CardProgress.learning),
        (10, 3, CardProgress.mastered),
      ]) {
        final localStudy = Study(
          store: memoryStore,
          clock: FixedClock(DateTime(2026, 9, day)),
          random: Random(1),
        );
        localStudy.startOrResumeQueue();
        localStudy.gradeKnew();

        final card = _findCard(localStudy, 'card-a');
        expect(card.streak, expectedStreak);
        expect(card.progress, expectedProgress);
      }
    });

    test('Streak advances only on consecutive local dates', () {
      final memoryStore = MemoryStore()..write(_oneNewCard());

      var localStudy = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 8)),
        random: Random(1),
      );
      localStudy.startOrResumeQueue();
      localStudy.gradeKnew();
      expect(_findCard(localStudy, 'card-a').streak, 1);

      localStudy = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 10)),
        random: Random(1),
      );
      localStudy.startOrResumeQueue();
      localStudy.gradeKnew();

      final card = _findCard(localStudy, 'card-a');
      expect(card.streak, 1);
      expect(card.progress, CardProgress.learning);
    });

    test('Mastered Card is not in the next default Queue', () {
      final memoryStore = MemoryStore()..write(_oneNewCard());

      for (final day in [8, 9, 10]) {
        final localStudy = Study(
          store: memoryStore,
          clock: FixedClock(DateTime(2026, 9, day)),
          random: Random(1),
        );
        localStudy.startOrResumeQueue();
        localStudy.gradeKnew();
      }

      final dayFour = Study(
        store: memoryStore,
        clock: FixedClock(DateTime(2026, 9, 11)),
        random: Random(1),
      );
      final snapshot = dayFour.inspectToday();

      expect(_findCard(dayFour, 'card-a').progress, CardProgress.mastered);
      expect(snapshot.queuedCardIds, isNot(contains('card-a')));
    });

    test('inspectToday reports Mastered count', () {
      final memoryStore = MemoryStore()..write(
        StoreData(
          lists: const [StudyList(id: 'list-1', name: '일상')],
          cards: [
            Card(
              id: 'card-a',
              listId: 'list-1',
              front: 'hello',
              back: '안녕',
              progress: CardProgress.mastered,
              streak: 3,
              lastKnewDate: DateTime(2026, 9, 7),
            ),
            Card(
              id: 'card-b',
              listId: 'list-1',
              front: 'world',
              back: '세계',
              progress: CardProgress.cardNew,
              streak: 0,
            ),
          ],
        ),
      );

      final localStudy = Study(
        store: memoryStore,
        clock: clock,
        random: random,
      );

      expect(localStudy.inspectToday().masteredCount, 1);
    });
  });
}

StoreData _oneNewCard() {
  return const StoreData(
    lists: [StudyList(id: 'list-1', name: '일상')],
    cards: [
      Card(
        id: 'card-a',
        listId: 'list-1',
        front: 'hello',
        back: '안녕',
        progress: CardProgress.cardNew,
        streak: 0,
      ),
    ],
  );
}

StoreData _twoNewCards() {
  return const StoreData(
    lists: [StudyList(id: 'list-1', name: '일상')],
    cards: [
      Card(
        id: 'card-a',
        listId: 'list-1',
        front: 'hello',
        back: '안녕',
        progress: CardProgress.cardNew,
        streak: 0,
      ),
      Card(
        id: 'card-b',
        listId: 'list-1',
        front: 'world',
        back: '세계',
        progress: CardProgress.cardNew,
        streak: 0,
      ),
    ],
  );
}

Card _findCard(Study study, String cardId) {
  for (final list in study.listLists()) {
    for (final card in study.listCards(list.id)) {
      if (card.id == cardId) {
        return card;
      }
    }
  }
  throw StateError('Card not found: $cardId');
}
