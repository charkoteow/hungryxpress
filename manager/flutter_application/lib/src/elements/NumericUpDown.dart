import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericUpDown extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final int max;

  NumericUpDown({Key key, this.text, this.onChanged, this.max})
      : super(key: key);

  @override
  _NumericUpDownState createState() => _NumericUpDownState();
}

class _NumericUpDownState extends State<NumericUpDown> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text; // Setting the initial value for the field.
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 30.0,
        padding: EdgeInsets.all(2.0),
        // foregroundDecoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(0.0),
        //   border: Border.all(
        //     color: Theme.of(context).accentColor,
        //     width: 1.0,
        //   ),
        // ),
        child: Row(
          children: <Widget>[
            Container(
              height: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.2,
                        ),
                      ),
                    ),
                    child: InkWell(
                      child: Icon(
                        Icons.remove,
                        color: Theme.of(context).accentColor,
                        size: 20.0,
                      ),
                      onTap: () {
                        int currentValue = int.parse(_controller.text);
                        setState(() {
                          if (currentValue > 1) {
                            currentValue--;
                            _controller.text =
                                (currentValue > 0 ? currentValue : 0)
                                    .toString(); // decrementing value
                            widget.onChanged(currentValue.toString());
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(1.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                controller: _controller,
                readOnly: true,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
              ),
            ),
            Container(
              height: 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.2,
                        ),
                      ),
                    ),
                    child: InkWell(
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).accentColor,
                        size: 20.0,
                      ),
                      onTap: () {
                        int currentValue = int.parse(_controller.text);
                        setState(() {
                          if (currentValue < widget.max) {
                            currentValue++;
                            _controller.text =
                                (currentValue).toString(); // incrementing value
                            widget.onChanged(currentValue.toString());
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
