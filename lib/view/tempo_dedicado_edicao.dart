
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

enum _Estado{
  MODO_CADASTRO, // Exibindo para cadastro de tempo.
  MODO_EDICAO, // Exibe para edição somente a data e hora de início
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
  bool orientationChanged = false;

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
      this.estadoAtual = _Estado.MODO_EDICAO;
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

  void set currentOrientation(Orientation currentOrientation){
    this._currentOrientation = currentOrientation;
    if(this._stateOfStatefulBuilder != null && this._stateOfStatefulBuilder.mounted ) {
      this._emptySetStateFunction();
    }
  }

  ValueKey<String> _criarKey(String keyString){
    return new ValueKey<String>( keyString );
  }

  /// Function used to invoke setState in Statefull Widget where dialog is inside.
  void _emptySetStateFunction(){
    if( this._setterStateOfStatefulBuilder != null ){
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
        onChange: (){
          this.algumValorAlterado = true;
          this._emptySetStateFunction();
        },
        dataInicialSelecionada: dataInicial,
    );
  }

  void _iniciarCampoDataHoraFinal( ){
    DateTime dataSelecionada = this.tempoDedicadoAtual.fim ?? DateTime.now();
    this.campoDataHoraFinal ??= new CampoDataHora("Fim", this.context, dataMaxima: new DateTime.now(),
        dataMinima: this.tempoDedicadoAtual.inicio,
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
    this.orientationChanged = ( this.currentOrientation != null && orientation != this.currentOrientation );
    if( this.currentOrientation == null || this.orientationChanged ) {
      this.currentOrientation = orientation;
    }
  }

  Widget _criarConteudoDialog( BuildContext contextDialogStatefull ){
    this._iniciarCampoDataHoraInicial( );

    this._checkOrientation();
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
            this._generateFinishAndDeleteButtons(contextDialogStatefull),
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
    if( this.estadoAtual == _Estado.MODO_CADASTRO || this.estadoAtual == _Estado.MODO_EDICAO ){
      return new Container( height: 0);
    }else if( this.estadoAtual == _Estado.MODO_EDICAO_COMPLETO ){
      this._iniciarCampoDataHoraFinal();
      return SizedBox(child: this.campoDataHoraFinal.getWidget(), width: 240, );
    }
  }

  Widget _gerarBotaoEncerrarOuVazio(){
    if( this.estadoAtual == _Estado.MODO_EDICAO ) {
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
    await this._saveChangedInformation();
    Navigator.of( contextDialogStatefull ).pop( 1 );
  }

  /// If some information in popup was changed saves the values.
  Future<void> _saveChangedInformation() async {
    if( this.algumValorAlterado ) {
      TempoDedicado tempo = this.tempoDedicadoAtual ??
          new TempoDedicado(this.tarefaAtual);
      tempo.inicio = this.campoDataHoraInicial.dataSelecionada;
      if (this.campoDataHoraFinal != null) {
        tempo.fim = this.campoDataHoraFinal.dataSelecionada;
      }
      await this.controlador.salvarTempoDedicado(tempo);
      this._emptySetStateFunction();
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
    int valor =  await showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return this.stateFullBuilder;
      },
    );
    valor = this._saveTimesIfChangedAndClickedOutside( valor );
    // Retorna por default valor, mas se ela for nula, retorna 0.
    return valor ?? 0;
  }

  /// If some value in popup was changed, saves the changes and returns 1. If nothing was changed, don't
  /// save and returns the same value that entered in method.
  int _saveTimesIfChangedAndClickedOutside( value ){
    if( value == null && this.algumValorAlterado ){
      this._saveChangedInformation();
      return 1;
    }
    return value;
  }

  Widget _generateFinishAndDeleteButtons(BuildContext contextDialogStatefull){
    return Row(
      children: [
        this._generateBackButtonOrEmpty( contextDialogStatefull ),
        this._gerarBotaoEncerrarOuVazio(),
        this._gerarBotaoDeletarOuVazio( contextDialogStatefull ),
      ],
    );
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