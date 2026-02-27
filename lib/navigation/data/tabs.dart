import 'package:clock_app/alarm/screens/alarm_screen.dart';
import 'package:clock_app/navigation/types/quick_action_controller.dart';
import 'package:clock_app/stopwatch/screens/stopwatch_screen.dart';
import 'package:clock_app/timer/screens/timer_screen.dart';

import 'package:clock_app/icons/flux_icons.dart';
import 'package:clock_app/clock/screens/clock_screen.dart';
import 'package:clock_app/navigation/types/tab.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:clock_app/l10n/app_localizations.dart';

List<Tab> getTabs(BuildContext context,
    [QuickActionController? actionController]) {
  return [
    Tab(
        id: "alarm",
        title: AppLocalizations.of(context)!.alarmTitle,
        icon: FluxIcons.alarm,
        widget: RepaintBoundary(
            child: AlarmScreen(actionController: actionController))),
    Tab(
        id: "clock",
        title: AppLocalizations.of(context)!.clockTitle,
        icon: FluxIcons.clock,
        widget: const RepaintBoundary(child: ClockScreen())),
    Tab(
        id: "timer",
        title: AppLocalizations.of(context)!.timerTitle,
        icon: FluxIcons.timer,
        widget: RepaintBoundary(
            child: TimerScreen(actionController: actionController))),
    Tab(
        id: "stopwatch",
        title: AppLocalizations.of(context)!.stopwatchTitle,
        icon: FluxIcons.stopwatch,
        widget: const RepaintBoundary(child: StopwatchScreen())),
  ];
}
