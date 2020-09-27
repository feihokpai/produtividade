import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/Labels.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'dart:ui';

import 'comum/CampoDeTextoWidget.dart';

class ListagemTempoDedicadoComponente{

  static final String KEY_STRING_ICONE_DELETAR = "deleteIcon";
  static final String KEY_STRING_ICONE_EDITAR = "editIcon";
  static final String KEY_STRING_TOTAL_TEMPO = "sumTime";

  CampoDeTextoWidget campoDuracaoTotal;
  BuildContext context;

  Tarefa _tarefaAtual = null;

  void Function() funcaoAposDeletar;
  void Function(TempoDedicado) funcaoParaEditar;

  int _duracaoMinutos = 0;

  /// A variable used to invoke setState() in
  void Function(VoidCallback callback) _externalSetterState;

  ///     To avoid generating a very big screen, only will be showed details of dedicated times about some days.
  /// These ones are the first and others that the user clicked in total sum field to see more
  /// details.
  List<DateTime> _allowedDaysToSeeMoreDetails = new List();
  int amountDaysDetailedInBeginning;
  static const int defaultAmountDaysDetailedInBeginning = 1;
  int maxDaysDetailed;
  static const int defaultMaxDaysDetailed = 2;
  DateTimeInterval _intervalReport;

  Controlador controlador = new Controlador();

  ListagemTempoDedicadoComponente( Tarefa tarefa, BuildContext context, void Function() funcaoAposDeletar,
      void Function(TempoDedicado) funcaoParaEditar,
      {int amountDaysDetailedInBeginning=defaultAmountDaysDetailedInBeginning,
        int maxDaysDetailed = defaultMaxDaysDetailed,
        void Function(VoidCallback callback) setterState
      })
      : assert(tarefa != null, "Tentou gerar componente de listagem de tempo dedicado, mas não repassou"
      "nenhuma Tarefa válida.")
  {
    this._tarefaAtual = tarefa;
    this.context = context;
    this.funcaoAposDeletar = funcaoAposDeletar;
    this.funcaoParaEditar = funcaoParaEditar;
    this.amountDaysDetailedInBeginning = amountDaysDetailedInBeginning;
    this.maxDaysDetailed = maxDaysDetailed;
    this._externalSetterState = setterState;
    this._defineDefaultReport();
    this._inicializarCampoDuracaoTotal();
  }

  void _defineDefaultReport(){
    DateTime now = DateTime.now();
    DateTime sevenDaysBefore = now.subtract( new Duration( days: 6 ) );
    this.intervalReport = new DateTimeInterval( sevenDaysBefore , now );
  }

  DateTimeInterval get intervalReport => this._intervalReport;

  void set intervalReport(DateTimeInterval intervalReport){
    assert( intervalReport != null );
    assert( intervalReport.beginTime != null );
    assert( intervalReport.endTime != null );
    intervalReport.beginTime = DataHoraUtil.resetHourMantainDate( intervalReport.beginTime );
    intervalReport.endTime = DataHoraUtil.resetHourMantainDate( intervalReport.endTime );
    this._intervalReport = intervalReport;
  }

  void _resetVariables(){
    this._allowedDaysToSeeMoreDetails = new List();

  }

  String generateLabelTotalField(){
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ? 
        DataHoraUtil.formatterDataResumidaAmericana : DataHoraUtil.formatterDataResumidaBrasileira;
    String dataInicial = formatter.format( this.intervalReport.beginTime );
    String dataFinal = formatter.format( this.intervalReport.endTime );
    String labelSummaryDataField = ComunsWidgets.getLabel( Labels.label_summary_task_data, parameters: <String>[dataInicial,dataFinal] );
    return labelSummaryDataField;
  }

  void _inicializarCampoDuracaoTotal(){
    Key keyString = new ValueKey( ListagemTempoDedicadoComponente.KEY_STRING_TOTAL_TEMPO );
    String labelCampoTotal = this.generateLabelTotalField();
    this.campoDuracaoTotal = new CampoDeTextoWidget( labelCampoTotal , 1, null,
        editavel: false, chave: keyString );
  }

  String _gerarConteudoCampoResumoGeral( int duracaoEmMinutos ){
    String duracaoTotalFormatada = DataHoraUtil.criarStringQtdHorasEMinutosAbreviados( new Duration(minutes: duracaoEmMinutos) );
    int quantidadeDeDiasDoRelatorio = this.intervalReport.daysAmount();
    double mediaDiariaEmMinutos = duracaoEmMinutos/quantidadeDeDiasDoRelatorio;
    Duration duracao = new Duration( minutes: mediaDiariaEmMinutos.toInt() );
    String duracaoMediaFormatada = DataHoraUtil.criarStringQtdHorasEMinutosAbreviados(duracao);
    return ComunsWidgets.getLabel(
        Labels.content_summary_task_data, parameters: <String>[duracaoTotalFormatada, duracaoMediaFormatada] );
  }

  Future<void> _setarTextoCampoDuracaoTotal() async {
    this._duracaoMinutos = await this.controlador.getTotalGastoNaTarefaEmMinutos( this._tarefaAtual, interval: this.intervalReport );
    String contentField = ComunsWidgets.getLabel( Labels.content_summary_task_no_registers );
    if( this._duracaoMinutos > 0 ){
      contentField = this._gerarConteudoCampoResumoGeral( this._duracaoMinutos );
    }
    this.campoDuracaoTotal.setText( contentField );
  }

  Future<int> get duracaoMinutos async => await this._duracaoMinutos;

  Future<Widget> gerarCampoDaDuracaoTotal() async{
    try {
      this._inicializarCampoDuracaoTotal();
      await this._setarTextoCampoDuracaoTotal();
      return this.campoDuracaoTotal.getWidget();
    }catch( ex, stack){
      print("Erro ao tentar gerar campo de duração total: ${ex} - ${stack}");
    }
  }

  String _getRegistroTempoDedicadoFormatado(TempoDedicado registro){
    String formatada = "";
    String dataInicio = DataHoraUtil.formatterDataResumidaBrasileira.format( registro.inicio );
    String horaInicio = DataHoraUtil.converterDateTimeParaHoraResumidaBr( registro.inicio );
    formatada += "${dataInicio}: ${horaInicio}";
    if( registro.fim != null) {
      String dataFim = DataHoraUtil.converterDateTimeParaDataBr(registro.fim);
      String horaFim = DataHoraUtil.converterDateTimeParaHoraResumidaBr( registro.fim);
      formatada += " a ${horaFim}";
      formatada += " (${registro.getDuracaoEmMinutos()}m)";
    }
    return formatada;
  }

  BoxDecoration gerarBoxDecorationDosItensDaLista(int indice, int qtd){
    int indiceUltimo = qtd-1;
    BorderRadius borderRadius;
    if(indice == 0){
      borderRadius =  BorderRadius.only( topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0) );
    }else if( indice == indiceUltimo ){
      borderRadius = BorderRadius.only( bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0) );
    }else{
      borderRadius = BorderRadius.zero;
    }
    return new BoxDecoration(
        color: ( (indice % 2 == 0) ? Estilos.corListaTipo1 : Estilos.corListaTipo2 ),
        borderRadius: borderRadius
    );
  }

  Future<void> _calcularDuracaoDoDiaESetarCampo( CampoDeTextoWidget fieldDia, Tarefa tarefa, DateTime data ) async {
    int tempoEmMinutos = await this.controlador.getTotalGastoNaTarefaEmMinutosNoDia( tarefa, data );
    Duration duracao = new Duration( minutes:  tempoEmMinutos );
    String horas = duracao.inHours.toString();
    String minutos = DataHoraUtil.restoDaDuracaoEmMinutos( duracao ).toString();
    String duracaoFormatada = ComunsWidgets.getLabel(
        Labels.content_summary_task_data_day, parameters: <String>[horas, minutos] );
    fieldDia.setText( duracaoFormatada );
  }

  Future<Widget> _gerarCampoSomatorioDoDia(TempoDedicado tempo) async {
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ?
        DataHoraUtil.formatterDataAmericana : DataHoraUtil.formatterDataBrasileira;
    String dataFormatada = formatter.format( tempo.inicio );
    ValueKey<String> key = ComunsWidgets.createKey( "TextField_day${tempo.inicio.day}" );
    String labelFieldDia = ComunsWidgets.getLabel(
        Labels.label_summary_task_data_day, parameters: <String>[dataFormatada] );
    CampoDeTextoWidget fieldDia = new CampoDeTextoWidget( labelFieldDia, 1, null, editavel: false, chave: key );
    this._calcularDuracaoDoDiaESetarCampo( fieldDia, tempo.tarefa, tempo.inicio );

    return new Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: GestureDetector(
        onTap: ()=> this.addDayToSeeMoreDetails( tempo.inicio ),
        child: AbsorbPointer(
            child: fieldDia.getWidget()
        )
      ),
    );
  }

  Future<List<Widget>> gerarWidgetsDaListagem() async {
    List<Widget> lista = new List();
    List<TempoDedicado> registrosTempo =
        await this.controlador.getTempoDedicadoOrderByInicio( this._tarefaAtual, interval: this.intervalReport );
    int diaAnterior = 0;
    int qtdDiasJaMostrados = 0;
    for( int i=0; i< registrosTempo.length; i++ ){
      TempoDedicado tempo = registrosTempo[i];
      if( tempo.inicio.day != diaAnterior ){
        Widget field = await this._gerarCampoSomatorioDoDia( tempo );
        lista.add( field );
        qtdDiasJaMostrados++;
      }
      int qtdPermitidaNoInicio = this.amountDaysDetailedInBeginning;
      if( qtdDiasJaMostrados <= qtdPermitidaNoInicio || this._isAnAllowedDayToShow( tempo.inicio) ) {
        lista.add(this.gerarLinhaDeTempo(tempo, i, registrosTempo.length));
      }
      diaAnterior = tempo.inicio.day;
    }
    return lista;
  }

  Future<Widget> gerarListViewDosTempos() async {
    return Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 1.0, color: Colors.black54, style: BorderStyle.solid),//, style: BorderStyle.solid ),
        borderRadius: BorderRadius.circular( 4.0 ),
//        borderRadius: BorderRadius.only(topRight:  Radius.circular(40)),
      ),
      child: new Column(
        children: await this.gerarWidgetsDaListagem(),
      ),
    );
  }


  Widget gerarLinhaDeTempo(TempoDedicado registro, int indice, int qtdRegistros){
    String strKeyIconeDelecao = "${ListagemTempoDedicadoComponente.KEY_STRING_ICONE_DELETAR}${registro.id}";
    String strKeyIconeEdicao = "${ListagemTempoDedicadoComponente.KEY_STRING_ICONE_EDITAR}${registro.id}";
    String descricaoRegistro = this._getRegistroTempoDedicadoFormatado( registro );
    return Container(
      decoration: this.gerarBoxDecorationDosItensDaLista(indice, qtdRegistros),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: new Row(
          children:  <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: new Text(
                descricaoRegistro,
                style: Estilos.textStyleListaPaginaInicial,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ComunsWidgets.createIconButton(Icons.edit, strKeyIconeEdicao, () {
                this._clicouNoIconeEdicao(registro);
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ComunsWidgets.createIconButton(Icons.delete, strKeyIconeDelecao, () {
                this._clicouNoIconeDelecao(registro);
              }),
            ),
          ],
        )
      ),
    );
  }

  void _clicouNoIconeDelecao(TempoDedicado registro) {
    ComunsWidgets.exibirDialogConfirmacao(this.context,
        "Você tem certeza de que deseja deletar esse registro",
        "Essa operação não pode ser revertida.").then( (resposta) async {
      if( resposta == 1 ){
        await this.controlador.deletarRegistroTempoDedicado( registro );
        if( this.funcaoAposDeletar != null ){
          this.funcaoAposDeletar.call();
        }
      }
    });
  }

  void _clicouNoIconeEdicao(TempoDedicado registro) {
    this.funcaoParaEditar.call( registro );
  }

  bool _isAnAllowedDayToShow(DateTime dateTime){
    bool isInserted = false;
    this._allowedDaysToSeeMoreDetails.forEach(( dateTimeAllowed) {
      if( DataHoraUtil.eDataMesmoDia( dateTime, dateTimeAllowed ) ){
        isInserted = true;
        return;
      }
    });
    return isInserted;
  }

  void _setStateWithEmptyFunction(){
    if( this._externalSetterState != null ) {
      this._externalSetterState.call( () {} );
    }
  }

  void addDayToSeeMoreDetails( DateTime dateTime ){
    int maxAllowed = this.maxDaysDetailed - this.amountDaysDetailedInBeginning;
    dateTime = DataHoraUtil.resetHourMantainDate( dateTime );
    if( !this._isAnAllowedDayToShow( dateTime ) ) {
      this._allowedDaysToSeeMoreDetails.add( dateTime );
      if( this._allowedDaysToSeeMoreDetails.length > maxAllowed ){
        this._allowedDaysToSeeMoreDetails.removeAt( 0 );
      }
    }else{
      this._allowedDaysToSeeMoreDetails.remove( dateTime );
    }
    this._setStateWithEmptyFunction();
  }

}