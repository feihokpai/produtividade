///     DurationWithInterval is a Duration that register the begin and the end DateTime
/// envolved in the process.
class DateTimeInterval{
  DateTime _beginTime;
  DateTime _endTime;

  DateTimeInterval( DateTime begin, DateTime end ){
    this._beginTime = begin;
    this._endTime = end;
  }

  ///     Duration of the difference between beginTime and endTime. If endTime is null, returns the difference
  /// between beginTime and DateTime.now()
  Duration getDuration(){
    if( beginTime == null ){
      throw new Exception("Tried acess the duration of a DateTimeInterval, but the beginTime is null");
    }
    DateTime dateAfter = this.endTime ?? DateTime.now();
    int durationInMicroseconds = dateAfter.difference( beginTime ).inMicroseconds;
    return new Duration( microseconds: durationInMicroseconds );
  }

  DateTime get beginTime => this._beginTime;

  void set beginTime(DateTime beginTime){
    this._beginTime = beginTime;
  }

  DateTime get endTime => this._endTime;

  void set endTime(DateTime endTime){
    this._endTime = endTime;
  }

}