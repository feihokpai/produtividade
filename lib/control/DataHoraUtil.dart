import 'package:intl/intl.dart';

class DataHoraUtil{

  static DateFormat formatterDataBrasileira = new DateFormat("dd/MM/yyyy");
  static DateFormat formatterDataResumidaBrasileira = new DateFormat("dd/MM");
  static DateFormat formatterHoraBrasileira = new DateFormat("HH:mm:ss");
  static DateFormat formatterHoraComMilisegundos = new DateFormat("HH:mm:ss.SSS");
  static DateFormat formatterDataHoraResumidaBrasileira = new DateFormat("dd/MM/yyyy HH:mm");
  static DateFormat formatterDataSemAnoHoraBrasileira = new DateFormat("dd/MM - HH:mm:ss");
  static DateFormat formatterDataSemAnoHoraAmericana = new DateFormat("MM/dd - hh:mm:ss a");
  static DateFormat formatterDataHoraAmericana = new DateFormat("MM/dd/yyyy hh:mm:ss a");
  static DateFormat formatterHoraResumidaBrasileira = new DateFormat("HH:mm");
  static DateFormat formatterDataHoraBrasileira = new DateFormat("dd/MM/yyyy HH:mm:ss");
  static DateFormat formatterSqllite = new DateFormat("yyyy-MM-dd HH:mm:ss.SSS");

  static const String CRONOMETRO_ZERADO = "00:00:00";

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
  @deprecated
  static String converterDateTimeParaDataHoraBr(DateTime dateTime){
    return formatterDataHoraBrasileira.format( dateTime );
  }

  ///     Converte um DateTime para uma string no formato "01/01/2001 09:07:45".
  static String converterDateTimeParaString(DateTime dateTime, DateFormat formatter){
    return formatter.format( dateTime );
  }

  /// [formatter], escolher um dentre os campos estáticos da classe DataHoraUtil
  static DateTime converterStringDateTime(String dataFormatada, DateFormat formatter){
    return formatter.parse( dataFormatada );
  }
  
  ///     Converte um DateTime para uma string no formato "01/01/2001 09:07:45".
  ///
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

  /**     Cria uma DateTime que corresponde ao dia de hoje às 00:00:10. É útil principalmente
   * para testes.*/
  static DateTime criarDataHojeInicioDoDia(){
    DateTime agora = DateTime.now();
    DateTime hojeInicioDoDia = agora.subtract( new Duration( hours: agora.hour, minutes: agora.minute, seconds: (agora.second-10) ) );
    return hojeInicioDoDia;
  }

  /// Cria um DateTime com a data de ontem e com o horário de 23:59.
  static DateTime criarDataOntemFimDoDia(){
    DateTime agora = DateTime.now();
    DateTime ontemMesmoHorarioDeAgora = agora.subtract( new Duration(days: 1) );
    return DataHoraUtil.criarDataHoraMesmoDiaAs2359( ontemMesmoHorarioDeAgora );
  }

  static DateTime criarDataHoraMesmoDiaAs2359(DateTime dataHora){
    return dataHora.add(
        new Duration(
            hours: (23-dataHora.hour),
            minutes: (59-dataHora.minute)
        )
    );
  }

  /// Cria um DateTime com a data de ontem e com o horário de 23:59.
  static DateTime criarDataHojeFimDoDia(){
    DateTime agora = DateTime.now();
    return DataHoraUtil.criarDataHoraMesmoDiaAs2359( agora );
  }

  /// Cria um new DateTime com a mesma data e hora da que foi passada por parãmetro.
  static DateTime criarDataHoraIgual( DateTime data ){
    return new DateTime(data.year, data.month, data.day, data.hour, data.minute, data.second,
        data.millisecond, data.microsecond );
  }

  /// Cria uma data do mês anterior com o mesmo dia do mês que hoje, com horário 00:00:00.
  static DateTime criarDataMesAnteriorMesmoDia(DateTime data){
    if( data.month != DateTime.january ) {
      return DateTime(data.year, data.month-1, data.day);
    }else{
      return DateTime(data.year-1, DateTime.december, data.day);
    }
  }

  /// Cria uma data do anos anterior com o mesmo dia e mês que hoje, com horário 00:00:00.
  static DateTime criarDataAnoAnteriorMesmoDiaEMes(DateTime data){
    return DateTime(data.year-1, data.month, data.day);
  }

  ///     Verifica se data1 é uma data de um dia anterior a data2. Ou seja, se data1 for 01/01/2020 23:59
  /// e data2 for 02/01/2020 00:00, retorna true, porque significa que é uma data de um dia anterior,
  /// mesmo que a diferença entre elas seja de 1 minuto. Por outro lado, se data1 for 01/01/2020 00:00
  /// e data2 for 01/01/2020 23:59 retornará false, porque apesar de estarem com 23h59m de diferença,
  /// ambas as datas estão no mesmo dia.
  /// TODO Criar teste de unidade para eDataDeDiaAnterior();
  static bool eDataDeDiaAnterior( DateTime data1, DateTime data2 ){
    assert( data1 != null && data2 != null );
    if( data1.year < data2.year ){
      return true;
    }
    if( data1.year == data2.year && data1.month < data2.month ){
      return true;
    }
    if( data1.year == data2.year && data1.month == data2.month && data1.day < data2.day ){
      return true;
    }
    return false;
  }

  ///    Retorna true se ambos os dateTime tiverem o mesmo dia, mês e ano, independente do horário.
  // TODO Criar teste de unidade para eDataMesmoDia();
  static bool eDataMesmoDia( DateTime data1, DateTime data2 ){
    return (
        data1.year == data2.year
        && data1.month == data2.month
        && data1.day == data2.day);
  }

  ///    Retorna true se ambos os dateTime tiverem o mesmo horário, considerando
  /// apenas horas, minutos e segundos. Não considera a data, nem milisegundos.
  // TODO Criar teste de unidade para eMesmoHorarioAteSegundos();
  static bool eMesmoHorarioAteSegundos( DateTime data1, DateTime data2 ){
    return (
        DataHoraUtil.eMesmoHorarioAteMinutos(data1, data2)
            && data1.second == data2.second);
  }

  ///    Retorna true se ambos os dateTime tiverem o mesmo horário, considerando
  /// apenas horas e minutos apenas. Não considera a data, segundos, nem milisegundos.
  // TODO Criar teste de unidade para eMesmoHorarioAteSegundos();
  static bool eMesmoHorarioAteMinutos( DateTime data1, DateTime data2 ){
    return (
        data1.hour == data2.hour
            && data1.minute == data2.minute);
  }

  // TODO Criar teste de unidade para eHorarioAnteriorAteSegundos();
  /// Verifica se horario1 tem horário anterior a horario2, considerando somente
  /// hora, minuto e segundo. Não considera milisegundos, nem a data.
  static bool eHorarioAnteriorAteSegundos(DateTime horario1, DateTime horario2) {
    if( horario1.hour != horario2.hour){
      return horario1.hour < horario2.hour;
    }else if( horario1.minute != horario2.minute ){
      return horario1.minute < horario2.minute;
    }
    return horario1.second < horario2.second;
  }

  ///     Recebe um Duration e retorna uma string no formato "3 horas e 25 minutos".
  static String criarStringQtdHorasEMinutos( Duration duracao ){
    int horas = duracao.inHours;
    int minutos = duracao.inMinutes - (60*horas);
    return "${horas} horas e ${minutos} minutos";
  }

  ///     Recebe um Duration e retorna uma string no formato "3h25m".
  static String criarStringQtdHorasEMinutosAbreviados( Duration duracao ){
    int horas = duracao.inHours;
    int minutos = duracao.inMinutes - (60*horas);
    return "${horas}h${minutos}m";
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

  /// It Returns a string with current hour in format "HH:mm:ss.SSS", that is, from hours to miliseconds
  static String timestampMili(){
    return DataHoraUtil.formatterHoraComMilisegundos.format( DateTime.now() );
  }
  
  /// The beginning date of Produtividade Project.
  static DateTime projectBeginDate(){
    return new DateTime( 2020, DateTime.july, 20 );
  }

  /// It Receives a DateTime complete (ex: 2020-08-28 06:14:01.765435) and returns other with the
  /// same date but with hour reseted (ex: 2020-08-28 00:00:00.000000)
  static DateTime resetHourMantainDate(DateTime date){
    return new DateTime( date.year, date.month, date.day );
  }

  static bool isToday( DateTime date ){
    DateTime today = DateTime.now();
    return DataHoraUtil.eDataMesmoDia(date, today);
  }
}