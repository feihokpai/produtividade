import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/TimersProdutividade.dart';

class ChronometerStateful extends StatefulWidget {

  _ChronometerStatefulState state;

  ChronometerField field;

  ChronometerStateful( String label, {ValueKey<String> key, DateTime beginTime, DateFormat formatter,
      bool printLogs=false} ){
    this.field = new ChronometerField(label, key: key, beginTime: beginTime, formatter: formatter, printLogs: printLogs);
  }

  @override
  _ChronometerStatefulState createState() {
    this.state = _ChronometerStatefulState();
    return this.state;
  }

  DateTime get beginTime => this.field.beginTime;

  void set beginTime( DateTime dateTime ){
    this.field.beginTime = beginTime;
  }

  bool isActive() {
    return this.field == null ? false : this.field.isActive();
  }

  void start(){
    this.field.start();
    this.state.iniciarTimer();
  }

  /// It pauses the chronometer field and cancels the Timer associated with it.
  void pause(){
    this.field.pause();
    if( this.state != null ) {
      this.state.cancelarTimer();
    }else {
      TimersProdutividade.cancelAndRemoveTimer(this);
    }
  }

}

class _ChronometerStatefulState extends State<ChronometerStateful> {


  @override
  Widget build(BuildContext context) {
    this.initVariables();
    Widget widget = this.widget.field.getWidget();
    return widget;
  }

  void initVariables(){
    if( this.widget.isActive() && !this.isTimerActive() ){
      this.iniciarTimer();
    }
    if( !this.widget.isActive() && this.isTimerActive()){
      this.cancelarTimer();
    }
  }

  void iniciarTimer(){
    TimersProdutividade.createAPeriodicTimer(widget, operation: this.updateTextField );
  }

  void updateTextField(){
    this.widget.field.updateFieldWithFormatedDuration();
  }

  void cancelarTimer(){
    TimersProdutividade.cancelAndRemoveTimer(this.widget);
  }

  bool isTimerActive(){
    return TimersProdutividade.isTimerActive( this.widget );
  }

  String _stringIdentifier(){
    return "ChronometerStateful_${this.widget.hashCode}";
  }

  void setStateWithEmptyFunction(){
    if( super.mounted ) {
      this.setState(() {});
    }
  }

  @override
  void dispose() {
    this.cancelarTimer();
    super.dispose();
  }

}
