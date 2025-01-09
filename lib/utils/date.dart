import 'package:intl/intl.dart';

// 格式化日期
String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  return DateFormat('yyyy年MM月dd日').format(dateTime);
}
