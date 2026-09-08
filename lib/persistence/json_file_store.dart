import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:solvoca/study/models.dart';
import 'package:solvoca/study/store.dart';

class JsonFileStore implements Store {
  JsonFileStore({this.fileName = 'solvoca_store'});

  final String fileName;
  StoreData? _data;

  @override
  StoreData? read() => _data;

  @override
  void write(StoreData data) {
    _data = data;
    _persist(data);
  }

  Future<void> load() async {
    final file = await _storeFile();
    if (!await file.exists()) {
      _data = null;
      return;
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _data = _decodeStore(decoded);
  }

  Future<File> _storeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName.json');
  }

  Future<void> _persist(StoreData data) async {
    final file = await _storeFile();
    await file.writeAsString(jsonEncode(_encodeStore(data)));
  }
}

Map<String, dynamic> _encodeStore(StoreData data) {
  return {
    'lists': data.lists
        .map((list) => {'id': list.id, 'name': list.name})
        .toList(),
    'cards': data.cards.map(_encodeCard).toList(),
    'queueByDate': data.queueByDate.map(
      (key, queue) => MapEntry(key, _encodeQueue(queue)),
    ),
    'startedDates': data.startedDates.toList(),
  };
}

Map<String, dynamic> _encodeCard(Card card) {
  return {
    'id': card.id,
    'listId': card.listId,
    'front': card.front,
    'back': card.back,
    'progress': card.progress.name,
    'streak': card.streak,
    'lastKnewDate': card.lastKnewDate?.toIso8601String(),
  };
}

Map<String, dynamic> _encodeQueue(DayQueue queue) {
  return {
    'date': queue.date.toIso8601String(),
    'cardIds': queue.cardIds,
    'gradedCardIds': queue.gradedCardIds,
  };
}

StoreData _decodeStore(Map<String, dynamic> json) {
  return StoreData(
    lists: (json['lists'] as List<dynamic>)
        .map(
          (raw) => StudyList(
            id: raw['id'] as String,
            name: raw['name'] as String,
          ),
        )
        .toList(),
    cards: (json['cards'] as List<dynamic>)
        .map((raw) => _decodeCard(raw as Map<String, dynamic>))
        .toList(),
    queueByDate: (json['queueByDate'] as Map<String, dynamic>).map(
      (key, raw) => MapEntry(key, _decodeQueue(raw as Map<String, dynamic>)),
    ),
    startedDates: (json['startedDates'] as List<dynamic>)
        .map((value) => value as String)
        .toSet(),
  );
}

Card _decodeCard(Map<String, dynamic> json) {
  return Card(
    id: json['id'] as String,
    listId: json['listId'] as String,
    front: json['front'] as String,
    back: json['back'] as String,
    progress: CardProgress.values.byName(json['progress'] as String),
    streak: json['streak'] as int,
    lastKnewDate: json['lastKnewDate'] == null
        ? null
        : DateTime.parse(json['lastKnewDate'] as String),
  );
}

DayQueue _decodeQueue(Map<String, dynamic> json) {
  return DayQueue(
    date: DateTime.parse(json['date'] as String),
    cardIds: (json['cardIds'] as List<dynamic>).cast<String>(),
    gradedCardIds: (json['gradedCardIds'] as List<dynamic>).cast<String>(),
  );
}
