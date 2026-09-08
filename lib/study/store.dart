import 'package:solvoca/study/models.dart';

abstract class Store {
  StoreData? read();
  void write(StoreData data);
}

class MemoryStore implements Store {
  StoreData? _data;

  @override
  StoreData? read() => _data;

  @override
  void write(StoreData data) {
    _data = data;
  }
}
