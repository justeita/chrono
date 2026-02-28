import 'package:clock_app/alarm/data/sleep_mode_settings_schema.dart';
import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/alarm/types/alarm_task.dart';
import 'package:clock_app/common/types/file_item.dart';
import 'package:clock_app/common/types/json.dart';
import 'package:clock_app/common/types/list_item.dart';
import 'package:clock_app/common/types/tag.dart';
import 'package:clock_app/common/types/time.dart';
import 'package:clock_app/common/utils/id.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:clock_app/settings/types/setting_group.dart';
import 'package:flutter/material.dart';

/// SleepMode represents a bedtime schedule.
/// It wraps an Alarm for the wake-up time and adds bedtime info +
/// dismiss confirmation settings.
///
/// Settings flow: SleepMode has its own settings (from sleepModeSettingsSchema)
/// that the user edits. Before scheduling the alarm, we sync these settings
/// to the wrapped alarm via JSON serialization, so the alarm plays the correct
/// ringtone, volume, etc.
class SleepMode extends CustomizableListItem {
  late int _id;
  late Time _bedtime;
  late Time _wakeTime;
  bool _isEnabled = true;
  late Alarm _wakeAlarm;
  late SettingGroup _settings;

  SleepMode({
    required Time bedtime,
    required Time wakeTime,
  })  : _bedtime = bedtime,
        _wakeTime = wakeTime,
        _id = getId() {
    _settings = SettingGroup(
      "Sleep Mode Settings",
      (context) => "Sleep Mode Settings",
      sleepModeSettingsSchema.copy().settingItems,
    );
    _wakeAlarm = Alarm(wakeTime);
    _applySettingsToAlarm();
  }

  SleepMode.fromSleepMode(SleepMode other)
      : _id = getId(),
        _bedtime = other._bedtime,
        _wakeTime = other._wakeTime,
        _isEnabled = other._isEnabled,
        _settings = other._settings.copy(),
        _wakeAlarm = Alarm.fromAlarm(other._wakeAlarm);

  @override
  int get id => _wakeAlarm.id;
  @override
  bool get isDeletable => _wakeAlarm.isDeletable;

  Time get bedtime => _bedtime;
  Time get wakeTime => _wakeTime;
  bool get isEnabled => _isEnabled;
  bool get isFinished => _wakeAlarm.isFinished;
  bool get isSnoozed => _wakeAlarm.isSnoozed;
  DateTime? get snoozeTime => _wakeAlarm.snoozeTime;
  DateTime? get currentScheduleDateTime => _wakeAlarm.currentScheduleDateTime;
  Alarm get wakeAlarm => _wakeAlarm;

  @override
  SettingGroup get settings => _settings;

  String get label => _settings.getSetting("Label").value;
  FileItem get ringtone => _settings.getSetting("Melody").value;
  bool get vibrate => _settings.getSetting("Vibration").value;
  double get volume => _settings.getSetting("Volume").value;
  List<AlarmTask> get tasks => _settings.getSetting("Tasks").value;
  List<Tag> get tags => _settings.getSetting("Tags").value;
  bool get canBeSnoozed =>
      _settings.getGroup("Snooze").getSetting("Enabled").value;
  double get snoozeLength => _settings.getSetting("Length").value;
  int get maxSnoozes => _settings.getSetting("Max Snoozes").value.toInt();

  bool get dismissConfirmationEnabled =>
      _settings.getGroup("Dismiss Confirmation").getSetting("Enabled").value;
  double get dismissConfirmationWaitTime =>
      _settings.getGroup("Dismiss Confirmation").getSetting("Wait Time").value;

  List<int> get selectedWeekdayIds {
    final toggleSetting = _settings.getSetting("Week Days") as ToggleSetting;
    return toggleSetting.selected.cast<int>();
  }

  /// Calculate sleep duration between bedtime and wake time
  Duration get sleepDuration {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    int diff = wakeMinutes - bedMinutes;
    if (diff <= 0) diff += 24 * 60; // crosses midnight
    return Duration(minutes: diff);
  }

  String get sleepDurationString {
    final duration = sleepDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Sync sleep mode settings to the wake alarm before scheduling.
  ///
  /// This copies matching settings (Label, Sound, Vibration, Snooze, Tasks,
  /// Tags, Week Days) from the sleep mode settings to the alarm's settings
  /// via JSON serialization. Non-matching keys keep their defaults.
  /// The schedule type is forced to Weekly (index 2).
  void _applySettingsToAlarm() {
    final sleepModeJson = _settings.valueToJson();
    _wakeAlarm.settings.loadValueFromJson(sleepModeJson);

    // Force schedule type to Weekly (index 2 in alarm schedule types:
    // 0=Once, 1=Daily, 2=Weekly, 3=Dates, 4=Range)
    _wakeAlarm.setSettingWithoutNotify("Type", 2);
  }

  void setBedtime(Time time) {
    _bedtime = time;
  }

  void setWakeTime(Time time) {
    _wakeTime = time;
    _wakeAlarm.setTime(time);
  }

  void setBedtimeFromTimeOfDay(TimeOfDay timeOfDay) {
    _bedtime = Time.fromTimeOfDay(timeOfDay);
  }

  void setWakeTimeFromTimeOfDay(TimeOfDay timeOfDay) {
    _wakeTime = Time.fromTimeOfDay(timeOfDay);
    _wakeAlarm.setTimeFromTimeOfDay(timeOfDay);
  }

  Future<void> enable(String description) async {
    _isEnabled = true;
    _applySettingsToAlarm();
    await _wakeAlarm.enable(description);
  }

  Future<void> disable() async {
    _isEnabled = false;
    await _wakeAlarm.disable();
  }

  Future<void> toggle(String description) async {
    if (_isEnabled) {
      await disable();
    } else {
      await enable(description);
    }
  }

  Future<void> setIsEnabled(bool enabled, String description) async {
    if (enabled) {
      await enable(description);
    } else {
      await disable();
    }
  }

  Future<void> update(String description) async {
    if (_isEnabled) {
      _applySettingsToAlarm();
      await _wakeAlarm.update(description);
      if (_wakeAlarm.isFinished) {
        await disable();
      }
    }
  }

  Future<void> handleEdit(String description) async {
    _applySettingsToAlarm();
    _wakeAlarm.setTime(_wakeTime);
    await _wakeAlarm.handleEdit(description);
    _isEnabled = true;
  }

  Future<void> cancelSnooze() async {
    await _wakeAlarm.cancelSnooze();
  }

  bool hasScheduleWithId(int scheduleId) {
    return _wakeAlarm.hasScheduleWithId(scheduleId);
  }

  @override
  copy() {
    return SleepMode.fromSleepMode(this);
  }

  @override
  void copyFrom(dynamic other) {
    SleepMode o = other as SleepMode;
    _id = o._id;
    _bedtime = o._bedtime;
    _wakeTime = o._wakeTime;
    _isEnabled = o._isEnabled;
    _settings = o._settings.copy();
    _wakeAlarm.copyFrom(o._wakeAlarm);
  }

  SleepMode.fromJson(Json json) {
    if (json == null) {
      _id = getId();
      _bedtime = const Time(hour: 22, minute: 0);
      _wakeTime = const Time(hour: 7, minute: 0);
      _settings = SettingGroup(
        "Sleep Mode Settings",
        (context) => "Sleep Mode Settings",
        sleepModeSettingsSchema.copy().settingItems,
      );
      _wakeAlarm = Alarm(_wakeTime);
      return;
    }
    _id = json['id'] ?? getId();
    _bedtime = json['bedtime'] != null
        ? Time.fromJson(json['bedtime'])
        : const Time(hour: 22, minute: 0);
    _wakeTime = json['wakeTime'] != null
        ? Time.fromJson(json['wakeTime'])
        : const Time(hour: 7, minute: 0);
    _isEnabled = json['enabled'] ?? false;
    _settings = SettingGroup(
      "Sleep Mode Settings",
      (context) => "Sleep Mode Settings",
      sleepModeSettingsSchema.copy().settingItems,
    );
    _settings.loadValueFromJson(json['settings']);
    _wakeAlarm = json['wakeAlarm'] != null
        ? Alarm.fromJson(json['wakeAlarm'])
        : Alarm(_wakeTime);
  }

  @override
  Json toJson() => {
        'id': _id,
        'bedtime': _bedtime.toJson(),
        'wakeTime': _wakeTime.toJson(),
        'enabled': _isEnabled,
        'settings': _settings.valueToJson(),
        'wakeAlarm': _wakeAlarm.toJson(),
      };
}
