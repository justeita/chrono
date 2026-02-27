import 'package:clock_app/common/widgets/circular_progress_bar.dart';
import 'package:clock_app/timer/types/time_duration.dart';
import 'package:clock_app/timer/types/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TimerProgressBar extends StatefulWidget {
  const TimerProgressBar({super.key, required this.timer, required this.size, this.centerWidget, this.textScale = 1.0});

  final ClockTimer timer;
  final double size;
  final double textScale;
  final Widget? centerWidget;

  @override
  State<TimerProgressBar> createState() => _TimerProgressBarState();
}

class _TimerProgressBarState extends State<TimerProgressBar>
    with SingleTickerProviderStateMixin {
  late Ticker ticker;
  late ValueNotifier<double> valueNotifier;
  double maxValue = 0;

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(widget.timer.remainingMilliseconds.toDouble());
    maxValue = widget.timer.currentDuration.inMilliseconds.toDouble();
    ticker = createTicker((elapsed) {
      valueNotifier.value = widget.timer.remainingMilliseconds.toDouble();
      maxValue = widget.timer.currentDuration.inMilliseconds.toDouble();
    });
    // Only start if timer is running
    if (widget.timer.isRunning) {
      ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant TimerProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync ticker with timer state
    if (widget.timer.isRunning && !ticker.isActive) {
      ticker.start();
    } else if (!widget.timer.isRunning && ticker.isActive) {
      ticker.stop();
    }
    // Update value immediately for paused/stopped state
    valueNotifier.value = widget.timer.remainingMilliseconds.toDouble();
    maxValue = widget.timer.currentDuration.inMilliseconds.toDouble();
  }

    @override
  void dispose() {
    ticker.dispose();
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  CircularProgressBar(
              size: widget.size,
              valueNotifier: valueNotifier,
              progressStrokeWidth: 8,
              backStrokeWidth: 8,
              maxValue: maxValue,
              mergeMode: true,
              // animationDuration: 0,
              onGetCenterWidget: (value) {
                if(widget.centerWidget != null) return widget.centerWidget!;
                final secs = (value / 1000).round();
                return Text(
                  TimeDuration.fromSeconds(secs).toTimeString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: (secs > 3600 ? 48 : 64) * widget.textScale,
                      ),
                );
              },
              progressColors: [Theme.of(context).colorScheme.primary],
              backColor: Colors.black.withValues(alpha: 0.15),
            );
  }
}
