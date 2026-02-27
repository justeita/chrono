import 'package:clock_app/common/types/json.dart';
import 'package:clock_app/common/types/list_item.dart';
import 'package:clock_app/timer/types/time_duration.dart';

class Lap extends ListItem {
  late int _number;
  late TimeDuration lapTime;
  late TimeDuration elapsedTime;
  late bool isActive;

  int get number => _number;
  @override
  int get id => number;
  @override
  bool get isDeletable => false;

  Lap(
      {required int number,
      this.elapsedTime = const TimeDuration(),
      this.lapTime = const TimeDuration(),
      this.isActive = false})
      : _number = number;

  Lap.fromJson(Json? json) {
    if (json == null) {
      _number = 0;
      lapTime = TimeDuration.zero;
      elapsedTime = TimeDuration.zero;
      isActive = false;
      return;
    }
    _number = json['number'] ?? 0;
    lapTime = TimeDuration.fromJson(json['lapTime']);
    elapsedTime = TimeDuration.fromJson(json['elapsedTime']);
    isActive = json['isActive'] ?? false;
  }

  @override
  Json toJson() => {
        'number': number,
        'lapTime': lapTime.toJson(),
        'elapsedTime': elapsedTime.toJson(),
        'isActive': isActive,
      };

  @override
  copy() {
    return Lap(
        elapsedTime: elapsedTime,
        number: number,
        lapTime: lapTime,
        isActive: isActive);
  }

  @override
  void copyFrom(other) {
    _number = other.number;
    lapTime = TimeDuration.from(other.lapTime);
    elapsedTime = TimeDuration.from(other.elapsedTime);
    isActive = other.isActive;
  }
}
