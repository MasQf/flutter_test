import 'package:intl/intl.dart';

// 格式化日期
String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  return DateFormat('yyyy年MM月dd日').format(dateTime);
}

// 根据日期计算显示方式
String getFriendlyDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString).toLocal(); // 转换为本地时间
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    // 当天，返回时间格式 '08:26'
    return DateFormat('HH:mm').format(dateTime);
  } else if (dateTime.year == yesterday.year &&
      dateTime.month == yesterday.month &&
      dateTime.day == yesterday.day) {
    // 昨天
    return '昨天';
  } else if (dateTime.isAfter(today.subtract(Duration(days: 7)))) {
    // 一周内，返回星期几
    return DateFormat('EEEE', 'zh_CN').format(dateTime);
  } else {
    // 更早的时间，返回 '2025/2/13'
    return DateFormat('yyyy/M/d').format(dateTime);
  }
}
