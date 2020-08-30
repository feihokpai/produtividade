import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

/// This class has the objective to have only one active periodic Timer to refresh each screen.
class TimersProdutividade{
//  static Map<Type, _TimerProdutividade> _timers = new Map();
  static Map<Type, Timer> _timers = new Map();
  static Map<Type, int> callsNumber = new Map();
  static bool printLogs = false;

  static void createAPeriodicTimer( StatefulWidget widget,
      {int frequencyInMiliseconds = 1000, @required void Function() operation } ){
    assert( widget != null, "Tried to create a new Timer, but didn't inform the widget related" );
    assert( operation != null, "Tried to create a new Timer, but didn't inform the operation that it needed executing." );
    assert( frequencyInMiliseconds > 0, "Tried to create a new Timer, but set the update execution frequency to zero.");
    cancelTimerIfActivated( widget );
    _setTimer(widget, frequencyInMiliseconds, operation );
  }

  static void cancelTimerIfActivated( StatefulWidget widget ){
    Timer timer = _getTimer(widget);
    if( timer != null && timer.isActive ){
      timer.cancel();
      _printLog( "Timer of ${widget.runtimeType} canceled" );
    }
  }

  static void cancelAllTimers(){
    _timers.forEach( (Type type, Timer timer) {
      timer.cancel();
    });
  }

  static Timer _getTimer(StatefulWidget widget){
    return _timers[widget.runtimeType];
  }

  static void _setTimer(StatefulWidget widget, int frequencyMili, void Function( ) operation ){
    Duration frequency = new Duration( milliseconds: frequencyMili );
    callsNumber[widget.runtimeType] ??= 0;
    _timers[widget.runtimeType] = Timer.periodic( frequency, (timer){
      _printLog( "Timer of ${widget.runtimeType} executed: ${++callsNumber[widget.runtimeType]}" );
      operation.call();
    } );
    _printLog( "Timer of ${widget.runtimeType} created" );
  }

  static void _printLog(String msg){
    if( printLogs ){
      print( msg );
    }
  }
}
