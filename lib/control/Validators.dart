import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/Labels.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';

class ValidationException implements Exception{
  List<ValidationProblem> _problems = new List();

  ValidationException( {List<ValidationProblem> problems} ){
    this.problems = problems;
  }

  void addProblem(String description){
    this.problems.add( new ValidationProblem( description ) );
  }

  List<ValidationProblem> get problems => this._problems;

  void set problems(List<ValidationProblem> problems){
    this._problems = problems ?? new List();
  }

  /// Generate a string with some lines having a validation problem message each.
  String generateMsgToUser(){
    String msg = "";
    this.problems.forEach((problem) {
      msg += "* "+problem.description+"\n";
    });
    return msg;
  }
}

class ValidationProblem{
  String description;

  ValidationProblem( this.description );
}

///     Class that will validate so many informations, to avoid that the user insert invalid values
/// and to avoid that the controller process invalid data.
class Validators{
  static void validateTimeToInsert( TempoDedicado dedicatedTime ){
    List<ValidationProblem> problems = new List();
    problems.addAll( _verifyIfSomeHourIsAfterTheLimit( dedicatedTime ) );
    if( problems.length > 0 ){
      throw new ValidationException( problems: problems );
    }
  }

  static List<ValidationProblem> _verifyIfSomeHourIsAfterTheLimit( TempoDedicado dedicatedTime ){
    List<ValidationProblem> problems = new List();
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ?
        DataHoraUtil.formatterDataSemAnoHoraAmericana : DataHoraUtil.formatterDataSemAnoHoraBrasileira;
    DateTime begin = dedicatedTime.inicio;
    DateTime end = dedicatedTime.fim;
    problems.addAll( Validators._verifyIfInitialTimeIsLaterThanCurentTime( formatter, begin ) );
    if( end != null ){
      problems.addAll( Validators._verifyIfEndTimeIsLaterThanCurentTime(formatter, end) );
      problems.addAll( Validators._verifyIfEndTimeIsLaterThanInitialTime(formatter, begin, end) );
    }
    return problems;
  }

  static List<ValidationProblem> _verifyIfInitialTimeIsLaterThanCurentTime(DateFormat formatter, DateTime begin) {
    bool isBeginHourPosteriorNow = DateTime.now().difference( begin ).inMinutes < 0;
    if( isBeginHourPosteriorNow ){
      String formatedNow = formatter.format( DateTime.now() );
      String formatedBegin = formatter.format( begin );
      return <ValidationProblem>[ Validators._createValidationProblem(Labels.begin_time_after_now, formatedBegin, formatedNow) ];
    }
    return new List();
  }

  static List<ValidationProblem> _verifyIfEndTimeIsLaterThanCurentTime(DateFormat formatter, DateTime end) {
    bool isEndHourPosteriorNow = DateTime.now().difference( end ).inMinutes < 0;
    if( isEndHourPosteriorNow ){
      String formatedEnd = formatter.format( end );
      String formatedNow = formatter.format( DateTime.now() );
      return <ValidationProblem>[ Validators._createValidationProblem( Labels.end_time_after_now, formatedEnd, formatedNow) ];
    }
    return new List();
  }

  static List<ValidationProblem> _verifyIfEndTimeIsLaterThanInitialTime(DateFormat formatter, DateTime begin, DateTime end) {
    bool isEndHourPosteriorBeginHour = begin.difference( end ).inMinutes > 0;
    if( isEndHourPosteriorBeginHour ){
      String formatedEnd = formatter.format( end );
      String formatedBegin = formatter.format( begin );
      return <ValidationProblem>[ Validators._createValidationProblem( Labels.end_time_after_begin, formatedBegin, formatedEnd ) ];
    }
    return new List();
  }

  static ValidationProblem _createValidationProblem( String labelName, String parameter1, String parameter2 ){
    List<String> parametersLabel = <String>[parameter1,parameter2];
    String problemDescription = ComunsWidgets.getLabel( labelName, parameters: parametersLabel );
    return new ValidationProblem( problemDescription );
  }

}