import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class DismissConfirmationWidget extends StatefulWidget {
  const DismissConfirmationWidget({
    super.key,
    required this.waitTimeSeconds,
    required this.onConfirmed,
  });

  final int waitTimeSeconds;
  final VoidCallback onConfirmed;

  @override
  State<DismissConfirmationWidget> createState() =>
      _DismissConfirmationWidgetState();
}

class _DismissConfirmationWidgetState extends State<DismissConfirmationWidget>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _canConfirm = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.waitTimeSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canConfirm = true;
          timer.cancel();
          _pulseController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;

    final double progress = _canConfirm
        ? 1.0
        : 1.0 - (_remainingSeconds / widget.waitTimeSeconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _canConfirm ? Icons.alarm_off_rounded : Icons.access_alarm_rounded,
            size: 64,
            color: _canConfirm
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.dismissConfirmationTitle,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.dismissConfirmationSubtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _canConfirm
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (!_canConfirm)
                  Text(
                    '$_remainingSeconds',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                if (_canConfirm)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onConfirmed,
                        borderRadius: BorderRadius.circular(75),
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                          child: Center(
                            child: Text(
                              localizations.dismissConfirmationButton,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_canConfirm) ...[
            const SizedBox(height: 24),
            Text(
              localizations.dismissConfirmationWaiting(_remainingSeconds),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
