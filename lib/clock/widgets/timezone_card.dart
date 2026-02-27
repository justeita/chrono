import 'package:clock_app/clock/types/city.dart';
import 'package:clock_app/common/utils/popup_action.dart';
import 'package:clock_app/common/widgets/card_edit_menu.dart';
import 'package:clock_app/common/widgets/clock/digital_clock.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:clock_app/l10n/app_localizations.dart';

class TimeZoneCard extends StatelessWidget {
  TimeZoneCard({
    super.key,
    required this.city,
    required this.onDelete,
  }) {
    _timezoneLocation = timezone.getLocation(city.timezone);
    _offset = (_timezoneLocation.currentTimeZone.offset -
            DateTime.now().timeZoneOffset.inMilliseconds) /
        3600000;
  }

  late final timezone.Location _timezoneLocation;
  late final double _offset;
  final VoidCallback onDelete;
  final City city;

  String _formatTimeOffset(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  String _getOffsetDescription(BuildContext context) {
    String hourDifference = _formatTimeOffset(_offset.abs());
    String relativeLabel = _offset < 0 ? 'behind' : 'ahead';
    String differentOffsetLabel = AppLocalizations.of(context)!
        .relativeTime(hourDifference, relativeLabel);
    String offsetLabel = _offset != 0
        ? differentOffsetLabel
        : AppLocalizations.of(context)!.sameTime;

    return offsetLabel;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DigitalClock(
                  timezoneLocation: _timezoneLocation,
                  scale: 0.4,
                ),
                const SizedBox(height: 4),
                Text(
                  city.name,
                  style: textTheme.displaySmall
                      ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        // const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getOffsetDescription(context),
                style: textTheme.bodyMedium?.copyWith(
                    height: 0.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              CardEditMenu(actions: [
                getDeletePopupAction(context, onDelete),
              ]),
            ],
          ),
        ),
      ],
    );

    // TimezoneCardContent(
    //   title: city.name,
    //   subtitle: _getOffsetDescription(),
    //   timezoneLocation: _timezoneLocation,
    //   onPressDelete: onDelete,
    // );
  }
}
