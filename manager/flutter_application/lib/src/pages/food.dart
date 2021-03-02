import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import '../elements/CircularLoadingWidget.dart';
import '../controllers/food_controller.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ExtraItemWidget.dart';
import '../elements/ExtraEditDialog.dart';
import '../models/route_argument.dart';
import '../pages/product_edit.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/extra.dart';

// ignore: must_be_immutable
class FoodWidget extends StatefulWidget {
  RouteArgument routeArgument;

  FoodWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _FoodWidgetState createState() {
    return _FoodWidgetState();
  }
}

class _FoodWidgetState extends StateMVC<FoodWidget> {
  FoodController _con;
  HashMap radioButtonsGroupValues;
  HashMap radioButtonsExtraPrevValues;

  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForFood(foodId: widget.routeArgument.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food == null || _con.food?.image == null
          ? CircularLoadingWidget(height: 500)
          : RefreshIndicator(
              onRefresh: _con.refreshFood,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(bottom: 125),
                    // padding: EdgeInsets.only(bottom: 125),
                    child: CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                          expandedHeight: 210,
                          elevation: 0,
                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                  return DetailScreen(
                                      heroTag: widget.routeArgument.heroTag,
                                      image: _con.food.image.url);
                                }));
                              },
                              child: Hero(
                                tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      child: ClipRRect(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: _con.food.image.url,
                                          placeholder: (context, url) => Image.asset(
                                            'assets/img/loading.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Wrap(
                              runSpacing: 8,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _con.food?.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          Text(
                                            _con.food?.restaurant?.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Helper.getPrice(
                                            _con.food.price,
                                            context,
                                            style: Theme.of(context).textTheme.headline2,
                                          ),
                                          _con.food.discountPrice > 0
                                              ? Helper.getPrice(_con.food.discountPrice, context, style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                                              : SizedBox(height: 0),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: SizedBox(height: 0)),
                                    if (_con.food.unit.isNotEmpty)
                                      Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).focusColor,
                                            borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Text(
                                            _con.food.weight + " " + _con.food.unit,
                                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                          )),
                                    if (_con.food.unit.isNotEmpty)
                                      SizedBox(width: 5),
                                    if (_con.food.packageItemsCount == '')
                                      SizedBox(width: 0)
                                    else if (_con.food.packageItemsCount == '1')
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).focusColor,
                                          borderRadius: BorderRadius.circular(24)
                                        ),
                                        child: Text(
                                          _con.food.packageItemsCount + " " + 'Item',
                                          style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                        )
                                      )
                                    else
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).focusColor,
                                          borderRadius: BorderRadius.circular(24)
                                        ),
                                        child: Text(
                                          _con.food.packageItemsCount + " " + S.of(context).items,
                                          style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                        )
                                      )
                                  ],
                                ),
                                Divider(height: 10),
                                Helper.applyHtml(context, _con.food.description, style: TextStyle(fontSize: 12)),
                                _con.food.extraGroups == null
                                    ? CircularLoadingWidget(height: 100)
                                    : ListView.separated(
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, extraGroupIndex) {
                                          var extraGroup = _con.food.extraGroups.elementAt(extraGroupIndex);
                                          return ExpansionTile(
                                            tilePadding: EdgeInsets.symmetric(horizontal: 0),
                                            title: Text(extraGroup.name),
                                            subtitle: Text(
                                              'hold an extra to edit',
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.caption,
                                            ),
                                            initiallyExpanded: true,
                                            children: <Widget>[
                                              ListView.separated(
                                                padding: EdgeInsets.all(0),
                                                itemBuilder: (context, extraIndex) {
                                                  return ExtraItemWidget(
                                                    heroTag: 'details_featured_product',
                                                    extra: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex),
                                                    onAction: (value) {
                                                      _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex).active == 0
                                                        ? _con.doStatusExtraOn(_con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex))
                                                        : _con.doStatusExtraOff(_con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex));
                                                    },
                                                    onLongPress: (Extra _extrass) {
                                                      ExtraEditDialog(
                                                        context: context,
                                                        extras: _extrass,
                                                        onChanged: (Extra _extrass) {
                                                          _con.doUpdateExtra(_extrass);
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                separatorBuilder: (context, index) {
                                                  return SizedBox(height: 0);
                                                },
                                                itemCount: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).length,
                                                primary: false,
                                                shrinkWrap: true,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 20);
                                        },
                                        itemCount: _con.food.extraGroups.length,
                                        primary: false,
                                        shrinkWrap: true,
                                      ),
                                if (_con.food.nutritions.isNotEmpty)
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    leading: Icon(
                                      Icons.local_activity,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    title: Text(
                                      'Nutrientes',
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                if (_con.food.nutritions.length > 0)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                      _con.food.nutritions.length, (index) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).focusColor.withOpacity(0.2),
                                              offset: Offset(0, 2),
                                              blurRadius: 6.0
                                            )
                                          ]
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              _con.food.nutritions.elementAt(index).name,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.caption),
                                            Text(
                                              _con.food.nutritions.elementAt(index).quantity.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.headline5
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.recent_actors,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    'Comentarios',
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                ReviewsListWidget(
                                  reviewsList: _con.food.foodReviews,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 15,
                    child: IconButton(
                      icon: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle
                        ),
                        child: Center(
                          child: Icon(
                            Icons.edit,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductEditWidget(id: _con.food.id, store: _con.food.restaurant.id)));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String image;
  final String heroTag;

  const DetailScreen({Key key, this.image, this.heroTag}) : super(key: key);

  @override
  _DetailScreenWidgetState createState() => _DetailScreenWidgetState();
}

class _DetailScreenWidgetState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: GestureDetector(
        child: Hero(
            tag: widget.heroTag,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(widget.image),
              // Contained = the smallest possible size to fit one dimension of the screen
              minScale: PhotoViewComputedScale.contained * 0.8,
              // Covered = the smallest possible size to fit the whole screen
              maxScale: PhotoViewComputedScale.covered * 2,
            )),
      ),
    ));
  }
}
