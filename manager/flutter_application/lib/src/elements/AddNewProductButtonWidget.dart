import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/notification_controller.dart';

class AddNewProductButtonWidget extends StatefulWidget {
  const AddNewProductButtonWidget({
    this.iconColor,
    this.labelColor,
    Key key,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;

  @override
  _AddNewProductButtonWidgetState createState() => _AddNewProductButtonWidgetState();
}

class _AddNewProductButtonWidgetState extends StateMVC<AddNewProductButtonWidget> {
  NotificationController _con;

  @override
  void initState() {
    //_con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/AddProductWidget');
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductEditWidget(id: _con.food.id, store: _con.food.restaurant.id)));
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Icon(
            Icons.plus_one_outlined,
            color: this.widget.iconColor,
            size: 28,
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}
