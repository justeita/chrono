import 'package:clock_app/system/data/device_info.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void initForegroundTask() {
  final brand = androidInfo?.brand.toLowerCase();
  final isPoco = brand == 'poco' || brand == 'xiaomi';

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.drawable,
        resPrefix: ResourcePrefix.ic,
        name: 'alarm_icon',
      ),
      // buttons: [
      //   const NotificationButton(id: 'sendButton', text: 'Send'),
      //   const NotificationButton(id: 'testButton', text: 'Test'),
      // ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      interval: 1000 * 60,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: isPoco,
      allowWifiLock: false,
    ),
  );
}
