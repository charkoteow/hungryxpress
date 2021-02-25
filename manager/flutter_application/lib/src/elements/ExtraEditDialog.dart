import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/extra.dart';

// ignore: must_be_immutable
class ExtraEditDialog {
  BuildContext context;
  Extra extras;
  ValueChanged<Extra> onChanged;
  GlobalKey<FormState> _extraItemFormKey = new GlobalKey<FormState>();

  ExtraEditDialog({this.context, this.extras, this.onChanged}) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
        titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
        title: Row(
              children: <Widget>[
                Icon(
                  Icons.donut_small,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(width: 10),
                Text(
                  'Actualizar extra',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          children: <Widget>[
            Form(
              key: _extraItemFormKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: new TextField(
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        extras.name = value;
                      },
                      controller: TextEditingController()..text = extras.name,
                      cursorColor: Theme.of(context).accentColor,
                      maxLines: 1,
                      decoration: getInputDecoration(hintText: 'Ingrese un nombre...', labelText: 'Nombre del extra'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: new TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (String value) {
                        extras.price = double.tryParse(value);
                      },
                      controller: TextEditingController()..text = extras.price.toString(),
                      cursorColor: Theme.of(context).accentColor,
                      maxLines: 1,
                      decoration: getInputDecoration(hintText: 'Ingrese el precio', labelText: 'Precio'),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
                MaterialButton(
                  onPressed: _submit,
                  child: Text(
                    S.of(context).save,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            SizedBox(height: 10),
          ],
        );
      }
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).focusColor)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).hintColor)),
    );
  }

  void _submit() {
    if (_extraItemFormKey.currentState.validate()) {
      _extraItemFormKey.currentState.save();
      onChanged(extras);
      Navigator.pop(context);
    }
  }
}
