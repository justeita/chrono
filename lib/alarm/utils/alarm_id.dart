import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/alarm/types/sleep_mode.dart';
import 'package:clock_app/common/utils/list_storage.dart';

Alarm? getAlarmById(int id) {
  try {
    final List<Alarm> alarms = loadListSync('alarms');
    return alarms.firstWhere((alarm) => alarm.hasScheduleWithId(id));
  } catch (e) {
    // Not found in regular alarms, check sleep modes
    try {
      final List<SleepMode> sleepModes = loadListSync('sleep_modes');
      return sleepModes.firstWhere((sm) => sm.hasScheduleWithId(id)).wakeAlarm;
    } catch (e) {
      return null;
    }
  }
}

SleepMode? getSleepModeByAlarmId(int id) {
  try {
    final List<SleepMode> sleepModes = loadListSync('sleep_modes');
    return sleepModes.firstWhere((sm) => sm.hasScheduleWithId(id));
  } catch (e) {
    return null;
  }
}
