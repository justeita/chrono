import 'package:clock_app/alarm/types/sleep_mode.dart';
import 'package:clock_app/common/types/picker_result.dart';
import 'package:clock_app/common/widgets/clock/digital_clock_display.dart';
import 'package:clock_app/common/widgets/time_picker.dart';
import 'package:clock_app/navigation/types/alignment.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class SleepModeTimePicker extends StatefulWidget {
  const SleepModeTimePicker({super.key, required this.sleepMode});

  final SleepMode sleepMode;

  @override
  State<SleepModeTimePicker> createState() => _SleepModeTimePickerState();
}

class _SleepModeTimePickerState extends State<SleepModeTimePicker> {
  Future<void> _pickTime({
    required TimeOfDay initialTime,
    required String title,
    required void Function(TimeOfDay) onPicked,
  }) async {
    PickerResult<TimeOfDay>? result = await showTimePickerDialog(
      context: context,
      initialTime: initialTime,
      title: title,
      cancelText: AppLocalizations.of(context)!.cancelButton,
      confirmText: AppLocalizations.of(context)!.saveButton,
    );
    if (result != null) {
      setState(() {
        onPicked(result.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Bedtime row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6), size: 28),
            const SizedBox(width: 8),
            Text(
              localizations.sleepModeBedtimeLabel,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _pickTime(
            initialTime: widget.sleepMode.bedtime.toTimeOfDay(),
            title: localizations.sleepModeBedtimeLabel,
            onPicked: widget.sleepMode.setBedtimeFromTimeOfDay,
          ),
          child: DigitalClockDisplay(
            dateTime: widget.sleepMode.bedtime.toDateTime(),
            horizontalAlignment: ElementAlignment.center,
            scale: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        // Wake time row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny_rounded, color: colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              localizations.sleepModeWakeLabel,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _pickTime(
            initialTime: widget.sleepMode.wakeTime.toTimeOfDay(),
            title: localizations.sleepModeWakeLabel,
            onPicked: widget.sleepMode.setWakeTimeFromTimeOfDay,
          ),
          child: DigitalClockDisplay(
            dateTime: widget.sleepMode.wakeTime.toDateTime(),
            horizontalAlignment: ElementAlignment.center,
            scale: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        // Sleep duration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hotel_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                '${localizations.sleepModeDurationLabel}: ${widget.sleepMode.sleepDurationString}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
