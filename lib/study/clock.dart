abstract class Clock {
  DateTime get now;
}

class SystemClock implements Clock {
  @override
  DateTime get now => DateTime.now();
}

class FixedClock implements Clock {
  FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime get now => _now;
}

extension LocalDate on DateTime {
  DateTime get localDate => DateTime(year, month, day);

  String get dateKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
