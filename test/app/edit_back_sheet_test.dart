import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solvoca/app/cards_tab.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/store.dart';
import 'package:solvoca/study/study.dart';

void main() {
  testWidgets('closing edit back sheet does not use disposed controller', (
    tester,
  ) async {
    final controller = StudyController(
      study: Study(
        store: MemoryStore(),
        clock: FixedClock(DateTime(2026, 9, 8)),
      ),
    );
    final list = controller.listLists().first;
    final card = controller.listCards(list.id).first;

    await tester.pumpWidget(
      MaterialApp(
        home: CardDetailScreen(controller: controller, card: card),
      ),
    );

    await tester.tap(find.text('뒷면 수정'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('저장'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
