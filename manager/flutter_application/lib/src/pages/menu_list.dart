import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FoodItemMenuWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MenuWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  RestaurantController _con;
  List<String> selectedCategories;

  _MenuWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.restaurant = (new Restaurant())..id = widget.routeArgument.id;
    _con.listenForCategories(widget.routeArgument.id);
    selectedCategories = ['0'];
    _con.listenForFoods(_con.restaurant.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _con.restaurant?.name ?? '',
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          maxLines: 2,
          softWrap: true,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 0)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              title: Text(
                S.of(context).all_menu,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                'Deslize de derecha a izquierda para ver más categorías',
                style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 11)),
              ),
            ),
            //Tabs
            _con.categoriesRestaurant.isEmpty
              ? SizedBox(height: 90)
              : Container(
                  height: 90,
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: List.generate(_con.categoriesRestaurant.length, (index) {
                      var _category = _con.categoriesRestaurant.elementAt(index);
                      var _selected = this.selectedCategories.contains(_category.id);
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 20),
                        child: RawChip(
                          elevation: 0,
                          label: Text(_category.description),
                          labelStyle: _selected
                              ? Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).primaryColor))
                              : Theme.of(context).textTheme.bodyText2,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          backgroundColor: Theme.of(context).focusColor.withOpacity(0.1),
                          selectedColor: Theme.of(context).accentColor,
                          selected: _selected,
                          //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                          showCheckmark: false,
                          onSelected: (bool value) {
                            setState(() {
                              if (_category.id == '0') {
                                this.selectedCategories = ['0'];
                              } else {
                                this.selectedCategories = [_category.id];
                                // this.selectedCategories.removeWhere((element) => element == '0');
                              }
                              // if (value) {
                              //   this.selectedCategories.removeWhere((element) => element != _category.id);
                              //   this.selectedCategories.add(_category.id);
                              // } else {
                              //   this.selectedCategories.removeWhere((element) => element == _category.id);
                              // }
                              _con.selectCategory(this.selectedCategories);
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
            //Tabs
            _con.foods.isEmpty
              ? CircularLoadingWidget(height: 250)
              : ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: _con.foods.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  return FoodItemMenuWidget(
                    heroTag: 'menu_list',
                    food: _con.foods.elementAt(index),
                    onAction: (value) {
                      _con.foods.elementAt(index).foodStatus == 0 ? _con.doStatusFoodOn(_con.foods.elementAt(index)) : _con.doStatusFoodOff(_con.foods.elementAt(index));
                    },
                  );
                },
              )
            // _con.foods.isEmpty
                // ? CircularLoadingWidget(height: 250)

          ],
        ),
      ),
    );
  }
}
