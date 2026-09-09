import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solvoca/app/solvoca_app.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/store.dart';
import 'package:solvoca/study/study.dart';

Future<void> pumpSolvoca(WidgetTester tester, StudyController controller) async {
  await tester.pumpWidget(SolvocaApp(controller: controller));
  await tester.pumpAndSettle();
}

Future<void> expectNoExceptions(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.takeException(), isNull, reason: 'frame $i');
  }
}

void main() {
  late StudyController controller;

  setUp(() {
    controller = StudyController(
      study: Study(
        store: MemoryStore(),
        clock: FixedClock(DateTime(2026, 9, 8)),
      ),
    );
  });

  testWidgets('grade knew on today tab', (tester) async {
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('뒷면 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('알았다'));
    await expectNoExceptions(tester);
  });

  testWidgets('add card sheet', (tester) async {
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'newword');
    await tester.enterText(find.byType(TextField).at(1), '새단어');
    await tester.tap(find.text('추가'));
    await expectNoExceptions(tester);
  });

  testWidgets('delete card', (tester) async {
    final list = controller.listLists().first;
    final card = controller.listCards(list.id).first;
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(list.name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(card.front));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await expectNoExceptions(tester);
  });

  testWidgets('move card', (tester) async {
    final lists = controller.listLists();
    final list = lists.first;
    final other = lists[1];
    final card = controller.listCards(list.id).first;
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(list.name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(card.front));
    await tester.pumpAndSettle();
    await tester.tap(find.text('목록 이동'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(other.name));
    await expectNoExceptions(tester);
  });

  testWidgets('create list dialog', (tester) async {
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('목록 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '새 목록');
    await tester.tap(find.text('추가'));
    await expectNoExceptions(tester);
  });
}
