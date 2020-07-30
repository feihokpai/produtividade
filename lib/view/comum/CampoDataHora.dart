import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';

class CampoDataHora extends CampoDeTextoWidget{

  BuildContext context;
  DateTime _dataMinima;
  DateTime _dataMaxima;
  DateTime _dataSelecionada;

  static final String KEY_STRING_CAMPO_HORA_INICIAL = "beginHour";
  static final String KEY_STRING_DATE_PICKER_INICIAL = "beginHourDatePicker";
  static final String KEY_STRING_TIME_PICKER_INICIAL = "beginHourTimePicker";
  static final String KEY_STRING_CAMPO_HORA_FINAL = "endHour";
  static final String KEY_STRING_DATE_PICKER_FINAL = "endHourDatePicker";
  static final String KEY_STRING_TIME_PICKER_FINAL = "endHourTimePicker";
  static final String KEY_STRING_CAMPO_CRONOMETRO = "timerField";
  static final String KEY_STRING_BOTAO_ENCERRAR = "endButton";
  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "returnButton";

  ///Função executada quando mudar o valor preenchido no campo de texto.
  void Function() _onChange;

  CampoDataHora(String label, BuildContext context, {Key chave, DateTime dataMaxima, DateTime dataMinima, void Function() onChange}):super(label, 1, null, chave: chave, editavel: false ){
    this.context = context;
    this.dataMaxima = dataMaxima ?? new DateTime(2030);
    this.dataMinima = dataMinima ?? new DateTime( 1980 );
    this.onChange = onChange;
  }

  void set onChange(void Function() onChange){
    this._onChange = onChange;
  }

  DateTime get dataSelecionada => this._dataSelecionada;

  void set dataSelecionada(DateTime dataSelecionada){
    this._dataSelecionada = dataSelecionada;
    if( this.dataSelecionada != null ) {
      String textoCampo = DataHoraUtil.converterDateTimeParaDataHoraBr( this.dataSelecionada);
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
    showDatePicker(context: this.context,
        initialDate: new DateTime.now(),
        firstDate: this.dataMinima,
        lastDate: this.dataMaxima ).then((selecionada) {
          if( selecionada == null ) {
            return;
          }
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
    showTimePicker(context: this.context, initialTime: new TimeOfDay.now() ).then((value) {
      if( value == null ){
        return;
      }
      TimeOfDay hora = value;
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
            flex: 3,
            child: super.getWidget()
        ),
        Expanded(
          flex: 1,
          child: new IconButton(
            icon: new Icon( Icons.date_range ),
            onPressed: this.exibirCalendario,
          ),
        ),
        Expanded(
          flex: 1,
          child: new IconButton(
            icon: new Icon( Icons.alarm ),
            onPressed: this.exibirRelogio,
          ),
        )
      ],
    );
  }
}