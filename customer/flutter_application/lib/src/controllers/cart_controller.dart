import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:math' as Math;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import '../models/address.dart';
import '../repository/settings_repository.dart' as settingRepo;

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;

  Address currentAddress;
  double currentFee = 0.0;
  double degtorad = 0.0;
  double radtodeg = 0.0;
  double dlong = 0.0;
  double dvalue = 0.0;
  double dd = 0.0;
  double miles = 0.0;
  double km = 0.0;
  double lat1 = 0.0;
  double long1 = 0.0;
  double lat2 = 0.0;
  double long2 = 0.0;
  double deliveryFeeCalculate = 0.0;
  double valueNew = 0.0;
  double distanceResponse = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.food.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context).carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_food_was_removed_from_your_cart(_cart.food.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.food.price;
      cart.extras.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });
    if (Helper.canDelivery(carts[0].food.restaurant, carts: carts)) {
      // deliveryFee = carts[0].food.restaurant.deliveryFee;
      calculateDeliveryFee();
    }
    taxAmount = (subTotal + deliveryFee) * carts[0].food.restaurant.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    setState(() {});
  }

  void calculateDeliveryFee() {
    currentAddress = settingRepo.deliveryAddress.value;
    if (currentAddress.isUnknown()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              'Dirección de envío desconocida',
              style: Theme.of(context).textTheme.body2,
            ),
            content: new Text(
              'Por favor, permita la ubicación y agregue una dirección de envío válida',
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/DeliveryAddresses');
                },
                child: Text(S.of(context).cancel),
              ),
            ],
          );
        },
      );
    } else {
      //Coordenadas Cliente
      lat1 = currentAddress.latitude;
      long1 = currentAddress.longitude;

      //Coordenadas Tienda
      lat2 = double.parse(carts[0].food.restaurant.latitude);
      long2 = double.parse(carts[0].food.restaurant.longitude);

      degtorad = 0.01745329;
      radtodeg = 57.29577951;

      dlong = (long1 - long2);
      dvalue = (Math.sin(lat1 * degtorad) * Math.sin(lat2 * degtorad)) +
          (Math.cos(lat1 * degtorad) *
              Math.cos(lat2 * degtorad) *
              Math.cos(dlong * degtorad));

      dd = Math.acos(dvalue) * radtodeg;

      miles = (dd * 69.16);
      km = (dd * 111.302);
      valueNew = double.parse(km.toStringAsFixed(2));

      if (valueNew <= 4) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee;
      } else if (valueNew > 4 && valueNew <= 5) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 5;
      } else if (valueNew > 5 && valueNew <= 6) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 10;
      } else if (valueNew > 6 && valueNew <= 7) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 15;
      } else if (valueNew > 7 && valueNew <= 8) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 20;
      } else if (valueNew > 8 && valueNew <= 9) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 25;
      } else if (valueNew > 9 && valueNew <= 10) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 30;
      } else if (valueNew > 10 && valueNew <= 11) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 35;
      } else if (valueNew > 11 && valueNew <= 12) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 40;
      } else if (valueNew > 12 && valueNew <= 13) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 45;
      } else if (valueNew > 13) {
        deliveryFeeCalculate = carts[0].food.restaurant.deliveryFee + 50;
      }
      deliveryFee = deliveryFeeCalculate;
      settingRepo.deliveryFee = deliveryFee;
    }
  }

  void doApplyCoupon(String code, {String message}) async {
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
//      saveCoupon(currentCoupon).then((value) => {
//          });
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      if (carts[0].food.restaurant.closed) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_restaurant_is_closed_),
        ));
      } else {
        if (carts[0].food.restaurant.currentOpenRestaurant()) {
          Navigator.of(context).pushNamed('/DeliveryPickup');
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).this_restaurant_is_closed_),
          ));
        }
      }
    }
  }

  Color getCouponIconColor() {
    print(coupon.toMap());
    if (coupon?.valid == true) {
      return Colors.green;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context).focusColor.withOpacity(0.7);
  }
}
