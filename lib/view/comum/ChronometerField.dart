import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';

class ChronometerField extends CampoDeTextoWidget{

  ///     The frequency in miliseconds that this field calls the _functionUpdateUI(), to invoke the
  /// function registered in constructor.
  int updateFrequencyInMilliseconds = 1000;

  /// DateTime Intervals recorded in this field
  List<DateTimeInterval> _intervals = new List();
  DateFormat _formatter;
  static DateFormat defaultFormatter = DataHoraUtil.formatterHoraBrasileira;

  bool printLogs = false;

  ChronometerField(String label, {ValueKey<String> key, DateTime beginTime, DateFormat formatter, void Function() functionUpdateUI, bool printLogs=false})
      : super(label, 1, null, chave: key, editavel: false ){
    this._formatter = formatter ?? defaultFormatter;
    this.setText( DataHoraUtil.CRONOMETRO_ZERADO );
    this.beginTime = beginTime;
    super.enabledBorderWidth = 0.5;
    this.printLogs = printLogs;
    super.setKeyString( key ?? this.createKeyStringUsingTime( ) );
  }

  String createKeyStringUsingTime(){
    String agoraFormatado = DataHoraUtil.formatterHoraComMilisegundos.format( DateTime.now() );
    return "chronometer_${agoraFormatado}";
  }

  bool isActive(){
    return this.intervals.isNotEmpty && this.intervals.last.endTime == null;
  }
  @override
  Widget getWidget() {
    this._updateFieldWithFormatedDuration();
    return super.getWidget();
  }

  List<DateTimeInterval> get intervals => _intervals;

  Future<void> _beginNewInterval( {DateTime beginTime} ) async {
    beginTime ??= DateTime.now();
    this.intervals.add( new DateTimeInterval( beginTime, null) );
    this._printLogIntervalsSituation();
  }

  void _printLog(String msg){
    if( this.printLogs ) {
      print(msg);
    }
  }

  void _printLogIntervalsSituation(){
    if( !this.printLogs ) {
      return;
    }
    String text = "Intervals amount: ${intervals.length}";
    if( intervals.isNotEmpty ){
      intervals.forEach((element) {
        DateFormat format = DataHoraUtil.formatterHoraBrasileira;
        String begin = format.format(element.beginTime);
        String end = (element.endTime == null) ? "--:--:--" : format.format( element.endTime );
        text += " - [$begin a $end]";
      });
    }
    this._printLog( text );
  }

  Future<void> start() async {
    if( !this.isActive() ){
      this._beginNewInterval();
    }
  }

  void pause(){
    this._getLastInterval().endTime = DateTime.now();
    this._printLogIntervalsSituation();
  }

  void reset(){
    this.pause();
    this.intervals.clear();
  }

  DateTime get beginTime{
    if( this.intervals.isEmpty ){
      return null;
    }
    return this._getLastInterval().beginTime;
  }

  void set beginTime(DateTime beginTime){
    if( beginTime == null ){
      return;
    }
    if( this.isActive() ){
      this._getLastInterval().beginTime = beginTime;
    }else{
      this._beginNewInterval( beginTime: beginTime );
    }
  }

  DateFormat get formatter => this._formatter;

  DateTimeInterval _getLastInterval(){
    if( this.intervals == null || this.intervals.isEmpty ){
      throw new Exception( "Tried update field, but dont't exist intervals created" );
    }
    return this.intervals.last;
  }

  Duration getLastDuration(){
    if( this.intervals.isEmpty ){
      return new Duration(seconds: 0);
    }
    return this._getLastInterval().getDuration();
  }

  void _updateFieldWithFormatedDuration(){
    String duracaoFormatoCronometro = DataHoraUtil.converterDuracaoFormatoCronometro( this.getLastDuration() );
    this._printLog("Formated Duration: ${duracaoFormatoCronometro} - key: ${this.key}");
    super.setText(duracaoFormatoCronometro);
  }


}