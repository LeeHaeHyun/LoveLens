import 'package:intl/intl.dart';

String formatDateBydMMMYYYY(DateTime dateTime) {
  return DateFormat("yyyy년 M월 d일 HH시 mm분").format(dateTime);
}
