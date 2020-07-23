import 'package:intl/intl.dart';

class DataHoraUtil{

  static DateFormat formatterDataBrasileira = new DateFormat("dd/MM/yyyy");
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

  static String converterDateTimeParaDateStringSqllite( DateTime valor ){
    return formatterSqllite.format( valor );
  }

  static DateTime converterDateTimeStringSqllitearaDateTime( String valor ){
    return formatterSqllite.parse( valor );
  }
}