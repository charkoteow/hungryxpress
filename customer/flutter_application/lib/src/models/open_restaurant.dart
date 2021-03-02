import '../helpers/custom_trace.dart';
import 'package:intl/intl.dart';

class OpenRestaurant {
  int day_of_week;
  DateTime open_time;
  DateTime close_time;

  OpenRestaurant();

  OpenRestaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      day_of_week = jsonMap['day_of_week'];
      open_time = new DateFormat("HH:mm:ss").parse(jsonMap['open_time'].toString());
      close_time = new DateFormat("HH:mm:ss").parse(jsonMap['close_time'].toString());
    } catch (e) {
      day_of_week = 0;
      open_time = new DateTime.now();
      close_time = new DateTime.now();
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["day_of_week"] = day_of_week;
    map["open_time"] = open_time;
    map["close_time"] = close_time;
    return map;
  }
}
