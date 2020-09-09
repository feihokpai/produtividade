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

  ///     Verify if exists some Timer associated to "runtime type" of the widget in parameter. If don't exist,
  /// create a new Timer with the frequency = [frequencyInMiliseconds] and invking the function [operation].
  /// If already exists a Timer, don't do anything.
  static void setTimerToWidget( StatefulWidget widget, Timer timer ){
    assert( widget != null, "Tried to create a new Timer, but didn't inform the widget related" );
    assert( timer != null, "Tried to register a new Timer, but past a timer null." );
    assert( timer.isActive, "Tried to register a new Timer, but the timer isn't active." );
    _initCallNumber( widget );
    _timers[widget] = timer;
  }

  static String _widgetIdentifier( StatefulWidget widget ){
    return "${widget.runtimeType}_${widget.hashCode}";
  }

  static bool isTimerActive( StatefulWidget widget ){
    Timer timer = _getActiveTimer(widget);
    return timer != null;
  }

  static void _printLogCancelAndRemoveTimer(StatefulWidget widget, bool canceled, bool removed){
    if( !canceled && !removed ) {
      return;
    }
    String msg = canceled ? "canceled and removed" : "removed";
    _printLog("Timer of ${_widgetIdentifier(widget)} ${msg} from Map");
  }

  static void cancelAndRemoveTimer( StatefulWidget widget ){
    bool canceled = TimersProdutividade._cancelTimer(widget);
    bool removed = TimersProdutividade._removeTimer(widget);
    _printLogCancelAndRemoveTimer(widget, canceled, removed);
  }

  /// If doesn't exist a timer from [widget], it returns false.<br/>
  /// If a timer exists, but is not active, it returns false.<br/>
  /// If a timer exists and is active, return true.
  static bool _cancelTimer( StatefulWidget widget ){
    Timer timer = _getTimer(widget);
    if( timer != null && timer.isActive ) {
      timer.cancel();
      return true;
    }
    return false;
  }

  /// If exists a timer from [widget], remove it from Map and returns true.<br/>
  /// Otherwise it returns false.
  static bool _removeTimer( StatefulWidget widget ){
    Timer timer = _getTimer(widget);
    if( timer != null ) {
      _timers.remove( widget );
      return true;
    }
    return false;
  }

  static void cancelAllTimers(){
    _timers.forEach((key, Timer timer) {
      TimersProdutividade._cancelTimer( key );
      _printLog("Timer of ${_widgetIdentifier(key)} canceled");
    });
    _timers.clear();
    _printLog("All Timers removed");
  }

  /// Returns true or false if exists (or not) an active Timer linked to [widget] parameter
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
      operation();
      _printLog( "Timer of ${_widgetIdentifier(widget)} executed. count: ${_nextCallNumber(widget)}. Timer ${timer.hashCode} - "
          " operation ${operation.hashCode}" );
    } );
    _printLog( "Timer of ${_widgetIdentifier(widget)} created. code: ${_timers[widget].hashCode}. Total created: ${_timers.length}" );
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
