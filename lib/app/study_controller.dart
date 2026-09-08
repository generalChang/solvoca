import 'package:flutter/foundation.dart';
import 'package:solvoca/study/clock.dart';
import 'package:solvoca/study/models.dart';
import 'package:solvoca/study/store.dart';
import 'package:solvoca/study/study.dart';

class StudyController extends ChangeNotifier {
  StudyController({required Study study}) : _study = study;

  final Study _study;
  bool _backRevealed = false;

  TodaySnapshot get today => _study.inspectToday();
  bool get backRevealed => _backRevealed;

  List<StudyList> listLists() => _study.listLists();

  List<Card> listCards(String listId) => _study.listCards(listId);

  void startOrResumeQueue() {
    _study.startOrResumeQueue();
    _backRevealed = false;
    notifyListeners();
  }

  void revealBack() {
    _backRevealed = true;
    notifyListeners();
  }

  void gradeKnew() {
    _study.gradeKnew();
    _backRevealed = false;
    notifyListeners();
  }
}

StudyController createStudyController({required Store store}) {
  return StudyController(
    study: Study(store: store, clock: SystemClock()),
  );
}
