import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';

class ChronometerField extends CampoDeTextoWidget{

  /// Indicates if the Field is showing and updating the Timer in the screen or not.
  /// If it is false, the field will not be updated until it to be changed to true.
//  bool activated = false;

  /// Timer that create periodic calls to calculate the Duration past and invoke the _functionUpdateUI()
  Timer _timer;

  ///     The frequency in miliseconds that this field calls the _functionUpdateUI(), to invoke the
  /// function registered in constructor.
  int updateFrequencyInMilliseconds = 1000;

  /// DateTime Intervals recorded in this field
  List<DateTimeInterval> _intervals = new List();
  void Function() _functionUpdateUI;
  DateFormat _formatter;
  static DateFormat defaultFormatter = DataHoraUtil.formatterHoraBrasileira;

  bool printLogs = false;

  ChronometerField(String label, {ValueKey<String> key, DateTime beginTime, DateFormat formatter, void Function() functionUpdateUI, bool printLogs=false})
      : super(label, 1, null, chave: key, editavel: false ){
    assert( functionUpdateUI != null, "Is necessary to define a function to Update UI or the Chronometer Field"
        " will be useless." );
    this._formatter = formatter ?? defaultFormatter;
    this._functionUpdateUI = functionUpdateUI;
    this.setText( DataHoraUtil.CRONOMETRO_ZERADO );
    this.beginTime = beginTime;
    super.enabledBorderWidth = 0.5;
    this.printLogs = printLogs;
  }

  bool isActive(){
    return this.intervals.isNotEmpty && this.intervals.last.endTime == null;
  }

  List<DateTimeInterval> get intervals => _intervals;

  Future<void> _beginNewInterval( {DateTime beginTime} ) async {
    beginTime ??= DateTime.now();
    this.intervals.add( new DateTimeInterval( beginTime, null) );
    if( this.printLogs ) {
      this._printLogIntervalsSituation();
    }
    await this._createAPeriodicTimer();
  }

  void _printLogIntervalsSituation(){
    String text = "Intervals amount: ${intervals.length}";
    if( intervals.isNotEmpty ){
      intervals.forEach((element) {
        DateFormat format = DataHoraUtil.formatterHoraBrasileira;
        String begin = format.format(element.beginTime);
        String end = (element.endTime == null) ? "--:--:--" : format.format( element.endTime );
        text += " - [$begin a $end]";
      });
    }
    print( text );
  }

  Future<void> start() async {
    if( !this.isActive() ){
      this._beginNewInterval();
    }
  }

  void pause(){
    this._getLastInterval().endTime = DateTime.now();
    this.cancelTimerIfActivated();
    if( this.printLogs ) {
      this._printLogIntervalsSituation();
    }
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

  void cancelTimerIfActivated(){
    if( this._timer != null && this._timer.isActive ){
      this._timer.cancel();
    }
  }

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
    super.setText(duracaoFormatoCronometro);
  }

  Future<void> _createAPeriodicTimer() async {
    this.cancelTimerIfActivated();
    Duration frequency = new Duration( milliseconds: updateFrequencyInMilliseconds );
    this._timer = Timer.periodic( frequency, (timer) async {
      this._updateFieldWithFormatedDuration();
      this._functionUpdateUI.call();
    });
  }

}