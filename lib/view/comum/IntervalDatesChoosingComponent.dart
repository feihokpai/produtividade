import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/Labels.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class IntervalDatesChoosingComponent{

  DateTime beginDate;
  CampoDataHora beginDateField;
  DateTime endDate;
  CampoDataHora endDateField;

  BuildContext _externalContext;
  StatefulBuilder _stateFullBuilder;

  StateSetter _setterStateOfStatefulBuilder;
  BuildContext _contextOfStatefulBuilder;
//  State<StatefulWidget> _stateOfStatefulBuilder;

  final double DIALOG_SIZE = 200.0;
  
  IntervalDatesChoosingComponent( DateTime beginDate, DateTime endDate, BuildContext externalContext){
    this.beginDate = beginDate ?? DateTime.now();
    this.endDate = endDate ?? DateTime.now();
    this._externalContext = externalContext;
    this._generateStatefulBuilder();
  }

  void initializeFields( BuildContext context ) {
    this.initializeBeginDateField( context );
    this.initializeEndDateField( context );
  }

  void initializeBeginDateField( BuildContext context ){
    DateTime hoje = DateTime.now();
    DateTime minimalDate = DataHoraUtil.projectBeginDate();
    String labelBeginDate = ComunsWidgets.getLabel( Labels.label_field_start_date );
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ?
        DataHoraUtil.formatterDataAmericana : DataHoraUtil.formatterDataBrasileira;
    this.beginDateField ??= new CampoDataHora( labelBeginDate, context, dataInicialSelecionada: this.beginDate,
        dataMinima: minimalDate, dataMaxima: hoje, dateTimeFormatter: formatter,
        showHourPicker: false,
        locale: ComunsWidgets.currentLocale,
        onChange: (){
          this.beginDate = this.beginDateField.dataSelecionada;
          this._emptySetStateFunction();
        }
    );
  }

  void initializeEndDateField( BuildContext context ){
    DateTime hoje = DateTime.now();
    DateTime minimalDate = DataHoraUtil.projectBeginDate();
    String labelEndDate = ComunsWidgets.getLabel( Labels.label_field_end_date );
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ?
        DataHoraUtil.formatterDataAmericana : DataHoraUtil.formatterDataBrasileira;
    this.endDateField ??= new CampoDataHora( labelEndDate, context, dataInicialSelecionada: this.endDate,
        dataMinima: minimalDate, dataMaxima: hoje, dateTimeFormatter: formatter,
        showHourPicker: false,
        locale: ComunsWidgets.currentLocale,
        onChange: (){
          this.endDate = this.endDateField.dataSelecionada;
          this._emptySetStateFunction();
        }
    );
  }

  void _emptySetStateFunction(){

    if( this._setterStateOfStatefulBuilder != null){
      this._setterStateOfStatefulBuilder.call(() {});
    }
  }

  void _generateStatefulBuilder() {
    this._stateFullBuilder = new StatefulBuilder(
        builder: (BuildContext contextDialogStatefull, StateSetter setState){
          this._setterStateOfStatefulBuilder = setState;
          this._contextOfStatefulBuilder = contextDialogStatefull;
          return new AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            backgroundColor: Estilos.corDeFundoPrincipal,
            content: this._createDialogContent( contextDialogStatefull ),
          );
        }
    );
  }

  Widget _createDialogContent(BuildContext contextDialogStatefull) {
    this.initializeFields( contextDialogStatefull );
    return new Container(
      height: DIALOG_SIZE,
      child: new Column(
        children: [
          this.beginDateField.getWidget(),
          this.endDateField.getWidget(),
          this._generateButtons( contextDialogStatefull ),
        ],
      ),
    );
  }

  Widget _generateButtons( BuildContext context ){
    String labelButton = ComunsWidgets.getLabel( Labels.button_select );
    return new Row(
      children: [
        SizedBox(
          width: 120.0,
          child: ComunsWidgets.createRaisedButton( labelButton, null, () {
            this.clickedSearchButton( context);
          }),
        ),
      ],
    );
  }

  void clickedSearchButton( BuildContext context ){
    Navigator.of( context ).pop<DateTimeInterval>( new DateTimeInterval(this.beginDate, this.endDate) );
  }

  /// Returns
  Future<DateTimeInterval> showSearchDialog(  ) async {
    DateTimeInterval valor =  await showDialog<DateTimeInterval>(
      context: this._externalContext,
      builder: (BuildContext context) {
        return this._stateFullBuilder;
      },
    );
    return valor;
  }

  
}