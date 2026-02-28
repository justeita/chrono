import 'package:clock_app/alarm/screens/alarm_screen.dart';
import 'package:clock_app/alarm/screens/sleep_mode_screen.dart';
import 'package:clock_app/navigation/types/quick_action_controller.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class AlarmTabScreen extends StatefulWidget {
  const AlarmTabScreen({super.key, this.actionController});

  final QuickActionController? actionController;

  @override
  State<AlarmTabScreen> createState() => _AlarmTabScreenState();
}

class _AlarmTabScreenState extends State<AlarmTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: colorScheme.onPrimaryContainer,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
            splashBorderRadius: BorderRadius.circular(12),
            tabs: [
              Tab(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.alarm_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(localizations.alarmTitle),
                  ],
                ),
              ),
              Tab(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bedtime_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(localizations.sleepModeTitle),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AlarmScreen(actionController: widget.actionController),
              const SleepModeScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
