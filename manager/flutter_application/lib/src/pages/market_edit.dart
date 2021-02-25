import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../elements/ShoppingCartButtonWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../controllers/food_controller.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/NumericUpDown.dart';
import '../elements/DrawerWidget.dart';
import '../../generated/l10n.dart';
import '../models/route_argument.dart';
import '../helpers/helper.dart';

class MarketEditWidget extends StatefulWidget {
  final String id;
  final String store;
  final RouteArgument routeArgument;

  MarketEditWidget({Key key, this.id, this.store, this.routeArgument}) : super(key: key);

  @override
  _MarketEditWidgetState createState() {
    return _MarketEditWidgetState();
  }
}

class _MarketEditWidgetState extends StateMVC<MarketEditWidget> {
  RestaurantController _con;

  _MarketEditWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForRestaurant(id: this.widget.id);
    _con.listenForCuisines();
    // _con.listenForMarkets();
    // _con.listenForCategoriesMenu(this.widget.store);
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
                        _con.doUpdateMarket(_con.restaurant);
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
          'Editar Tienda',
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _con.restaurant == null
        ? CircularLoadingWidget(height: 400)
        : ListView(
            primary: true,
            shrinkWrap: false,
            children: [
              //Nombre
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    _con.restaurant.name = value;
                  },
                  controller: TextEditingController()..text = _con.restaurant.name,
                  cursorColor: Theme.of(context).accentColor,
                  maxLines: 2,
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
              //Descripción
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    _con.restaurant.description = value;
                  },
                  controller: TextEditingController()..text = Helper.skipHtml(_con.restaurant.description),
                  cursorColor: Theme.of(context).accentColor,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Write a description of your business',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
              ),
              //Descripción
              //Información
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    _con.restaurant.information = value;
                  },
                  controller: TextEditingController()..text = Helper.skipHtml(_con.restaurant.information),
                  cursorColor: Theme.of(context).accentColor,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Information',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Write relevant information',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
              ),
              //Información
              //Teléfonos
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.50,
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (String value) {
                        _con.restaurant.phone = value;
                      },
                      controller: TextEditingController()..text = _con.restaurant.phone,
                      cursorColor: Theme.of(context).accentColor,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: Theme.of(context).textTheme.headline5,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.all(18),
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: 'Write a contact phone',
                        border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.50,
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (String value) {
                        _con.restaurant.mobile = value;
                      },
                      controller: TextEditingController()..text = _con.restaurant.mobile,
                      cursorColor: Theme.of(context).accentColor,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Cell phone',
                        labelStyle: Theme.of(context).textTheme.headline5,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.all(18),
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: 'Write a contact cell phone',
                        border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                      ),
                    ),
                  ),
                ]
              ),
              //Teléfono
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 60.0,
                    child: CheckboxListTile(
                      title: Text(
                        'Open shop',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _con.restaurant.closed ? false : true,
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _con.restaurant.closed = false;
                          } else {
                            _con.restaurant.closed = true;
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
