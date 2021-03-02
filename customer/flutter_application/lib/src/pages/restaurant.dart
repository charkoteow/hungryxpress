import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/conversation.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class RestaurantWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  RestaurantWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _RestaurantWidgetState createState() {
    return _RestaurantWidgetState();
  }
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  RestaurantController _con;

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument.param as Restaurant;
    _con.listenForGalleries(_con.restaurant.id);
    _con.listenForFeaturedFoods(_con.restaurant.id);
    _con.listenForRestaurantReviews(id: _con.restaurant.id);
    super.initState();
  }

  getStatusRestaurantPhoto() {
    if (_con.restaurant.closed){
      return CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: _con.restaurant.image.url,
        placeholder: (context, url) => Image.asset(
          'assets/img/loading.gif',
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        imageBuilder: (context, imageProvider) => new Container (
          height: 60,
          width: 60,
          child : new Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0)
                    ),
                  ),
                  child: Text(
                    S.of(context).closed,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: const Color(0xff000000),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
            ),
          ),
        ),
      );
    } else {
      if (_con.restaurant.currentOpenRestaurant()) {
        return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: _con.restaurant.image.url,
          placeholder: (context, url) => Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
      } else {
        return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: _con.restaurant.image.url,
          placeholder: (context, url) => Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          imageBuilder: (context, imageProvider) => new Container (
            height: 60,
            width: 60,
            child : new Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0)
                      ),
                    ),
                    child: Text(
                      S.of(context).closed,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800])
                      ,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: const Color(0xff000000),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
              ),
            ),
          ),
        );
      }
    }
  }

  getStatusRestaurantBadge() {
    if (_con.restaurant.closed){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(24)),
        child: Text(
          S.of(context).closed,
          style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
        ),
      );
    } else {
      if (_con.restaurant.currentOpenRestaurant()) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration:
              BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24)),
          child: Text(
            S.of(context).open,
            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        );
      } else {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration:
              BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(24)),
          child: Text(
            S.of(context).closed,
            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        body: RefreshIndicator(
          onRefresh: _con.refreshRestaurant,
          child: _con.restaurant == null
              ? CircularLoadingWidget(height: 500)
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                          expandedHeight: 300,
                          elevation: 0,
                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                  return DetailScreen(heroTag: widget?.routeArgument?.heroTag ?? '', image: _con.restaurant.image.url);
                                  }
                                ));
                              },
                              child: Hero(
                                tag: (widget?.routeArgument?.heroTag ?? '') + _con.restaurant.id,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          child: ClipRRect(
                                            child: getStatusRestaurantPhoto(),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10, top: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _con.restaurant?.name ?? '',
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.headline3,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32,
                                      child: Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(_con.restaurant.rate,
                                                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Theme.of(context).primaryColor))),
                                            Icon(
                                              Icons.star_border,
                                              color: Theme.of(context).primaryColor,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 20),
                                  getStatusRestaurantBadge(),
                                  SizedBox(width: 10),
                                  Expanded(child: SizedBox(height: 0)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: Helper.canDelivery(_con.restaurant) ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(24)),
                                    child: Text(
                                      Helper.getDistance(_con.restaurant.distance, Helper.of(context).trans(setting.value.distanceUnit)),
                                      style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Helper.applyHtml(context, _con.restaurant.description),
                              ),
                              ImageThumbCarouselWidget(galleriesList: _con.galleries),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.stars,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).information,
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Helper.applyHtml(context, _con.restaurant.information),
                              ),
                              if (_con.restaurant.openRestaurants.length > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.lock_clock,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    'Hours of Operation',
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              ),
                              if (_con.restaurant.openRestaurants.length > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: _con.restaurant.openRestaurants.length,
                                  itemBuilder: (context, index) {
                                    DateTime date = DateTime.now();
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            Helper.dayOfWeekHours(_con.restaurant.openRestaurants.elementAt(index).day_of_week),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: _con.restaurant.openRestaurants.elementAt(index).day_of_week == date.weekday ? Theme.of(context).textTheme.headline3.merge(TextStyle(fontSize: 13)) : Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 13)),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          DateFormat('HH:mm').format(_con.restaurant.openRestaurants.elementAt(index).open_time)+' - '+DateFormat('HH:mm').format(_con.restaurant.openRestaurants.elementAt(index).close_time),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: _con.restaurant.openRestaurants.elementAt(index).day_of_week == date.weekday ? Theme.of(context).textTheme.headline3.merge(TextStyle(fontSize: 13)) : Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 13)),
                                        ),
                                        SizedBox(height: 8),
                                      ]
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        currentUser.value.apiToken != null
                                            ? S.of(context).forMoreDetailsPleaseChatWithOurManagers
                                            : S.of(context).signinToChatWithOurManagers,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                                        onPressed: currentUser.value.apiToken != null
                                            ? () {
                                                Navigator.of(context).pushNamed('/Chat',
                                                    arguments: RouteArgument(
                                                        param: new Conversation(
                                                            _con.restaurant.users.map((e) {
                                                              e.image = _con.restaurant.image;
                                                              return e;
                                                            }).toList(),
                                                            name: _con.restaurant.name)));
                                              }
                                            : null,
                                        child: Icon(
                                          Icons.chat,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _con.restaurant.address ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/Pages', arguments: new RouteArgument(id: '1', param: _con.restaurant));
                                        },
                                        child: Icon(
                                          Icons.directions,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '${_con.restaurant.phone} \n${_con.restaurant.mobile}',
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          launch("tel:${_con.restaurant.mobile}");
                                        },
                                        child: Icon(
                                          Icons.call,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.restaurant,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).featured_foods,
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                      ),
                                    ),
                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : ListView.separated(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _con.featuredFoods.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10);
                                      },
                                      itemBuilder: (context, index) {
                                        return FoodItemWidget(
                                          heroTag: 'details_featured_food',
                                          food: _con.featuredFoods.elementAt(index),
                                        );
                                      },
                                    ),
                              SizedBox(height: 100),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.recent_actors,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).what_they_say,
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                      ),
                                    ),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: ReviewsListWidget(reviewsList: _con.reviews),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 32,
                      right: 20,
                      child: ShoppingCartFloatButtonWidget(
                          iconColor: Theme.of(context).primaryColor,
                          labelColor: Theme.of(context).hintColor,
                          routeArgument: RouteArgument(id: '0', param: _con.restaurant.id, heroTag: 'home_slide')),
                    ),
                  ],
                ),
        ));
  }
}

class DetailScreen extends StatefulWidget {
  final String image;
  final String heroTag;

  const DetailScreen ({Key key, this.image, this.heroTag}) : super(key: key);

  @override
  _DetailScreenWidgetState createState() => _DetailScreenWidgetState();
  
  }
  class _DetailScreenWidgetState extends State<DetailScreen>{
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
        )
    );
  }
}
