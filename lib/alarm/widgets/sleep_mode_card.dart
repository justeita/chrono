import 'package:clock_app/alarm/types/sleep_mode.dart';
import 'package:clock_app/clock/types/time.dart';
import 'package:clock_app/common/utils/popup_action.dart';
import 'package:clock_app/common/widgets/card_edit_menu.dart';
import 'package:clock_app/common/widgets/clock/digital_clock_display.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class SleepModeCard extends StatefulWidget {
  const SleepModeCard({
    super.key,
    required this.sleepMode,
    required this.onEnabledChange,
    required this.onPressDelete,
    required this.onPressDuplicate,
    required this.onDismiss,
  });

  final SleepMode sleepMode;
  final void Function(bool) onEnabledChange;
  final void Function() onDismiss;
  final VoidCallback onPressDelete;
  final VoidCallback onPressDuplicate;

  @override
  State<SleepModeCard> createState() => _SleepModeCardState();
}

class _SleepModeCardState extends State<SleepModeCard> {
  late TimeFormat timeFormat;
  late Setting timeFormatSetting;

  void setTimeFormat(dynamic newTimeFormat) {
    setState(() {
      timeFormat = newTimeFormat;
    });
  }

  @override
  void initState() {
    super.initState();
    timeFormatSetting = appSettings
        .getGroup("General")
        .getGroup("Display")
        .getSetting("Time Format");
    timeFormatSetting.addListener(setTimeFormat);
    setTimeFormat(timeFormatSetting.value);
  }

  @override
  void dispose() {
    timeFormatSetting.removeListener(setTimeFormat);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    const double disabledAlpha = 0.4;
    final bool enabled = widget.sleepMode.isEnabled;

    Widget getActionWidget() {
      if (widget.sleepMode.isSnoozed) {
        return TextButton(
          onPressed: widget.onDismiss,
          child: Text(localizations.dismissAlarmButton,
              maxLines: 1,
              style:
                  textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
        );
      }
      return Switch(
        value: enabled,
        onChanged: widget.onEnabledChange,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Moon icon to differentiate from regular alarms
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.bedtime_rounded,
              color: enabled
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface.withValues(alpha: disabledAlpha),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.sleepMode.label.isNotEmpty)
                    Text(
                      widget.sleepMode.label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: enabled
                            ? colorScheme.onSurface.withValues(alpha: 0.8)
                            : colorScheme.onSurface
                                .withValues(alpha: disabledAlpha),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Bedtime and wake time row
                  Row(
                    children: [
                      // Bedtime
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.nights_stay_rounded,
                            size: 16,
                            color: enabled
                                ? colorScheme.onSurface.withValues(alpha: 0.6)
                                : colorScheme.onSurface
                                    .withValues(alpha: disabledAlpha),
                          ),
                          const SizedBox(width: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: DigitalClockDisplay(
                              dateTime: widget.sleepMode.bedtime.toDateTime(),
                              scale: 0.35,
                              color: enabled
                                  ? null
                                  : colorScheme.onSurface
                                      .withValues(alpha: disabledAlpha),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: enabled
                              ? colorScheme.onSurface.withValues(alpha: 0.4)
                              : colorScheme.onSurface
                                  .withValues(alpha: disabledAlpha),
                        ),
                      ),
                      // Wake time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_sunny_rounded,
                            size: 16,
                            color: enabled
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withValues(alpha: disabledAlpha),
                          ),
                          const SizedBox(width: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: DigitalClockDisplay(
                              dateTime:
                                  widget.sleepMode.wakeTime.toDateTime(),
                              scale: 0.35,
                              color: enabled
                                  ? null
                                  : colorScheme.onSurface
                                      .withValues(alpha: disabledAlpha),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Sleep duration and schedule info
                  Row(
                    children: [
                      Icon(
                        Icons.hotel_rounded,
                        size: 14,
                        color: enabled
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface
                                .withValues(alpha: disabledAlpha),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.sleepMode.sleepDurationString,
                        style: textTheme.bodySmall?.copyWith(
                          color: enabled
                              ? colorScheme.onSurface.withValues(alpha: 0.6)
                              : colorScheme.onSurface
                                  .withValues(alpha: disabledAlpha),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: enabled
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface
                                .withValues(alpha: disabledAlpha),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.sleepMode.repeatDescription(context),
                          style: textTheme.bodySmall?.copyWith(
                            color: enabled
                                ? colorScheme.onSurface.withValues(alpha: 0.6)
                                : colorScheme.onSurface
                                    .withValues(alpha: disabledAlpha),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              getActionWidget(),
              CardEditMenu(actions: [
                getDuplicatePopupAction(context, widget.onPressDuplicate),
                if (widget.sleepMode.isDeletable)
                  getDeletePopupAction(context, widget.onPressDelete),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
