import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solvoca/app/solvoca_app.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/store.dart';
import 'package:solvoca/study/study.dart';
import 'package:solvoca/ui/study_card_surface.dart';
import 'package:solvoca/ui/tokens.dart';

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

  testWidgets('app is light-only latte cream', (tester) async {
    await pumpSolvoca(tester, controller);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(app.darkTheme, isNull);
    expect(app.theme!.scaffoldBackgroundColor, SolvocaTokens.background);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('오늘'), findsOneWidget);
    expect(find.text('카드'), findsOneWidget);
    await expectNoExceptions(tester);
  });

  testWidgets('study card keeps height when the back is revealed', (
    tester,
  ) async {
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle();

    expect(find.byType(StudyCardSurface), findsOneWidget);
    final before = tester.getSize(find.byType(StudyCardSurface));
    expect(before.height, SolvocaTokens.studyCardHeight);

    await tester.tap(find.text('뒷면 보기'));
    await tester.pumpAndSettle();

    final after = tester.getSize(find.byType(StudyCardSurface));
    expect(after.height, before.height);
    expect(find.text('알았다'), findsOneWidget);
    expect(find.text('몰랐다'), findsOneWidget);
    await expectNoExceptions(tester);
  });

  testWidgets('cards tab puts list add in the header and keeps one card add', (
    tester,
  ) async {
    await pumpSolvoca(tester, controller);
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('목록 추가'), findsOneWidget);
    expect(find.text('목록 추가'), findsOneWidget);
    expect(find.text('카드 추가'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    await expectNoExceptions(tester);
  });
}
