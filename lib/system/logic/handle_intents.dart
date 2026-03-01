import 'dart:convert';

import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/alarm/types/schedules/weekly_alarm_schedule.dart';
import 'package:clock_app/common/types/notification_type.dart';
import 'package:clock_app/common/utils/list_storage.dart';
import 'package:clock_app/developer/logic/logger.dart';
import 'package:clock_app/navigation/types/app_visibility.dart';
import 'package:clock_app/notifications/logic/alarm_notifications.dart';
import 'package:clock_app/settings/types/listener_manager.dart';
import 'package:clock_app/timer/types/time_duration.dart';
import 'package:clock_app/timer/types/timer.dart';

import 'package:flutter/material.dart' hide Intent;
import 'package:receive_intent/receive_intent.dart';

void handleIntent(Intent? receivedIntent, BuildContext context,
    Function(Alarm) onSetAlarm, Function(int, [String?]) setTab) async {
  if (receivedIntent != null) {
    logger.i(
        "Intent received ${receivedIntent.action} ${receivedIntent.data} ${receivedIntent.extra}");
    switch (receivedIntent.action) {
      case "android.intent.action.MAIN":
        final params = receivedIntent.extra?["params"];
        if (params != null) {
          ScheduledNotificationType notificationType = ScheduledNotificationType
              .values
              .byName(jsonDecode(params)['type']);
          if (notificationType == ScheduledNotificationType.alarm) {
            setTab(0);
          }
        }
        break;
      case "android.intent.action.SET_ALARM":
        int? hour = receivedIntent.extra?["android.intent.extra.alarm.HOUR"];
        int? minute =
            receivedIntent.extra?["android.intent.extra.alarm.MINUTES"];
        bool skipUi =
            receivedIntent.extra?["android.intent.extra.alarm.SKIP_UI"] ??
                false;
        bool? vibration =
            receivedIntent.extra?["android.intent.extra.alarm.VIBRATE"];
        String? message =
            receivedIntent.extra?["android.intent.extra.alarm.MESSAGE"];
        List<int>? days =
            receivedIntent.extra?["android.intent.extra.alarm.DAYS"];
        if (hour == null || minute == null || !skipUi) {
          setTab(0);
        } else {
          Alarm alarm =
              Alarm.fromTimeOfDay(TimeOfDay(hour: hour, minute: minute));
          if (vibration != null) {
            alarm.setSetting(context, "Vibrate", vibration);
          }
          if (days != null) {
            for (int i = 0; i < days.length; i++) {
              days[i] = (days[i] + 1) % 7;
              if (days[i] == 0) days[i] = 7;
            }

            List<bool> settingDays = List.filled(7, false);
            for (int day in days) {
              settingDays[day - 1] = true;
            }
            alarm.setSetting(context, "Type", WeeklyAlarmSchedule);
            alarm.setSetting(context, "Week Days", settingDays);
          }
          if (message != null) {
            alarm.setSetting(context, "Label", message);
          }

          alarm.update("handleIntent(): Alarm set by external app");
          List<Alarm> alarms = await loadList<Alarm>("alarms");
          alarms.add(alarm);
          await saveList("alarms", alarms);
          onSetAlarm(alarm);

          ListenerManager.notifyListeners("alarms");
        }
        break;
      case "android.intent.action.SNOOZE_ALARM":
        setTab(0);
        break;
      case "android.intent.action.SET_TIMER":
        int? length =
            receivedIntent.extra?["android.intent.extra.alarm.LENGTH"];
        bool skipUiTimer =
            receivedIntent.extra?["android.intent.extra.alarm.SKIP_UI"] ??
                false;
        String? messageTimer =
            receivedIntent.extra?["android.intent.extra.alarm.MESSAGE"];

        if (length == null || !skipUiTimer) {
          setTab(2);
        } else {
          ClockTimer timer = ClockTimer(TimeDuration.fromSeconds(length));
          if (messageTimer != null) {
            timer.setSettingWithoutNotify("Label", messageTimer);
          }
          await timer.start();
          List<ClockTimer> timers = await loadList<ClockTimer>("timers");
          timers.add(timer);
          await saveList("timers", timers);
          ListenerManager.notifyListeners("timers");
          // update timer notification using appropriate logic later
        }
        break;
      case "android.intent.action.SET_STOPWATCH":
        setTab(3); // Just open tab. Standard Google Assistant lacks this anyway
        break;
      case "android.intent.action.VIEW_ALARMS":
      case "android.intent.action.SHOW_ALARMS":
        setTab(0);
        break;
      case "android.intent.action.VIEW_TIMERS":
      case "android.intent.action.SHOW_TIMERS":
        setTab(2);
        break;
      case "android.intent.action.DISMISS_ALARM":
        setTab(0);
        break;
      case "android.intent.action.DISMISS_TIMER":
        setTab(2);
        break;
      case "SELECT_NOTIFICATION":
        appVisibilityWhenAlarmNotificationCreated = AppVisibility.state;
        break;
      default:
        break;
    }
  }
}
