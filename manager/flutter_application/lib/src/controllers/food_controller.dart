import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/extra_repository.dart';
import '../repository/restaurant_repository.dart';

class FoodController extends ControllerMVC {
  Food food;
  double quantity = 1;
  double total = 0;
  Cart cart;
  Favorite favorite;
  bool loadCart = false;
  List<Restaurant> restaurants = <Restaurant>[];
  List<Category> categories = <Category>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForFood({String foodId, String message}) async {
    final Stream<Food> stream = await getFood(foodId);
    stream.listen((Food _food) {
      setState(() => food = _food);
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      if (message != null) {
        scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFavorite({String foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      print(a);
    });
  }

  bool isSameRestaurants(Food food) {
    if (cart != null) {
      return cart.food?.restaurant?.id == food.restaurant.id;
    }
    return true;
  }

  void addToFavorite(Food food) async {
    var _favorite = new Favorite();
    _favorite.food = food;
    _favorite.extras = food.extras.where((Extra _extra) {
      return _extra.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('This food was added to favorite'),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('This food was removed from favorites'),
      ));
    });
  }

  Future<void> refreshFood() async {
    var _id = food.id;
    food = new Food();
    listenForFavorite(foodId: _id);
    listenForFood(foodId: _id, message: 'Food refreshed successfuly');
  }

  void calculateTotal() {
    total = food?.price ?? 0;
    food.extras.forEach((extra) {
      total += extra.checked ? extra.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity > 1) {
      --this.quantity;
      calculateTotal();
    }
  }

  void doStatusExtraOff(Extra extra) {
    closedExtra(extra).then((value) {
      setState(() {
        extra.active = 0;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Extra out of stock'),
      ));
    });
  }

  void doStatusExtraOn(Extra extra) {
    openExtra(extra).then((value) {
      setState(() {
        extra.active = 1;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      // refreshRestaurants();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Extra available'),
      ));
    });
  }

  void listenForMarkets({String message}) async {
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

  void listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void doUpdateProduct(Food _food) async {
    updateOrder(_food).then((value) {
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
      // refreshFood();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Product updated successfully...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.grey[900],
        textColor: Colors.white,
        fontSize: 16.0
      );
    });
  }

  void doUpdateExtra(Extra _extra) async {
    updateExtra(_extra).then((value) {
      setState(() {
        _extra.price = value.price;
        _extra.name = value.name;
      });
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
      // refreshFood();
      Fluttertoast.showToast(
        msg: "Extra successfully updated...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.grey[900],
        textColor: Colors.white,
        fontSize: 16.0
      );
    });
  }
}
