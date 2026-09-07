import 'package:intl/intl.dart';

final DateFormat _date = DateFormat('d MMMM y', 'ru');
final DateFormat _shortDate = DateFormat('dd.MM.yyyy', 'ru');
final DateFormat _dateTime = DateFormat('d MMMM, HH:mm', 'ru');
final NumberFormat _money = NumberFormat.decimalPattern('ru');

String formatDate(DateTime value) => _date.format(value);

String formatShortDate(DateTime value) => _shortDate.format(value);

String formatDateTime(DateTime value) => _dateTime.format(value);

String formatMoney(int rubles) => '${_money.format(rubles)} ₽';

String formatDateRange(DateTime from, DateTime to) {
  if (from.year == to.year && from.month == to.month) {
    return '${from.day} — ${formatDate(to)}';
  }
  return '${formatDate(from)} — ${formatDate(to)}';
}

String plural(int count, String one, String few, String many) {
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) return many;
  switch (count % 10) {
    case 1:
      return one;
    case 2:
    case 3:
    case 4:
      return few;
    default:
      return many;
  }
}
