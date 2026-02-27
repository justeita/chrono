import 'package:clock_app/alarm/types/alarm_event.dart';
import 'package:clock_app/common/types/list_filter.dart';

final List<ListSortOption<AlarmEvent>> alarmEventSortOptions = [
  ListSortOption((context) => "Earliest start date", sortStartDateAscending),
  ListSortOption((context) => "Latest start date", sortStartDateDescending),
  ListSortOption((context) => "Earliest event date", sortEventDateAscending),
  ListSortOption((context) => "Latest event date", sortEventDateDescending),
];

int sortStartDateAscending(AlarmEvent a, AlarmEvent b) {
  return a.startDate.compareTo(b.startDate);
}

int sortStartDateDescending(AlarmEvent a, AlarmEvent b) {
  return b.startDate.compareTo(a.startDate);
}

int sortEventDateAscending(AlarmEvent a, AlarmEvent b) {
  return a.eventTime.compareTo(b.eventTime);
}

int sortEventDateDescending(AlarmEvent a, AlarmEvent b) {
  return b.eventTime.compareTo(a.eventTime);
}
