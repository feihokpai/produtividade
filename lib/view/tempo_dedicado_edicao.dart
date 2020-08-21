
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

enum _Estado{
  MODO_CADASTRO, // Exibindo para cadastro de tempo.
  MODO_EDICAO, // Exibe para edição somente a data e hora de início
  MODO_EDICAO_COMPLETO, // Exibe além da data/hora de início, a data/hora de fim.
}

class TempoDedicadoEdicaoComponente{
  _Estado estadoAtual = _Estado.MODO_CADASTRO;

  StateSetter _setStateOfStatefullWidget;

  Tarefa tarefaAtual;
  TempoDedicado tempoDedicadoAtual;
  static DateFormat formatterPadrao = DataHoraUtil.formatterDataHoraBrasileira;
  DateFormat formatter;

  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  CampoDataHora campoDataHoraInicial;
  ChronometerField campoCronometro;
  CampoDataHora campoDataHoraFinal;

  Controlador controlador = new Controlador();
  BuildContext context;

  void Function() onChangeDataHoraInicial;
  void Function() onChangeDataHoraFinal;

  static final String KEY_STRING_CAMPO_HORA_INICIAL = "beginHour";
  static final String KEY_STRING_CAMPO_HORA_FINAL = "endHour";
  static final String KEY_STRING_CAMPO_CRONOMETRO = "timerField";
  static final String KEY_STRING_BOTAO_ENCERRAR = "endButton";
  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "returnButton";
  static final String KEY_STRING_BOTAO_DELETAR = "deleteButton";

  TempoDedicadoEdicaoComponente( Tarefa tarefa, BuildContext context, {TempoDedicado tempoDedicado, DateFormat formatter} )
  :assert(context != null, "Tentou criar componente de edição de Tempo, mas o contexto está nulo"),
   assert(tarefa != null, "Tentou criar componente de edição de Tempo, mas a Tarefa está nula." ){
    this.context = context;
    this.formatter = formatter ?? TempoDedicadoEdicaoComponente.formatterPadrao;
    this.tarefaAtual = tarefa;
    this.tempoDedicadoAtual = tempoDedicado;
    this._definirEstadoInicial();
  }

  void _definirEstadoInicial(){
    if( this.tempoDedicadoAtual == null ){
      this.estadoAtual = _Estado.MODO_CADASTRO;
    }else if( this.tempoDedicadoAtual.fim == null){
      this.estadoAtual = _Estado.MODO_EDICAO;
    }else{
      this.estadoAtual = _Estado.MODO_EDICAO_COMPLETO;
    }
  }

  ValueKey<String> _criarKey(String keyString){
    return new ValueKey<String>( keyString );
  }

  /// Function used to invoke setState in Statefull Widget where dialog is inside.
  void _emptySetStateFunction(){
    if( this._setStateOfStatefullWidget != null ){
      this._setStateOfStatefullWidget( (){  } );
    }
  }

  void _iniciarCampoDataHoraInicial( ){
    DateTime dataInicial = DateTime.now();
    if( this.tempoDedicadoAtual != null ){
      dataInicial = this.tempoDedicadoAtual.inicio;
    }
    String StringKey = TempoDedicadoEdicaoComponente.KEY_STRING_CAMPO_HORA_INICIAL;
    this.campoDataHoraInicial ??= new CampoDataHora("Início", this.context, dataMinima: new DateTime(2020),
        dataMaxima: new DateTime.now(), chave: this._criarKey( StringKey ),
        dateTimeFormatter: this.formatter,
        onChange: this._emptySetStateFunction,
        dataInicialSelecionada: dataInicial,
    );
  }

  void _iniciarCampoDataHoraFinal( ){
    DateTime dataSelecionada = this.tempoDedicadoAtual.fim ?? DateTime.now();
    this.campoDataHoraFinal ??= new CampoDataHora("Fim", this.context, dataMaxima: new DateTime.now(),
        dataMinima: this.tempoDedicadoAtual.inicio,
        chave: this._criarKey( TempoDedicadoEdicaoComponente.KEY_STRING_CAMPO_HORA_FINAL ),
        dateTimeFormatter: this.formatter,
        onChange: this._emptySetStateFunction,
        dataInicialSelecionada: dataSelecionada,
    );
  }

  Widget _criarConteudoDialog( ){
    this._iniciarCampoDataHoraInicial( );
    return SingleChildScrollView(
      child: new Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Text("Preencha a hora em que iniciou a atividade"),
          ),
          this.campoDataHoraInicial.getWidget(),
          this._campoHoraFinalBotaoEncerrarOuVazio(),
        ],
      ),
    );
  }

  Widget _campoHoraFinalBotaoEncerrarOuVazio(){
    if( this.estadoAtual == _Estado.MODO_CADASTRO ){
      return new Container( height: 0);
    }else if( this.estadoAtual == _Estado.MODO_EDICAO ) {
      return new RaisedButton(
        key: this._criarKey( TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_ENCERRAR ),
        child: new Text("Encerrar", style: Estilos.textStyleBotaoFormulario),
        color: Estilos.corRaisedButton,
        onPressed: this._clicouEmEncerrar,
      );
    }else if( this.estadoAtual == _Estado.MODO_EDICAO_COMPLETO ){
      this._iniciarCampoDataHoraFinal();
      return this.campoDataHoraFinal.getWidget();
    }
  }

  void _clicouEmEncerrar(){
    this.estadoAtual = _Estado.MODO_EDICAO_COMPLETO;
    this._emptySetStateFunction();
  }

  void _clicouEmSalvar(){
    TempoDedicado tempo = this.tempoDedicadoAtual ?? new TempoDedicado( this.tarefaAtual );
    tempo.inicio = this.campoDataHoraInicial.dataSelecionada;
    if( this.campoDataHoraFinal != null ){
      tempo.fim = this.campoDataHoraFinal.dataSelecionada;
    }
    this.controlador.salvarTempoDedicado( tempo );
    Navigator.of(context).pop( 1 );
  }

  void _resetarVariaveisDeTempoDedicado(){
    this.tempoDedicadoAtual = null;
    this.campoDataHoraInicial = null;
    this.campoDataHoraFinal = null;
  }

  Future<int> exibirDialogConfirmacao( String titulo, TempoDedicado tempo ) async{
    this._resetarVariaveisDeTempoDedicado();
    this.tempoDedicadoAtual = tempo;
    this._definirEstadoInicial();
    int valor =  await showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            this._setStateOfStatefullWidget = setState;
            return new AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              backgroundColor: Estilos.corDeFundoPrincipal,
              title: Text( titulo ),
              content: this._criarConteudoDialog( ),
              actions: [
                new  FlatButton(
                  color: Estilos.corRaisedButton,
                  key: new ValueKey( TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_SALVAR ),
                  child: Text("Salvar", style: Estilos.textStyleBotaoFormulario),
                  onPressed: this._clicouEmSalvar,
                ),
                new  FlatButton(
                  color: Estilos.corRaisedButton,
                  key: new ValueKey( TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_VOLTAR ),
                  child: Text("Voltar", style: Estilos.textStyleBotaoFormulario,),
                  onPressed: () => Navigator.of(context).pop( 2 ),
                )
              ],
            );
          },
        );;
      },
    );
    // Retorna por default valor, mas se ela for nula, retorna 0.
    return valor ?? 0;
  }
}