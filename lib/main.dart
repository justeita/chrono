import 'dart:core';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:clock_app/alarm/logic/update_alarms.dart';
import 'package:clock_app/app.dart';
import 'package:clock_app/audio/logic/audio_session.dart';
import 'package:clock_app/audio/types/ringtone_player.dart';
import 'package:clock_app/common/data/paths.dart';
import 'package:clock_app/navigation/types/app_visibility.dart';
import 'package:clock_app/notifications/logic/foreground_task.dart';
import 'package:clock_app/notifications/logic/notifications.dart';
import 'package:clock_app/settings/logic/initialize_settings.dart';
import 'package:clock_app/system/data/app_info.dart';
import 'package:clock_app/system/data/device_info.dart';
import 'package:clock_app/system/logic/background_service.dart';
import 'package:clock_app/system/logic/initialize_isolate_ports.dart';
import 'package:clock_app/timer/logic/update_timers.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_boot_receiver/flutter_boot_receiver.dart';
import 'package:flutter_show_when_locked/flutter_show_when_locked.dart';
import 'package:timezone/data/latest_all.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone init is synchronous and fast - do it first
  initializeTimeZones();

  // Phase 1: Parallelize all independent initializations
  final initializeData = [
    initializePackageInfo(),
    initializeAndroidInfo(),
    initializeAppDataDirectory(),
    initializeNotifications(),
    AndroidAlarmManager.initialize(),
    // BootReceiver.initialize(handleBoot), // Disabled: flutter_boot_receiver uses removed v1 embedding APIs
    RingtonePlayer.initialize(),
    initializeAudioSession(),
    FlutterShowWhenLocked().hide(),
  ];
  await Future.wait(initializeData);

  // Phase 2: Storage & settings (depends on app data directory)
  await initializeStorage();
  await initializeSettings();

  // Phase 3: Parallelize alarm/timer updates (both are independent)
  await Future.wait([
    updateAlarms("Update Alarms on Start"),
    updateTimers("Update Timers on Start"),
  ]);

  // Phase 4: Synchronous lightweight inits
  AppVisibility.initialize();
  initForegroundTask();
  initBackgroundService();
  initializeIsolatePorts();

  runApp(const App());

  // Register headless service after app is running (non-blocking)
  registerHeadlessBackgroundService();
}
