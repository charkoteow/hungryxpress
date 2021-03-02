import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/extra.dart' as model;
import '../models/route_argument.dart';

// ignore: must_be_immutable
class ExtraItemWidget extends StatelessWidget {
  final String heroTag;
  model.Extra extra;
  final ValueChanged<void> onAction;
  ValueChanged<model.Extra> onLongPress;

  ExtraItemWidget({Key key, this.heroTag, this.extra, this.onAction, this.onLongPress}) : super(key: key);

  getimageBuilder() {
    //Agotado
    if (extra.active == 0){
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: CachedNetworkImage(
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            imageUrl: extra.image.thumb,
            placeholder: (context, url) => Image.asset(
              'assets/img/loading.gif',
              fit: BoxFit.cover,
              height: 60,
              width: 60,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            imageBuilder: (context, imageProvider) => new Container (
              height: 60,
              width: 60,
              child : new Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text('Sold out', style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: const Color(0xff000000),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                ),
              ),
            ),
          ),
        );
    } else {
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: CachedNetworkImage(
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            imageUrl: extra.image.thumb,
            placeholder: (context, url) => Image.asset(
              'assets/img/loading.gif',
              fit: BoxFit.contain,
              height: 60,
              width: 60,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onLongPress: () {
        this.onLongPress(extra);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + extra.id,
              child: getimageBuilder(),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          extra.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        height: 40,
                        width: 40,
                        child: SwitchListTile(
                          value: extra.active == 0 ? false : true,
                          onChanged: (value) {
                            this.onAction(value);
                          },
                          activeTrackColor: Theme.of(context).accentColor.withOpacity(0.5),
                          activeColor: Theme.of(context).accentColor,
                        )
                      ),
                      Helper.getPrice(
                        extra.price,
                        context,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}