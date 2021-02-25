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

class ProductEditWidget extends StatefulWidget {
  final String id;
  final String store;
  final RouteArgument routeArgument;

  ProductEditWidget({Key key, this.id, this.store, this.routeArgument}) : super(key: key);

  @override
  _ProductEditWidgetState createState() {
    return _ProductEditWidgetState();
  }
}

class _ProductEditWidgetState extends StateMVC<ProductEditWidget> {
  FoodController _con;

  _ProductEditWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForFood(foodId: this.widget.id);
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
                  content: Text("¿Realizaste correctamente los cambios?"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    FlatButton(
                      textColor: Theme.of(context).focusColor,
                      child: new Text(S.of(context).confirm),
                      onPressed: () {
                        _con.doUpdateProduct(_con.food);
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
          'Editar Producto',
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _con.food == null
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
                    _con.food.name = value;
                  },
                  controller: TextEditingController()..text = _con.food.name,
                  cursorColor: Theme.of(context).accentColor,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Escriba el nombre de su producto',
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
                  controller: TextEditingController()..text = _con.food.price.toString(),
                  cursorColor: Theme.of(context).accentColor,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Ingrese el precio del producto',
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
                  controller: TextEditingController()..text = _con.food.discountPrice.toString(),
                  cursorColor: Theme.of(context).accentColor,
                  decoration: InputDecoration(
                    labelText: 'Precio de descuento',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Ingrese el precio de descuento del producto',
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
                      controller: TextEditingController()..text = _con.food.weight == 'null' ? '' : _con.food.weight,
                      cursorColor: Theme.of(context).accentColor,
                      decoration: InputDecoration(
                        labelText: 'Peso',
                        labelStyle: Theme.of(context).textTheme.headline5,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.all(18),
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: 'Ingrese el peso del producto',
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
                      controller: TextEditingController()..text = _con.food.unit.isEmpty ? '' : _con.food.unit,
                      cursorColor: Theme.of(context).accentColor,
                      decoration: InputDecoration(
                        labelText: 'Unidad',
                        labelStyle: Theme.of(context).textTheme.headline5,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.all(18),
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: 'Ingrese la unidad de medida',
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
                          child: Center(child: Text("Cantidad del paquete")),
                        ),
                        Container(
                          width: 100,
                          child: NumericUpDown(
                            text: (double.parse(_con.food.packageItemsCount.toString()).toInt()).toString(),
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
                  controller: TextEditingController()..text = Helper.skipHtml(_con.food.description),
                  cursorColor: Theme.of(context).accentColor,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: Theme.of(context).textTheme.headline5,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: EdgeInsets.all(18),
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Escriba una descripción de su producto',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
              ),
              //Descripción
              ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('Tienda o Restaurante'),
                initiallyExpanded: false,
                children: List.generate(_con.restaurants.length, (index) {
                  var _restaurants = _con.restaurants.elementAt(index);
                  return RadioListTile(
                    dense: true,
                    groupValue: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: _con.food.restaurant.id == _restaurants.id,
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
                title: Text('Categoría de la app'),
                initiallyExpanded: false,
                children: List.generate(_con.categories.length, (index) {
                  var _categories = _con.categories.elementAt(index);
                  return RadioListTile(
                    dense: true,
                    groupValue: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: _con.food.category.id == _categories.id,
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
                        'Destacado',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _con.food.featured,
                      onChanged: (val) {
                        setState(() {
                          _con.food.featured = val;
                        });
                      },
                    )
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.50,
                    height: 60.0,
                    child: CheckboxListTile(
                      title: Text(
                        'Disponible para envíar',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _con.food.deliverable,
                      onChanged: (val) {
                        setState(() {
                          _con.food.deliverable = val;
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
