import 'package:intl/intl.dart';

class DataHoraUtil{

  static DateFormat formatterDataBrasileira = new DateFormat("dd/MM/yyyy");
  static DateFormat formatterHoraBrasileira = new DateFormat("HH:mm:ss");
  static DateFormat formatterHoraResumidaBrasileira = new DateFormat("HH:mm");
  static DateFormat formatterDataHoraBrasileira = new DateFormat("dd/MM/yyyy HH:mm:ss");
  static DateFormat formatterSqllite = new DateFormat("yyyy-MM-dd HH:mm:ss.SSS");

  ///     retorna a data de hoje no formato 01/01/2001.
  static String dataDeHoje(){
    var now = new DateTime.now();
    return formatterDataBrasileira.format(now);
  }
  ///     Converte uma String de data no formato "01/01/2001" num objeto DateTime. O horário será preenchido com
  /// o valor 00:00:00.000.
  static DateTime converterDataStringParaDateTime(String dataFormatada){
    return formatterDataBrasileira.parse( dataFormatada );
  }

  ///     Converte um DateTime para uma string no formato "01/01/2001".
  static String converterDateTimeParaDataBr(DateTime dateTime){
    return formatterDataBrasileira.format( dateTime );
  }

  ///     Converte um DateTime para uma string no formato "09:07:45".
  static String converterDateTimeParaHoraBr(DateTime dateTime){
    return formatterHoraBrasileira.format( dateTime );
  }

  ///     Converte um DateTime para uma string no formato "09:07", ou seja, cortando os segundos.
  static String converterDateTimeParaHoraResumidaBr(DateTime dateTime){
    return formatterHoraResumidaBrasileira.format( dateTime );
  }

  ///     Converte um DateTime para uma string no formato "01/01/2001 09:07:45".
  static String converterDateTimeParaDataHoraBr(DateTime dateTime){
    return formatterDataHoraBrasileira.format( dateTime );
  }

  static String converterDateTimeParaDateStringSqllite( DateTime valor ){
    return formatterSqllite.format( valor );
  }

  static DateTime converterDateTimeStringSqllitearaDateTime( String valor ){
    return formatterSqllite.parse( valor );
  }

  /**     Cria uma DateTime que corresponde ao dia de amanhã às 00:00:10. É útil principalmente
   * para testes.*/
  static DateTime criarDataAmanhaInicioDoDia(){
    DateTime amanha = DateTime.now().add( new Duration( days: 1 ) );
    DateTime amanhaInicioDia = amanha.subtract( new Duration( hours: amanha.hour, minutes: amanha.minute, seconds: (amanha.second-10) ) );
    return amanhaInicioDia;
  }

  ///     Recebe um Duration e retorna uma string no formato "3 horas e 25 minutos".
  static String criarStringQtdHorasEMinutos( Duration duracao ){
    int horas = duracao.inHours;
    int minutos = duracao.inMinutes - (60*horas);
    return "${horas} horas e ${minutos} minutos";
  }

  ///     Recebe um Duration e retorna uma string no formato "00:00:00".
  static String converterDuracaoFormatoCronometro( Duration duracao ){
    int horas = duracao.inHours;
    String horaString = (horas >= 10) ? "$horas" : "0$horas";
    int minutos = duracao.inMinutes - (60*horas);
    String minutoString = (minutos >= 10) ? "$minutos" : "0$minutos";
    int segundos = duracao.inSeconds - (60*minutos) - (3600*horas);
    String segundoString = (segundos >= 10) ? "$segundos" : "0$segundos";
    return "${horaString}:${minutoString}:${segundoString}";
  }
}