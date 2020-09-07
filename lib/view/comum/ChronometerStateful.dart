import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/TimersProdutividade.dart';

class ChronometerStateful extends StatefulWidget {

  _ChronometerStatefulState state;

  ChronometerField field;

  ChronometerStateful( String label, {ValueKey<String> key, DateTime beginTime, DateFormat formatter,
      bool printLogs=false} ){
    field = new ChronometerField(label, key: key, beginTime: beginTime, formatter: formatter, printLogs: printLogs);
  }

  @override
  _ChronometerStatefulState createState() {
    this.state = _ChronometerStatefulState();
    return this.state;
  }

  bool isActive() {
    return this.field == null ? false : this.field.isActive();
  }

  void start(){
    this.field.start();
    this.state.iniciarTimer();
  }

  void pause(){
    this.field.pause();
    this.state.cancelarTimer();
  }

}

class _ChronometerStatefulState extends State<ChronometerStateful> {

  @override
  Widget build(BuildContext context) {
    return this.widget.field.getWidget();
  }

  void iniciarTimer(){
    TimersProdutividade.createAPeriodicTimer( this.widget, operation: this.setStateWithEmptyFunction );
  }

  void cancelarTimer(){
    TimersProdutividade.cancelTimerIfActivated( this.widget );
  }

  void setStateWithEmptyFunction(){
    this.setState( () {} );
  }

  @override
  void dispose() {
    this.cancelarTimer();
    super.dispose();
  }
}
