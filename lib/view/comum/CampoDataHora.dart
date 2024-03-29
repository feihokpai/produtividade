import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class CampoDataHora extends CampoDeTextoWidget{

  BuildContext context;
  DateTime _dataMinima;
  DateTime _dataMaxima;
  DateTime _dataSelecionada;
  DateFormat formatter;
  static DateFormat formatterPadrao = DataHoraUtil.formatterDataHoraResumidaBrasileira;
  bool _showDatePicker = true;
  bool _showHourPicker = true;

  static String PREFIXO_KEY_STRING_ICONE_DATE_PICKER = "datePicker_";
  static String PREFIXO_KEY_STRING_ICONE_TIME_PICKER = "timePicker_";

  Locale _locale;
  static Locale defaultLocale = new Locale("pt", "");

  ///Função executada quando mudar o valor preenchido no campo de texto.
  void Function() _onChange;

  CampoDataHora(String label, BuildContext context, {ValueKey<String> chave, DateTime dataMaxima, DateTime dataMinima,
    DateFormat dateTimeFormatter, DateTime dataInicialSelecionada, Locale locale, bool showHourPicker=true,
    bool showDatePicker=true, void Function() onChange})
      : assert( context != null ),
        assert( dataMaxima == null || dataMinima == null
            || !(DataHoraUtil.eDataDeDiaAnterior( dataMaxima , dataMinima) )
        ),
      super(label, 1, null, chave: chave, editavel: false ){
    this.context = context;
    this.dataMaxima = dataMaxima ?? new DateTime(2030);
    this.dataMinima = dataMinima ?? new DateTime( 1980 );
    this.onChange = onChange;
    this.formatter = dateTimeFormatter ?? CampoDataHora.formatterPadrao;
    this.dataSelecionada = dataInicialSelecionada;
    _showDatePicker = showDatePicker;
    _showHourPicker = showHourPicker;
    super.textStyleTexto = Estilos.textStyleCampoDataHora;
    this._locale = locale ?? CampoDataHora.defaultLocale;
  }

  void set onChange(void Function() onChange){
    this._onChange = onChange;
  }

  DateTime get dataSelecionada => this._dataSelecionada;

  void set dataSelecionada(DateTime dataSelecionada){
    this._dataSelecionada = dataSelecionada;
    if( this.dataSelecionada != null ) {
      String textoCampo = this.formatter.format( this.dataSelecionada);
      this.setText(textoCampo);
    }
  }

  DateTime get dataMaxima => this._dataMaxima;

  void set dataMaxima(DateTime dataMaxima){
    this._dataMaxima = dataMaxima;
  }

  DateTime get dataMinima => this._dataMinima;

  void set dataMinima(DateTime dataMinima){
    this._dataMinima = dataMinima;
  }

  void exibirCalendario( ) async {
    DateTime dataInicial = (this.dataSelecionada ?? new DateTime.now() );
    showDatePicker(context: this.context,
        initialDate: dataInicial,
        locale: _locale,
        firstDate: this.dataMinima,
        lastDate: this.dataMaxima ).then((selecionada) {
          if( selecionada == null ) {
            return;
          }
          this.dataSelecionada ??= new DateTime.now();
          this.dataSelecionada = new DateTime(selecionada.year,
              selecionada.month, selecionada.day, this.dataSelecionada.hour,
              this.dataSelecionada.minute, this.dataSelecionada.second
          );
          if( this._onChange != null ) {
            this._onChange.call();
          }
    });
  }

  void exibirRelogio() async{
    TimeOfDay horaInicial = new TimeOfDay.now();
    if( this.dataSelecionada != null ){
      horaInicial = new TimeOfDay.fromDateTime( this.dataSelecionada );
    }
    showTimePicker(context: this.context, initialTime: horaInicial ).then((value) {
      if( value == null ){
        return;
      }
      TimeOfDay hora = value;
      this.dataSelecionada ??= new DateTime.now();
      this.dataSelecionada = new DateTime( this.dataSelecionada.year,
          this.dataSelecionada.month, this.dataSelecionada.day,
          hora.hour,hora.minute, 0
      );
      if( this._onChange != null ) {
        this._onChange.call();
      }
    });
  }

  @override
  Widget getWidget(){
    return new Row(
      children: <Widget>[
        Expanded(
            flex: 65,
            child: super.getWidget()
        ),
        this.showDatePickerOrEmpty(),
        this.showTimePickerOrEmpty(),
      ],
    );
  }

  Widget showDatePickerOrEmpty(){
    if( !this._showDatePicker ){
      return new Container();
    }else{
      String keyCalendario = "${CampoDataHora.PREFIXO_KEY_STRING_ICONE_DATE_PICKER}${super.key.value}";
      return Expanded(
        flex: 18,
        child: new IconButton(
          key: new ValueKey( keyCalendario ),
          icon: new Icon( Icons.date_range ),
          onPressed: this.exibirCalendario,
        ),
      );
    }
  }

  Widget showTimePickerOrEmpty(){
    String keyRelogio = "${CampoDataHora.PREFIXO_KEY_STRING_ICONE_TIME_PICKER}${super.key.value}";
    if( !this._showHourPicker ){
      return new Container();
    }else{
      return new Expanded(
        flex: 17,
        child: new IconButton(
          key: new ValueKey( keyRelogio ),
          icon: new Icon( Icons.alarm ),
          onPressed: this.exibirRelogio,
        ),
      );
    }
  }
}