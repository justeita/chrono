import 'package:clock_app/common/logic/card_decoration.dart';
import 'package:clock_app/common/logic/clock_time_notifier.dart';
import 'package:clock_app/common/types/clock_settings_types.dart';
import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/clock/analog_clock/analog_clock_display.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as timezone;

class AnalogClock extends StatefulWidget {
  final bool showDigitalClock;
  final ClockTicksType ticksType;
  final ClockNumbersType numbersType;
  final ClockNumeralType numeralType;
  final timezone.Location? timezoneLocation;
  final bool showSeconds;

  const AnalogClock({
    super.key,
    this.showDigitalClock = false,
    this.ticksType = ClockTicksType.none,
    this.numbersType = ClockNumbersType.quarter,
    this.numeralType = ClockNumeralType.arabic,
    this.showSeconds = false,
    this.timezoneLocation,
  });

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  final ClockTimeNotifier _clockNotifier = ClockTimeNotifier.instance;

  @override
  void initState() {
    super.initState();
    _clockNotifier.startListening();
  }

  @override
  void dispose() {
    _clockNotifier.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return ValueListenableBuilder<DateTime>(
      valueListenable: _clockNotifier,
      builder: (context, now, _) {
        DateTime dateTime;
        if (widget.timezoneLocation != null) {
          dateTime = timezone.TZDateTime.now(widget.timezoneLocation!);
        } else {
          dateTime = now;
        }
        return Column(
          children: [
            AnalogClockDisplay(
              decoration: getCardDecoration(context,
                  color: getCardColor(context), boxShape: BoxShape.circle),
              width: 220.0,
              height: 220.0,
              isLive: true,
              hourHandColor: colorScheme.onSurface,
              minuteHandColor: colorScheme.onSurface,
              secondHandColor: colorScheme.primary,
              showSecondHand: widget.showSeconds,
              numberColor: colorScheme.onSurface,
              numbersType: widget.numbersType,
              ticksType: widget.ticksType,
              tickColor: colorScheme.onSurface.withValues(alpha: 0.6),
              numeralType: widget.numeralType,
              textScaleFactor: 1.4,
              digitalClockColor: colorScheme.onSurface.withValues(alpha: 0.6),
              showDigitalClock: widget.showDigitalClock,
              dateTime: dateTime,
            ),
          ],
        );
      },
    );
  }
}
