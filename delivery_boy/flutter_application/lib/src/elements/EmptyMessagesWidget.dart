import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;

class EmptyMessagesWidget extends StatefulWidget {
  EmptyMessagesWidget({
    Key key,
  }) : super(key: key);

  @override
  _EmptyMessagesWidgetState createState() => _EmptyMessagesWidgetState();
}

class _EmptyMessagesWidgetState extends State<EmptyMessagesWidget> {
  bool loading = true;

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),
                ),
              )
            : SizedBox(),
        Container(
          alignment: AlignmentDirectional.center,
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: config.App(context).appHeight(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                width: 140,
                height: 140,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                //     Theme.of(context).focusColor.withOpacity(0.7),
                //     Theme.of(context).focusColor.withOpacity(0.05),
                //     ]
                //   )
                // ),
                child: Image.asset(
                  'assets/img/icon_chat.png',
                  width: 130,
                  fit: BoxFit.cover,
                ),
                // child: Icon(
                //   Icons.chat,
                //   color: Theme.of(context).scaffoldBackgroundColor,
                //   size: 80,
                // ),
              ),
              SizedBox(height: 20),
              Opacity(
                opacity: 0.4,
                child: Text(
                  // S.of(context).youDontHaveAnyConversations,
                  'You dont have any conversation',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
              SizedBox(height: 20),
              !loading
                  ? FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Pages', arguments: 2);
                      },
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      color: Theme.of(context).accentColor.withOpacity(1),
                      shape: StadiumBorder(),
                      child: Text(
                        S.of(context).start_exploring,
                        style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        )
      ],
    );
  }
}
