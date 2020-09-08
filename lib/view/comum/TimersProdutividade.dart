import 'dart:async';

import 'package:flutter/material.dart';

/// This class has the objective to have only one active periodic Timer to refresh each screen.
class TimersProdutividade{
  static Map<StatefulWidget, Timer> _timers = new Map();
  static Map<StatefulWidget, int> callsNumber = new Map();
  static bool printLogs = false;

  ///     Verify if exists some Timer associated to "runtime type" of the widget in parameter. If don't exist,
  /// create a new Timer with the frequency = [frequencyInMiliseconds] and invking the function [operation].
  /// If already exists a Timer, don't do anything.
  static void createAPeriodicTimer( StatefulWidget widget,
      {int frequencyInMiliseconds = 1000, @required void Function() operation } ){
    assert( widget != null, "Tried to create a new Timer, but didn't inform the widget related" );
    assert( operation != null, "Tried to create a new Timer, but didn't inform the operation that it needed executing." );
    assert( frequencyInMiliseconds > 0, "Tried to create a new Timer, but set the update execution frequency to zero.");
    _setTimer(widget, frequencyInMiliseconds, operation );
  }

  static String _widgetIdentifier( StatefulWidget widget ){
    return "${widget.runtimeType}_${widget.hashCode}";
  }

  static void cancelTimerIfActivated( StatefulWidget widget ){
    Timer timer = _getActiveTimer(widget);
    if( timer != null ){
      timer.cancel();
      _printLog( "Timer of ${_widgetIdentifier(widget)} canceled" );
    }
  }

  static void cancelAllTimers(){
    _timers.forEach( ( mapKey, Timer timer) {
      timer.cancel();
    });
  }

  static Timer _getActiveTimer(StatefulWidget widget){
    Timer timer = _getTimer(widget);
    if( timer != null && timer.isActive ){
      return timer;
    }
    return null;
  }

  static Timer _getTimer(StatefulWidget widget){
    return _timers[widget];
  }

  static void _setTimer(StatefulWidget widget, int frequencyMili, void Function( ) operation ){
    Timer timer = _getActiveTimer(widget);
    if(timer != null){
      return;
    }
    Duration frequency = new Duration( milliseconds: frequencyMili );
    _initCallNumber( widget );
    _timers[widget] = Timer.periodic( frequency, (timer){
      _printLog( "Timer of ${_widgetIdentifier(widget)} executed: ${_nextCallNumber(widget)}" );
      operation.call();
    } );
    _printLog( "Timer of ${_widgetIdentifier(widget)} created" );
  }

  static void _initCallNumber( StatefulWidget widget ){
    callsNumber[widget] = 0;
  }

  static int _nextCallNumber( StatefulWidget widget ){
    return (++callsNumber[widget]);
  }

  static void _printLog(String msg){
    if( printLogs ){
      print( msg );
    }
  }
}
