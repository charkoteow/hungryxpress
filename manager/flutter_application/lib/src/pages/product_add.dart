import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../elements/ShoppingCartButtonWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../controllers/food_controller.dart';
import '../elements/NumericUpDown.dart';
import '../elements/DrawerWidget.dart';
import '../../generated/l10n.dart';
import '../models/route_argument.dart';
import '../helpers/helper.dart';

class ProductAddWidget extends StatefulWidget {
  final int store;
  final RouteArgument routeArgument;

  ProductAddWidget({Key key, this.store, this.routeArgument}) : super(key: key);

  @override
  _ProductAddWidgetState createState() {
    return _ProductAddWidgetState();
  }
}

class _ProductAddWidgetState extends StateMVC<ProductAddWidget> {
  FoodController _con;
  // bool _isCheckedFeatured = true;
  bool _isCheckedDeliverable = false;

  _ProductAddWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    // _con.listenForFood(foodId: this.widget.id);
    _con.listenForMarkets();
    _con.listenForCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: FlatButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(S.of(context).confirmation),
                  content: Text("Did you make the changes correctly?"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    FlatButton(
                      textColor: Theme.of(context).focusColor,
                      child: new Text(S.of(context).confirm),
                      onPressed: () {
                        _con.doAddProduct(_con.food);
                      },
                    ),
                    FlatButton(
                      child: new Text(S.of(context).dismiss),
                      textColor: Theme.of(context).accentColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
            );
          },
          padding: EdgeInsets.symmetric(vertical: 14),
          color: Theme.of(context).accentColor,
          shape: StadiumBorder(),
          child: Text(
            S.of(context).saveChanges,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ),
      ),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          '${widget.store}',
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        primary: true,
        shrinkWrap: false,
        children: [
          //Nombre
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (text) {
                _con.food.name = text;
              },
              cursorColor: Theme.of(context).accentColor,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.headline5,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.all(18),
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: 'Enter the name of your branch',
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
          ),
          //Nombre
          //Precio y precio descuento
          Container(
            width: MediaQuery.of(context).size.width * 0.47,
            padding: EdgeInsets.all(10),
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (String value) {
                _con.food.price = double.tryParse(value);
              },
              cursorColor: Theme.of(context).accentColor,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: Theme.of(context).textTheme.headline5,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.all(18),
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: 'Enter the price of the product',
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.48,
            padding: EdgeInsets.all(10),
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (String value) {
                _con.food.discountPrice = double.tryParse(value);
              },
              cursorColor: Theme.of(context).accentColor,
              decoration: InputDecoration(
                labelText: 'Discount price',
                labelStyle: Theme.of(context).textTheme.headline5,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.all(18),
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: 'Enter the discount price of the product',
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
          ),
          //Precio y precio descuento
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.30,
                padding: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) {
                    _con.food.weight = (value);
                  },
                  cursorColor: Theme.of(context).accentColor,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Enter product weight',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.30,
                padding: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    _con.food.unit = (value);
                  },
                  cursorColor: Theme.of(context).accentColor,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Enter the unit of measure',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
              ),
              //Cantidad del paquete
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Center(child: Text("Package quantity")),
                    ),
                    Container(
                      width: 100,
                      child: NumericUpDown(
                        text: (1).toString(),
                        max: 50,
                        onChanged: (value) {
                          if (value != '') {
                            setState(() {
                              _con.food.packageItemsCount = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              //Cantidad del paquete
            ],
          ),
          //Descripción
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              keyboardType: TextInputType.text,
              onChanged: (String value) {
                _con.food.description = value;
              },
              cursorColor: Theme.of(context).accentColor,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: Theme.of(context).textTheme.headline5,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.all(18),
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: 'Write a description of your product',
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
          ),
          //Descripción
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text('Store or Restaurant'),
            initiallyExpanded: false,
            children: List.generate(_con.restaurants.length, (index) {
              var _restaurants = _con.restaurants.elementAt(index);
              return RadioListTile(
                dense: true,
                groupValue: true,
                controlAffinity: ListTileControlAffinity.trailing,
                value: widget.store == int.tryParse(_restaurants.id),
                onChanged: (value) {
                  setState(() {
                    _con.food.restaurant = _restaurants;
                  });
                },
                title: Text(
                  " " + _restaurants.name,
                  style: Theme.of(context).textTheme.bodyText1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              );
            })
          ),
          //Categoria App
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text('Category'),
            initiallyExpanded: false,
            children: List.generate(_con.categories.length, (index) {
              var _categories = _con.categories.elementAt(index);
              return RadioListTile(
                dense: true,
                groupValue: true,
                controlAffinity: ListTileControlAffinity.trailing,
                // value: _con.food.category.id == _categories.id,
                value: _con.categories[0].id == _categories.id,
                onChanged: (value) {
                  setState(() {
                    _con.food.category = _categories;
                  });
                },
                title: Text(
                  " " + _categories.name,
                  style: Theme.of(context).textTheme.bodyText1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              );
            })
          ),
          //Categoria App
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.43,
                height: 60.0,
                child: CheckboxListTile(
                  title: Text(
                    'Featured',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: true,
                  onChanged: (val) {
                    setState(() {
                      // _con.food?.featured = false;
                      _con.food.featured = val;
                    });
                    // setState(() {
                    //   _isCheckedFeatured = val;
                    //   if (val == true) {
                    //     _currText_Featured = 1;
                    //   } else {
                    //     _currText_Featured = 0;
                    //   }
                    // });
                  },
                )
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.50,
                height: 60.0,
                child: CheckboxListTile(
                  title: Text(
                    'Available to ship',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _isCheckedDeliverable,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _isCheckedDeliverable = true;
                        _con.food.deliverable = _isCheckedDeliverable;
                      } else {
                        _isCheckedDeliverable = false;
                        _con.food.deliverable = _isCheckedDeliverable;
                      }
                    });
                  },
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
