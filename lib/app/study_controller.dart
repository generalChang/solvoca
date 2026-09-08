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

  void addCard({
    required String listId,
    required String front,
    required String back,
  }) {
    _study.addCard(listId: listId, front: front, back: back);
    notifyListeners();
  }

  void editCard({required String cardId, required String back}) {
    _study.editCard(cardId: cardId, back: back);
    notifyListeners();
  }

  void deleteCard({required String cardId}) {
    _study.deleteCard(cardId: cardId);
    notifyListeners();
  }

  void moveCard({required String cardId, required String listId}) {
    _study.moveCard(cardId: cardId, listId: listId);
    notifyListeners();
  }

  StudyList createList({required String name}) {
    final list = _study.createList(name: name);
    notifyListeners();
    return list;
  }

  void renameList({required String listId, required String name}) {
    _study.renameList(listId: listId, name: name);
    notifyListeners();
  }

  void deleteList({required String listId}) {
    _study.deleteList(listId: listId);
    notifyListeners();
  }

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

  void gradeDidntKnow() {
    _study.gradeDidntKnow();
    _backRevealed = false;
    notifyListeners();
  }

  void undoLastGrade() {
    _study.undoLastGrade();
    _backRevealed = false;
    notifyListeners();
  }
}

StudyController createStudyController({required Store store}) {
  return StudyController(
    study: Study(store: store, clock: SystemClock()),
  );
}
