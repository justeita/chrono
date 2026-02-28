import 'package:clock_app/alarm/types/sleep_mode.dart';
import 'package:clock_app/alarm/widgets/sleep_mode_card.dart';
import 'package:clock_app/alarm/widgets/sleep_mode_time_picker.dart';
import 'package:clock_app/common/logic/customize_screen.dart';
import 'package:clock_app/common/types/time.dart';
import 'package:clock_app/common/widgets/fab.dart';
import 'package:clock_app/common/widgets/list/customize_list_item_screen.dart';
import 'package:clock_app/common/widgets/list/persistent_list_view.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  final _listController = PersistentListController<SleepMode>();

  Future<SleepMode?> _openCustomizeScreen(
    SleepMode sleepMode, {
    Future<void> Function(SleepMode)? onSave,
    bool isNew = false,
  }) async {
    return openCustomizeScreen(
      context,
      CustomizeListItemScreen(
        item: sleepMode,
        isNewItem: isNew,
        headerBuilder: (item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SleepModeTimePicker(sleepMode: item),
        ),
      ),
      onSave: onSave,
    );
  }

  Future<void> _handleCustomize(SleepMode sleepMode) async {
    await _openCustomizeScreen(sleepMode, onSave: (newItem) async {
      await sleepMode.wakeAlarm.cancel();
      sleepMode.copyFrom(newItem);
      await sleepMode.handleEdit("Sleep mode edited by user");
      _listController.changeItems((_) {});
    });
  }

  Future<void> _handleEnableChange(SleepMode sleepMode, bool value) async {
    await sleepMode.setIsEnabled(value, "Sleep mode enable set to $value");
    _listController.changeItems((_) {});
  }

  void _handleDelete(SleepMode sleepMode) {
    _listController.deleteItem(sleepMode);
  }

  Future<void> _handleDismiss(SleepMode sleepMode) async {
    await sleepMode.cancelSnooze();
    await sleepMode.update("Sleep mode dismissed by user");
    _listController.changeItems((_) {});
  }

  Future<void> _addSleepMode() async {
    // Open customize screen directly with default values
    SleepMode sleepMode = SleepMode(
      bedtime: const Time(hour: 22, minute: 0),
      wakeTime: const Time(hour: 7, minute: 0),
    );

    await _openCustomizeScreen(sleepMode, onSave: (newItem) async {
      _listController.addItem(newItem);
    }, isNew: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PersistentListView<SleepMode>(
          saveTag: 'sleep_modes',
          listController: _listController,
          itemBuilder: (sleepMode) => SleepModeCard(
            sleepMode: sleepMode,
            onEnabledChange: (value) => _handleEnableChange(sleepMode, value),
            onPressDelete: () => _handleDelete(sleepMode),
            onPressDuplicate: () => _listController.duplicateItem(sleepMode),
            onDismiss: () => _handleDismiss(sleepMode),
          ),
          onTapItem: (sleepMode, index) => _handleCustomize(sleepMode),
          onAddItem: (sleepMode) async {
            await sleepMode.update("Sleep mode added by user");
          },
          onDeleteItem: (sleepMode) async {
            await sleepMode.disable();
          },
          placeholderText: AppLocalizations.of(context)!.noSleepModeMessage,
          reloadOnPop: true,
          isSelectable: true,
        ),
        FAB(
          onPressed: _addSleepMode,
          icon: Icons.bedtime_rounded,
        ),
      ],
    );
  }
}
