import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'open_restaurant.dart';
import 'user.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool closed;
  bool availableForDelivery;
  double deliveryRange;
  double distance;
  List<User> users;
  List<OpenRestaurant> openRestaurants;

  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      address = jsonMap['address'];
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? false;
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
      users = jsonMap['users'] != null && (jsonMap['users'] as List).length > 0
          ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toSet().toList()
          : [];
      openRestaurants = jsonMap['open_restaurants'] != null &&
              (jsonMap['open_restaurants'] as List).length > 0
          ? List.from(jsonMap['open_restaurants'])
              .map((element) => OpenRestaurant.fromJSON(element))
              .toSet()
              .toList()
          : [];
      if (openRestaurants.length > 0) {
        print(openRestaurants[0].day_of_week);
        print(openRestaurants[0].open_time);
        print(openRestaurants[0].close_time);
      }
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      users = [];
      openRestaurants = [];
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }

  bool currentOpenRestaurant() {
    DateTime currentDate = DateTime.now();
    final index = this.openRestaurants.indexWhere((openRestaurant) =>
        openRestaurant.day_of_week == DateTime.now().weekday &&
        currentDate.isAfter(DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            openRestaurant.open_time.hour,
            openRestaurant.open_time.minute,
            openRestaurant.open_time.second,
            openRestaurant.open_time.millisecond)) &&
        currentDate.isBefore(DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            openRestaurant.close_time.hour,
            openRestaurant.close_time.minute,
            openRestaurant.close_time.second,
            openRestaurant.close_time.millisecond)));

    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

}
