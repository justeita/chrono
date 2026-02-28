import 'dart:isolate';
import 'dart:ui';

import 'package:clock_app/alarm/logic/alarm_isolate.dart';
import 'package:clock_app/alarm/logic/schedule_alarm.dart';
import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/alarm/types/sleep_mode.dart';
import 'package:clock_app/common/types/notification_type.dart';
import 'package:clock_app/common/types/schedule_id.dart';
import 'package:clock_app/common/utils/list_storage.dart';
import 'package:clock_app/developer/logic/logger.dart';

Future<void> cancelAllAlarms() async {
  List<ScheduleId> scheduleIds =
      await loadList<ScheduleId>('alarm_schedule_ids');
  for (var scheduleId in scheduleIds) {
    try {
      await cancelAlarm(scheduleId.id, ScheduledNotificationType.alarm);
    } catch (e) {
      logger.e("Error canceling alarm ${scheduleId.id}: $e");
    }
  }
  scheduleIds.clear();
  await saveList('alarm_schedule_ids', scheduleIds);
}

Future<void> updateAlarm(int scheduleId, String description) async {
  try {
    List<Alarm> alarms = await loadList("alarms");
    int alarmIndex =
        alarms.indexWhere((alarm) => alarm.hasScheduleWithId(scheduleId));

    if (alarmIndex != -1) {
      Alarm alarm = alarms[alarmIndex];

      await alarm.update(description);

      if (alarm.isMarkedForDeletion) {
        await alarm.disable();
        alarms.removeAt(alarmIndex);
      } else {
        alarms[alarmIndex] = alarm;
      }
      await saveList("alarms", alarms);
      return;
    }

    // Check sleep modes if not found in regular alarms
    List<SleepMode> sleepModes = await loadList("sleep_modes");
    int sleepIndex =
        sleepModes.indexWhere((sm) => sm.hasScheduleWithId(scheduleId));

    if (sleepIndex != -1) {
      SleepMode sleepMode = sleepModes[sleepIndex];
      await sleepMode.update(description);
      sleepModes[sleepIndex] = sleepMode;
      await saveList("sleep_modes", sleepModes);
      return;
    }

    logger.e("Alarm with scheduleId $scheduleId not found during update");
  } catch (e) {
    logger.e("Error updating alarm $scheduleId: $e");
  }
}

// Update the state of all the alarms and save them to the disk
// This is called both when an alarm triggers, as well as when the device boots
// up, so we can check for alarms that rung when the device was off
Future<void> updateAlarms(String description) async {
  await cancelAllAlarms();

  List<Alarm> alarms = await loadList("alarms");

  List<Alarm> corruptAlarms = [];
  for (Alarm alarm in alarms) {
    try {
      await alarm.update(description);
      if (alarm.isMarkedForDeletion) {
        await alarm.disable();
      }
    } catch (e) {
      logger.e("Error updating alarm ${alarm.id}: $e");
      corruptAlarms.add(alarm);
      try {
        await alarm.disable();
      } catch (_) {}
    }
  }

  alarms.removeWhere(
      (alarm) => alarm.isMarkedForDeletion || corruptAlarms.contains(alarm));

  await saveList("alarms", alarms);

  // Also update sleep mode alarms
  List<SleepMode> sleepModes = await loadList("sleep_modes");
  for (SleepMode sleepMode in sleepModes) {
    try {
      await sleepMode.update(description);
    } catch (e) {
      logger.e("Error updating sleep mode ${sleepMode.id}: $e");
    }
  }
  await saveList("sleep_modes", sleepModes);

  // Notify other isolates that are listening for alarm updates
  SendPort? sendPort = IsolateNameServer.lookupPortByName(updatePortName);
  sendPort?.send("updateAlarms");
}

Future<void> updateAlarmById(
    int scheduleId, Future<void> Function(Alarm) callback) async {
  try {
    List<Alarm> alarms = await loadList("alarms");
    int alarmIndex =
        alarms.indexWhere((alarm) => alarm.hasScheduleWithId(scheduleId));

    if (alarmIndex != -1) {
      Alarm alarm = alarms[alarmIndex];
      await callback(alarm);
      if (alarm.isMarkedForDeletion) {
        await alarm.disable();
        alarms.removeAt(alarmIndex);
      } else {
        alarms[alarmIndex] = alarm;
      }
      await saveList("alarms", alarms);

      SendPort? sendPort = IsolateNameServer.lookupPortByName(updatePortName);
      sendPort?.send("updateAlarms");
      return;
    }

    // Check sleep modes if not found in regular alarms
    List<SleepMode> sleepModes = await loadList("sleep_modes");
    int sleepIndex =
        sleepModes.indexWhere((sm) => sm.hasScheduleWithId(scheduleId));

    if (sleepIndex != -1) {
      SleepMode sleepMode = sleepModes[sleepIndex];
      await callback(sleepMode.wakeAlarm);
      sleepModes[sleepIndex] = sleepMode;
      await saveList("sleep_modes", sleepModes);

      SendPort? sendPort = IsolateNameServer.lookupPortByName(updatePortName);
      sendPort?.send("updateAlarms");
      return;
    }
  } catch (e) {
    logger.e("Error updating alarm by id $scheduleId: $e");
  }
}
