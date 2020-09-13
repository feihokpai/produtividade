import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

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
    DateTime begin = dedicatedTime.inicio;
    String formatedBegin = DataHoraUtil.formatterDataHoraBrasileira.format( begin );
    DateTime now = DateTime.now();
    String formatedNow = DataHoraUtil.formatterDataHoraBrasileira.format( now );
    bool isBeginHourPosteriorNow = now.difference( begin ).inMinutes < 0;
    if( isBeginHourPosteriorNow ){
      problems.add( new ValidationProblem("O horário de início não pode ser posterior ao horário atual."
          " Início: ${formatedBegin}. Agora: ${formatedNow}") );
    }
    DateTime end = dedicatedTime.fim;
    if( end != null ){
      String formatedEnd = DataHoraUtil.formatterDataHoraBrasileira.format( end );
      bool isEndHourPosteriorNow = now.difference( end ).inMinutes < 0;
      if( isEndHourPosteriorNow ){
        problems.add( new ValidationProblem("O horário de fim não pode ser posterior ao horário atual."
            " Fim: ${formatedEnd}. Agora: ${formatedNow}") );
      }
      bool isEndHourPosteriorBeginHour = begin.difference( end ).inMinutes > 0;
      if( isEndHourPosteriorBeginHour ){
        problems.add( new ValidationProblem("O horário de fim não pode ser posterior ao horário inicial."
            " Início: ${formatedBegin}. Fim: ${formatedEnd}") );
      }
    }
    return problems;
  }


}