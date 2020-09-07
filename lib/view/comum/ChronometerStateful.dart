import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';

class ChronometerStateful extends StatefulWidget {

  ChronometerField field;

  ChronometerStateful( String label, {ValueKey<String> key, DateTime beginTime, DateFormat formatter,
      bool printLogs=false} ){
    field = new ChronometerField(label, key: key, beginTime: beginTime, formatter: formatter, printLogs: printLogs);
  }

  @override
  _ChronometerStatefulState createState() => _ChronometerStatefulState();
}

class _ChronometerStatefulState extends State<ChronometerStateful> {
  @override
  Widget build(BuildContext context) {
    return this.widget.field.getWidget();
  }
}
