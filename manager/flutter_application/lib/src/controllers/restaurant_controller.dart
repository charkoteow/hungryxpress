import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cuisine.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../pages/restaurants.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/category_repository.dart';
import '../repository/restaurant_repository.dart';

class RestaurantController extends ControllerMVC {
  Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Restaurant> restaurants = <Restaurant>[];
  List<Food> foods = <Food>[];
  List<Cuisine> cuisines = <Cuisine>[];
  List<Category> categories = <Category>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> featuredFoods = <Food>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForRestaurants({String message}) async {
    final Stream<Restaurant> stream = await getRestaurants();
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurants.add(_restaurant));
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForRestaurant({String id, String message}) async {
    final Stream<Restaurant> stream = await getRestaurant(id);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurant = _restaurant);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForGalleries(String idRestaurant) async {
    final Stream<Gallery> stream = await getGalleries(idRestaurant);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForRestaurantReviews({String id, String message}) async {
    final Stream<Review> stream = await getRestaurantReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForFoods(String idRestaurant, {List<String> categoriesId}) async {
    final Stream<Food> stream = await getFoodsOfRestaurant(idRestaurant, categories: categoriesId);
    stream.listen((Food _food) {
      setState(() => foods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      restaurant..name = foods.elementAt(0).restaurant.name;
    });
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => featuredFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshRestaurant() async {
    var _id = restaurant.id;
    restaurant = new Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    listenForRestaurant(id: _id, message: S.of(context).restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedFoods(_id);
  }

  Future<void> refreshRestaurants() async {
    restaurants.clear();
    listenForRestaurants(message: S.of(context).restaurant_refreshed_successfuly);
  }

  Future<void> listenForCategories(String restaurantId) async {
    final Stream<Category> stream = await getCategoriesOfRestaurant(restaurantId);
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      categories.insert(0, new Category.fromJSON({'id': '0', 'name': S.of(context).all}));
    });
  }

  Future<void> selectCategory(List<String> categoriesId) async {
    foods.clear();
    listenForFoods(restaurant.id, categoriesId: categoriesId);
  }

  void doStatusFoodOff(Food food) {
    closedFood(food).then((value) {
      setState(() {
        food.foodStatus = 0;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Item Sold out'),
      ));
    });
  }

  void doStatusFoodOn(Food food) {
    openFood(food).then((value) {
      setState(() {
        food.foodStatus = 1;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Product available'),
      ));
    });
  }

  void doStatusStoreOff(Restaurant restaurant) {
    closedRestaurant(restaurant).then((value) {
      // setState(() {
      //   restaurant.closed = true;
      // });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Store closed successfully'),
      ));
    });
  }

  void doStatusStoreOn(Restaurant restaurant) {
    openRestaurant(restaurant).then((value) {
      // setState(() {
      //   restaurant.closed = false;
      // });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Store opened successfully'),
      ));
    });
  }

  void doUpdateMarket(Restaurant _restaurant) async {
    updateMarket(_restaurant).then((value) {
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "An error occurred, retry to save changes",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.grey[900],
        textColor: Colors.white,
        fontSize: 16.0
      );
    }).whenComplete(() {
      // refreshRestaurants();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RestaurantsWidget()),
      );
      Fluttertoast.showToast(
        msg: "Store updated successfully ....",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.grey[900],
        textColor: Colors.white,
        fontSize: 16.0
      );
    });
  }

  void listenForCuisines() async {
    final Stream<Cuisine> stream = await getCuisines();
    stream.listen((Cuisine _cuisine) {
      setState(() => cuisines.add(_cuisine));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }
}
