
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/Validators.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/TimersProdutividade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

enum _Estado{
  MODO_CADASTRO, // Exibindo para cadastro de tempo.
  EDICAO_SEM_ALTERACOES, // Exibe para edição somente a data e hora de início
  EDICAO_COM_ALTERACOES, // Exibe somente a data e hora de início, porém ela foi alterada.
  MODO_EDICAO_COMPLETO, // Exibe além da data/hora de início, a data/hora de fim.
}

class TempoDedicadoEdicaoComponente{
  _Estado estadoAtual = _Estado.MODO_CADASTRO;

  StatefulBuilder stateFullBuilder;
  
  StateSetter _setterStateOfStatefulBuilder;
  BuildContext _contextOfStatefulBuilder;
  State<StatefulWidget> _stateOfStatefulBuilder;

  Tarefa tarefaAtual;
  TempoDedicado tempoDedicadoAtual;
  static DateFormat formatterPadrao = DataHoraUtil.formatterDataHoraBrasileira;
  DateFormat formatter;

  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  CampoDataHora campoDataHoraInicial;
  ChronometerField campoCronometro;
  CampoDataHora campoDataHoraFinal;
  ///     Indica se algum valor editável do componente foi alterado neste último uso. Caso seja true,
  /// será usado para indicar se o registro de tempo deve ser salvo ou não quando o usuário fechar o popup.
  bool algumValorAlterado = false;

  Controlador controlador = new Controlador();
  BuildContext context;

  Orientation _currentOrientation = null;
  bool _orientationChanged = false;

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
    this.stateFullBuilder = this.createStateFullBuilder();
  }

  void _definirEstadoInicial(){
    if( this.tempoDedicadoAtual == null ){
      this.estadoAtual = _Estado.MODO_CADASTRO;
    }else if( this.tempoDedicadoAtual.fim == null){
      this.estadoAtual = _Estado.EDICAO_SEM_ALTERACOES;
    }else{
      this.estadoAtual = _Estado.MODO_EDICAO_COMPLETO;
    }
  }
  
  Widget createStateFullBuilder(){
    return new StatefulBuilder(
      builder: (BuildContext contextDialogStatefull, StateSetter setState){
        this._setterStateOfStatefulBuilder = setState;
        this._contextOfStatefulBuilder = contextDialogStatefull;
        this._stateOfStatefulBuilder = contextDialogStatefull.findAncestorStateOfType();
        return new AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          backgroundColor: Estilos.corDeFundoPrincipal,
          content: this._criarConteudoDialog( contextDialogStatefull ),
        );
      },
    );
  }

  Orientation get currentOrientation => this._currentOrientation;

  void dispose(){
    this._cancelTimerIfActivated();
  }

  void _createTimer(){
    TimersProdutividade.createAPeriodicTimer(this.stateFullBuilder, operation: this._setStateIfOrientationChanged );
  }

  void _cancelTimerIfActivated(){
    TimersProdutividade.cancelAndRemoveTimer( this.stateFullBuilder );
  }

  void set currentOrientation(Orientation currentOrientation){
    this._currentOrientation = currentOrientation;
  }

  ValueKey<String> _criarKey(String keyString){
    return new ValueKey<String>( keyString );
  }

  /// Function used to invoke setState in Statefull Widget where dialog is inside.
  void _emptySetStateFunction(){
    if( this._setterStateOfStatefulBuilder != null && this._isStateFulBuilderMounted() ){
      try {
        this._setterStateOfStatefulBuilder(() {});
      }catch( exception ){
        print("Error ocurred during the call to setState in TempoDedicadoEdicaoComponente: ${exception}");
      }
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
        onChange: this._mudouValorCampoDataHoraInicial,
        dataInicialSelecionada: dataInicial,
    );
  }

  void _mudouValorCampoDataHoraInicial(){
    this.algumValorAlterado = true;
    if( this.campoDataHoraFinal != null ) {
      this.campoDataHoraFinal.dataMinima = this.campoDataHoraInicial.dataSelecionada;
      DateTime finalSelecionada = this.campoDataHoraFinal.dataSelecionada;
      DateTime minima = this.campoDataHoraFinal.dataMinima;
      if( DataHoraUtil.eDataDeDiaAnterior(finalSelecionada, minima) ){
        this.campoDataHoraFinal.dataSelecionada = minima.add( new Duration( minutes: 1 ) );
      }
    }
    if( this.estadoAtual == _Estado.EDICAO_SEM_ALTERACOES ) {
      this.estadoAtual = _Estado.EDICAO_COM_ALTERACOES;
    }
    this._emptySetStateFunction();
  }

  DateTime _definirDataHoraSelecionadaCampoDataHoraFinal(){
    if( this.tempoDedicadoAtual.fim != null){
      return this.tempoDedicadoAtual.fim;
    }
    DateTime inicio = this.campoDataHoraInicial.dataSelecionada;
    DateTime agora = DateTime.now();
    if( DataHoraUtil.eDataMesmoDia(inicio, agora) ) {
      return agora;
    }else{
      DateTime vinteMinutosDepois = inicio.add( new Duration( minutes: 20 ));
      return vinteMinutosDepois;
    }
  }

  void _iniciarCampoDataHoraFinal( ){
    DateTime dataSelecionada = this._definirDataHoraSelecionadaCampoDataHoraFinal();
    this.campoDataHoraFinal ??= new CampoDataHora("Fim", this.context, dataMaxima: new DateTime.now(),
        dataMinima: this.campoDataHoraInicial.dataSelecionada,
        chave: this._criarKey( TempoDedicadoEdicaoComponente.KEY_STRING_CAMPO_HORA_FINAL ),
        dateTimeFormatter: this.formatter,
        onChange: (){
          this.algumValorAlterado = true;
          this._emptySetStateFunction();
        },
        dataInicialSelecionada: dataSelecionada,
    );
  }

  void _checkOrientation(){
    Orientation orientation = MediaQuery.of(context).orientation;
    this._orientationChanged = ( this.currentOrientation != null && orientation != this.currentOrientation );
    if( this.currentOrientation == null || this._orientationChanged ) {
      this.currentOrientation = orientation;
    }
  }

  bool _isStateFulBuilderMounted(){
    return (this._stateOfStatefulBuilder != null && this._stateOfStatefulBuilder.mounted );
  }

  void _setStateIfOrientationChanged(){
    this._checkOrientation();
    if( this._orientationChanged ) {
        this._emptySetStateFunction();
    }
  }

  Widget _criarConteudoDialog( BuildContext contextDialogStatefull ){
    this._iniciarCampoDataHoraInicial( );

    double tamanhoContainer = this.currentOrientation == Orientation.landscape ? 150 : 220;

    return Container(
      height: tamanhoContainer,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: new Text("Preencha a hora em que iniciou a atividade. Deixe como está"
                  " se vai iniciar a atividade agora."),
            ),
            this.returnHoursFields(),
            this._generateSaveFinishAndDeleteButtons(contextDialogStatefull),
          ],
        ),
      ),
    );
  }

  Widget returnHoursFields(){
    if( this.currentOrientation == Orientation.landscape ){
      return new Row(
        children: [
          SizedBox(child: this.campoDataHoraInicial.getWidget(), width: 240, ),
          this._campoHoraFinalOuVazio(),
        ],
      );
    }else{
      return new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: SizedBox(child: this.campoDataHoraInicial.getWidget(), width: 240, ),
            ),
            this._campoHoraFinalOuVazio(),
          ],
        ),
      );
    }
  }

  Widget _campoHoraFinalOuVazio(){
    if( this.estadoAtual == _Estado.MODO_EDICAO_COMPLETO ){
      this._iniciarCampoDataHoraFinal();
      return SizedBox(child: this.campoDataHoraFinal.getWidget(), width: 240, );
    }
    return new Container( height: 0);
  }

  Widget _gerarBotaoEncerrarOuVazio(){
    if( this.estadoAtual == _Estado.EDICAO_SEM_ALTERACOES ||
        this.estadoAtual == _Estado.EDICAO_COM_ALTERACOES) {
      String keyString = TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_ENCERRAR;
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: ComunsWidgets.createRaisedButton("Encerrar", keyString, this._clicouEmEncerrar ),
      );
    }else{
      return new Container();
    }
  }

  Widget _gerarBotaoDeletarOuVazio( BuildContext contextDialogStatefull ){
    if( this.estadoAtual == _Estado.MODO_CADASTRO ){
      return new Container();
    }else{
      String keyStringDeletar = TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_DELETAR;
      Widget botaoDeletar = ComunsWidgets.createRaisedButton("Deletar", keyStringDeletar,
          () => this._clicouEmDeletar( contextDialogStatefull ) );
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: botaoDeletar,
      );
    }
  }

  Future<void> _clicouEmDeletar( BuildContext contextDialogStatefull ) async {
    this._checagemAntesDeDeletar();
    await this.controlador.deletarRegistroTempoDedicado( this.tempoDedicadoAtual );
    Navigator.of( contextDialogStatefull ).pop( 3 );
  }

  void _checagemAntesDeDeletar(){
    if( this.tempoDedicadoAtual == null || this.tempoDedicadoAtual.id == null){
      throw new Exception("Tentou deletar um registro de tempo, mas nenhum foi setado");
    }
  }

  void _clicouEmEncerrar(){
    this.estadoAtual = _Estado.MODO_EDICAO_COMPLETO;
    this.algumValorAlterado = true;
    this._emptySetStateFunction();
  }

  Future<void> _clicouEmSalvar(BuildContext contextDialogStatefull) async {
    String tituloPopup = "Falha ao tentar salvar um registro de tempo";
    this.tryCatch( tituloPopup, () async {
      await this._saveChangedInformation();
    });
  }

  Future<void> tryCatch( String tituloCasoOcorraErro, void Function() operation) async {
    try {
      await operation.call();
    } on ValidationException catch(ex, stackTrace){
      String msg = ex.generateMsgToUser();
      ComunsWidgets.popupDeAlerta( this._contextOfStatefulBuilder, tituloCasoOcorraErro, msg );
    }catch(ex, stackTrace){
      ComunsWidgets.popupDeAlerta( this._contextOfStatefulBuilder, tituloCasoOcorraErro, "Ocorreu"
          " um erro inesperado no aplicativo. Entre em contato com os desenvolvedores para comunicar"
          " esse problema, informando exatamente o que estava fazendo quando o erro ocorreu." );
      print("Erro ao tentar executar uma operação: $ex - ${stackTrace}");
      throw ex;
    }
  }

  Future<bool> _checarPossiveisValoresPreenchidosPorEngano( TempoDedicado tempo ) async {
    if( tempo.fim != null && !DataHoraUtil.eDataMesmoDia(tempo.inicio, tempo.fim) ){
      int quantidadeHoras = tempo.fim.difference(tempo.inicio).inHours;
      String descricao = "Você preencheu as datas com dias diferentes, gerando uma diferença de $quantidadeHoras"
          " horas entre o início e o fim do registro. Tem certeza de que deseja salvar essa informação?";
      BuildContext contextAtual = this._isStateFulBuilderMounted() ? this._contextOfStatefulBuilder : this.context;
      int resposta = await ComunsWidgets.exibirDialogConfirmacao( contextAtual , "Datas de dias diferentes",
          descricao);
      return ( resposta != 1 );
    }
    return false;
  }

  void _setTempoDedicadoComValoresPreenchidos(){
    if( this.algumValorAlterado ) {
      this.tempoDedicadoAtual ??= new TempoDedicado(this.tarefaAtual);
      this.tempoDedicadoAtual.inicio = this.campoDataHoraInicial.dataSelecionada;
      if (this.campoDataHoraFinal != null) {
        this.tempoDedicadoAtual.fim = this.campoDataHoraFinal.dataSelecionada;
      }
    }
  }

  void voltarParaPaginaAnterior(){
    if( this._isStateFulBuilderMounted() ) {
      Navigator.of(this._contextOfStatefulBuilder).pop(1);
    }
  }

  /// If some information in popup was changed saves the values.
  Future<void> _saveChangedInformation() async {
    if( this.algumValorAlterado ) {
      this._setTempoDedicadoComValoresPreenchidos();
      bool houveAlgumEngano = await this._checarPossiveisValoresPreenchidosPorEngano( this.tempoDedicadoAtual );
      if( !houveAlgumEngano ){
        await this.controlador.salvarTempoDedicado( this.tempoDedicadoAtual );
        this._emptySetStateFunction();
        this.voltarParaPaginaAnterior();
      }
    }
  }

  void _clicouEmVoltar( BuildContext contextDialogStatefull ){
    Navigator.of( contextDialogStatefull ).pop( 2 );
  }

  void _resetarVariaveisDeTempoDedicado(){
    this.tempoDedicadoAtual = null;
    this.campoDataHoraInicial = null;
    this.campoDataHoraFinal = null;
    this.algumValorAlterado = false;
  }

  Future<int> exibirDialogConfirmacao( String titulo, TempoDedicado tempo ) async{
    this._resetarVariaveisDeTempoDedicado();
    this.tempoDedicadoAtual = tempo;
    this._definirEstadoInicial();
    this._createTimer();
    int valor =  await showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return this.stateFullBuilder;
      },
    );
    valor = await this._saveTimesIfChangedSomethingUserClickedOutsideAndConfirmYes( valor );
    // Retorna por default valor, mas se ela for nula, retorna 0.
    this._cancelTimerIfActivated();
    return valor ?? 0;
  }

  /// If some value in popup was changed, saves the changes and returns 1. If nothing was changed, don't
  /// save and returns the same value that entered in method.
  Future<int> _saveTimesIfChangedSomethingUserClickedOutsideAndConfirmYes( value ) async{
    if( value == null && this.algumValorAlterado ){
      int resposta = await ComunsWidgets.exibirDialogConfirmacao( this.context, "Você deseja salvar as alterações feitas?", "");
      if( resposta == 1 ) {
        await this._saveChangedInformation();
        return 1;
      }
    }
    return value;
  }

  Widget _generateSaveFinishAndDeleteButtons(BuildContext contextDialogStatefull){
    return Row(
      children: [
        this._generateSaveButtonOrEmpty(contextDialogStatefull),
        this._gerarBotaoEncerrarOuVazio(),
        this._gerarBotaoDeletarOuVazio( contextDialogStatefull ),
      ],
    );
  }

  Widget _generateSaveButtonOrEmpty( BuildContext contextDialogStatefull ) {
    if( this.estadoAtual == _Estado.MODO_EDICAO_COMPLETO ||
        this.estadoAtual == _Estado.EDICAO_COM_ALTERACOES ) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: ComunsWidgets.createRaisedButton("salvar",
            TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_SALVAR,
                () => this._clicouEmSalvar( contextDialogStatefull ),
        )
      );
    }else{
      return Container();
    }
  }

  Widget _generateBackButtonOrEmpty( BuildContext contextDialogStatefull ) {
    if( this.estadoAtual == _Estado.MODO_EDICAO_COMPLETO ) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: ComunsWidgets.createRaisedButton("Sair sem salvar",
            TempoDedicadoEdicaoComponente.KEY_STRING_BOTAO_VOLTAR,
                () => this._clicouEmVoltar(contextDialogStatefull)),
      );
    }else{
      return Container();
    }
  }

}