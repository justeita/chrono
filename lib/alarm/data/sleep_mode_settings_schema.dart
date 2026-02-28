import 'package:clock_app/alarm/data/alarm_task_schemas.dart';
import 'package:clock_app/alarm/types/alarm_task.dart';
import 'package:clock_app/alarm/widgets/alarm_task_card.dart';
import 'package:clock_app/alarm/widgets/try_alarm_task_button.dart';
import 'package:clock_app/audio/audio_channels.dart';
import 'package:clock_app/audio/screens/ringtones_screen.dart';
import 'package:clock_app/audio/types/ringtone_player.dart';
import 'package:clock_app/common/data/weekdays.dart';
import 'package:clock_app/common/logic/tags.dart';
import 'package:clock_app/common/types/file_item.dart';
import 'package:clock_app/common/types/popup_action.dart';
import 'package:clock_app/common/types/tag.dart';
import 'package:clock_app/common/types/weekday.dart';
import 'package:clock_app/common/utils/ringtones.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/screens/tags_screen.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:clock_app/settings/types/setting_enable_condition.dart';
import 'package:clock_app/settings/types/setting_group.dart';
import 'package:clock_app/timer/types/time_duration.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';
import 'package:audio_session/audio_session.dart';

const sleepModeSchemaVersion = 1;

SettingGroup sleepModeSettingsSchema = SettingGroup(
  version: sleepModeSchemaVersion,
  "SleepModeSettings",
  (context) => AppLocalizations.of(context)!.sleepModeTitle,
  [
    StringSetting(
        "Label", (context) => AppLocalizations.of(context)!.labelField, ""),
    SettingGroup(
      "Schedule",
      (context) => AppLocalizations.of(context)!.alarmScheduleSettingGroup,
      [
        ToggleSetting(
          "Week Days",
          (context) => AppLocalizations.of(context)!.sleepModeWeekdaysSetting,
          weekdays
              .map((weekday) => ToggleSettingOption(
                  (context) => weekday.getAbbreviation(context), weekday.id))
              .toList(),
          getOffset: () {
            Weekday weekday = appSettings
                .getGroup("General")
                .getGroup("Display")
                .getSetting("First Day of Week")
                .value;
            return weekday.id - 1;
          },
        ),
      ],
      icon: Icons.calendar_today_rounded,
    ),
    SettingGroup(
      "Sound and Vibration",
      (context) => AppLocalizations.of(context)!.soundAndVibrationSettingGroup,
      [
        SettingGroup(
          "Sound",
          (context) => AppLocalizations.of(context)!.soundSettingGroup,
          [
            DynamicSelectSetting<FileItem>(
              "Melody",
              (context) => AppLocalizations.of(context)!.melodySetting,
              getRingtoneOptions,
              onChange: (context, index) {
                RingtonePlayer.stop();
              },
              actions: [
                MenuAction(
                  "Add",
                  (context) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RingtonesScreen()),
                    );
                  },
                  Icons.add,
                ),
              ],
            ),
            SliderSetting(
                "Volume",
                (context) => AppLocalizations.of(context)!.volumeSetting,
                0,
                100,
                100,
                unit: "%"),
            SwitchSetting(
              "Rising Volume",
              (context) => AppLocalizations.of(context)!.risingVolumeSetting,
              false,
            ),
            DurationSetting(
                "Time To Full Volume",
                (context) =>
                    AppLocalizations.of(context)!.timeToFullVolumeSetting,
                const TimeDuration(minutes: 1),
                enableConditions: [
                  ValueCondition(["Rising Volume"], (value) => value == true)
                ]),
            SelectSetting<AndroidAudioUsage>(
              "Audio Channel",
              (context) => AppLocalizations.of(context)!.audioChannelSetting,
              audioChannelOptions,
              onChange: (context, index) {
                RingtonePlayer.stop();
              },
            ),
          ],
        ),
        SwitchSetting("Vibration",
            (context) => AppLocalizations.of(context)!.vibrationSetting, false),
      ],
      icon: Icons.volume_up,
      summarySettings: [
        "Melody",
        "Vibration",
      ],
    ),
    SettingGroup(
      "Snooze",
      (context) => AppLocalizations.of(context)!.snoozeSettingGroup,
      [
        SwitchSetting(
            "Enabled",
            (context) => AppLocalizations.of(context)!.snoozeEnableSetting,
            true),
        SliderSetting(
            "Length",
            (context) => AppLocalizations.of(context)!.snoozeLengthSetting,
            1,
            30,
            5,
            unit: "minutes",
            enableConditions: [
              ValueCondition(["Enabled"], (value) => value == true)
            ]),
        SliderSetting(
            "Max Snoozes",
            (context) => AppLocalizations.of(context)!.maxSnoozesSetting,
            1,
            10,
            3,
            unit: "times",
            snapLength: 1,
            enableConditions: [
              ValueCondition(["Enabled"], (value) => value == true)
            ]),
      ],
      icon: Icons.snooze_rounded,
      summarySettings: [
        "Enabled",
        "Length",
      ],
    ),
    SettingGroup(
      "Dismiss Confirmation",
      (context) =>
          AppLocalizations.of(context)!.dismissConfirmationSettingGroup,
      [
        SwitchSetting(
          "Enabled",
          (context) =>
              AppLocalizations.of(context)!.dismissConfirmationEnabledSetting,
          true, // Default ON for sleep mode
          getDescription: (context) => AppLocalizations.of(context)!
              .dismissConfirmationEnabledSettingDescription,
        ),
        SliderSetting(
            "Wait Time",
            (context) =>
                AppLocalizations.of(context)!.dismissConfirmationTimeSetting,
            5,
            120,
            30,
            unit: "seconds",
            snapLength: 5,
            getDescription: (context) => AppLocalizations.of(context)!
                .dismissConfirmationTimeSettingDescription,
            enableConditions: [
              ValueCondition(["Enabled"], (value) => value == true)
            ]),
      ],
      icon: Icons.verified_user_rounded,
      summarySettings: [
        "Enabled",
        "Wait Time",
      ],
    ),
    CustomizableListSetting<AlarmTask>(
      "Tasks",
      (context) => AppLocalizations.of(context)!.tasksSetting,
      [],
      alarmTaskSchemasMap.keys.map((key) => AlarmTask(key)).toList(),
      addCardBuilder: (item) => AlarmTaskCard(task: item, isAddCard: true),
      cardBuilder: (item, [onDelete, onDuplicate]) => AlarmTaskCard(
        task: item,
        isAddCard: false,
        onPressDelete: onDelete,
        onPressDuplicate: onDuplicate,
      ),
      valueDisplayBuilder: (context, setting) {
        return Text("${setting.value.length} tasks");
      },
      itemPreviewBuilder: (item) => TryAlarmTaskButton(alarmTask: item),
    ),
    DynamicMultiSelectSetting<Tag>(
      "Tags",
      (context) => AppLocalizations.of(context)!.tagsSetting,
      getTagOptions,
      defaultValue: [],
      actions: [
        MenuAction(
          "Add",
          (context) async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TagsScreen()),
            );
          },
          Icons.add,
        ),
      ],
    ),
  ],
);
