import '../models/category.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/media.dart';
import '../models/nutrition.dart';
import '../models/restaurant.dart';
import '../models/review.dart';

class Food {
  String id;
  String name;
  int foodStatus;
  double price;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String weight;
  String unit;
  String packageItemsCount;
  bool featured;
  bool deliverable;
  Restaurant restaurant;
  Category category;
  List<Extra> extras;
  List<ExtraGroup> extraGroups;
  List<Review> foodReviews;
  List<Nutrition> nutritions;

  Food();

  Food.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      foodStatus = jsonMap['food_status'];
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      discountPrice = jsonMap['discount_price'] != null ? jsonMap['discount_price'].toDouble() : 0.0;
      price = discountPrice != 0 ? discountPrice : price;
      discountPrice = discountPrice == 0 ? discountPrice : jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      description = jsonMap['description'];
      ingredients = jsonMap['ingredients'];
      weight = jsonMap['weight'].toString();
      unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
      packageItemsCount = jsonMap['package_items_count'].toString();
      featured = jsonMap['featured'] ?? false;
      deliverable = jsonMap['deliverable'] ?? false;
      restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : Restaurant.fromJSON({});
      category = jsonMap['category'] != null ? Category.fromJSON(jsonMap['category']) : new Category();
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      extras = jsonMap['extras_manager'] != null && (jsonMap['extras_manager'] as List).length > 0
          ? List.from(jsonMap['extras_manager']).map((element) => Extra.fromJSON(element)).toSet().toList()
          : [];
      extraGroups = jsonMap['extra_groups'] != null && (jsonMap['extra_groups'] as List).length > 0
          ? List.from(jsonMap['extra_groups']).map((element) => ExtraGroup.fromJSON(element)).toSet().toList()
          : [];
      foodReviews = jsonMap['food_reviews'] != null && (jsonMap['food_reviews'] as List).length > 0
          ? List.from(jsonMap['food_reviews']).map((element) => Review.fromJSON(element)).toSet().toList()
          : [];
      nutritions = jsonMap['nutrition'] != null && (jsonMap['nutrition'] as List).length > 0
          ? List.from(jsonMap['nutrition']).map((element) => Nutrition.fromJSON(element)).toSet().toList()
          : [];
    } catch (e) {
      id = '';
      name = '';
      foodStatus = 0;
      price = 0.0;
      discountPrice = 0.0;
      description = '';
      weight = '';
      ingredients = '';
      unit = '';
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      restaurant = new Restaurant.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      extras = [];
      extraGroups = [];
      foodReviews = [];
      nutritions = [];
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["food_status"] = foodStatus;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
    map["ingredients"] = ingredients;
    map["weight"] = weight.isEmpty ? null : weight;
    map["unit"] = unit;
    if (restaurant?.id != 'null') map["restaurant_id"] = restaurant?.id;
    if (category?.id != 'null') map["category_id"] = category?.id;
    map["featured"] = featured;
    map["deliverable"] = deliverable;
    map["package_items_count"] = packageItemsCount;
    return map;
  }

  Map addProductMap() {
    var map = this.toMap();
    map["name"] = name;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
    map["weight"] = weight.isEmpty ? null : weight;
    map["unit"] = unit;
    if (restaurant?.id != 'null') map["restaurant_id"] = restaurant?.id;
    if (category?.id != 'null') map["category_id"] = category?.id;
    map["featured"] = featured;
    map["deliverable"] = deliverable;
    map["package_items_count"] = packageItemsCount;
    return map;
  }

  double getRate() {
    double _rate = 0;
    foodReviews.forEach((e) => _rate += double.parse(e.rate));
    _rate = _rate > 0 ? (_rate / foodReviews.length) : 0;
    return _rate;
  }

  Map closedMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["food_status"] = false;
    return map;
  }

  Map openRestaurantMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["food_status"] = true;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
