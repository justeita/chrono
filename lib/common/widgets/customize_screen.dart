import 'package:clock_app/common/types/list_item.dart';
import 'package:clock_app/navigation/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/l10n/app_localizations.dart';

class CustomizeState {
  bool isSaved = false;
  bool isChanged = false;
}

class CustomizeScreen<Item extends CustomizableListItem>
    extends StatefulWidget {
  const CustomizeScreen({
    super.key,
    required this.item,
    this.onSave,
    required this.builder,
    required this.isNewItem,
  });

  final Item item;
  final void Function(Item item)? onSave;
  final Widget Function(BuildContext context, Item item) builder;
  final bool isNewItem;

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState<Item>();
}

class _CustomizeScreenState<Item extends CustomizableListItem>
    extends State<CustomizeScreen<Item>> {
  late final Item _item = widget.item.copy();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppTopBar(actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            AppLocalizations.of(context)!.cancelButton,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: () {
              widget.onSave?.call(_item);
              _isSaved = true;
              Navigator.pop(context, _item);
            },
            child: Text(AppLocalizations.of(context)!.saveButton),
          ),
        )
      ]),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_isSaved ||
              (_item.hasSameSettingsAs(widget.item) && !widget.isNewItem)) {
            Navigator.pop(context);
            return;
          }
          bool? shouldPop = await showDialog<bool>(
            context: context,
            builder: (buildContext) {
              return AlertDialog(
                actionsPadding: const EdgeInsets.only(bottom: 6, right: 10),
                content: Text(AppLocalizations.of(context)!.saveReminderAlert),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(AppLocalizations.of(context)!.noButton,
                        style: TextStyle(color: colorScheme.primary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(AppLocalizations.of(context)!.yesButton,
                        style: TextStyle(color: colorScheme.error)),
                  ),
                ],
              );
            },
          );
          if (shouldPop ?? false) {
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: widget.builder(context, _item),
      ),
    );
  }
}
