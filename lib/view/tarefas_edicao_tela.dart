import "package:flutter/material.dart";
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/control/Validators.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/FutureBuilderWithCache.dart';
import 'package:registro_produtividade/view/comum/IntervalDatesChoosingComponent.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/tempo_dedicado_edicao.dart';
import 'package:registro_produtividade/view/tempo_dedicado_listagem.dart';

enum _Estado{
  CADASTRO,
  RELATORIO_VISIVEL,
  EDICAO_VISIVEL,
}


class TarefasEdicaoTela extends StatefulWidget {

  Tarefa tarefaAtual;
  _Estado estadoAtual;

  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "backButton";
  static final String KEY_STRING_BOTAO_DELETAR = "deleteButton";
  static final String KEY_STRING_BOTAO_DETALHES_TEMPOS = "showDetailsButton";
  static final String KEY_STRING_CAMPO_NOME = "nameTextField";
  static final String KEY_STRING_CAMPO_DESCRICAO = "descriptionTextField";

  TarefasEdicaoTela( {Tarefa tarefa} ){
    this.tarefaAtual = tarefa;
    this.defineInitialState();
  }

  @deprecated
  /// Não usar mais. Usar o construtor padrão, em vez dele.
  TarefasEdicaoTela.modoEdicao( Tarefa tarefa ){
    this.tarefaAtual = tarefa;
  }

  @override
  _TarefasEdicaoTelaState createState() => _TarefasEdicaoTelaState();

  void defineInitialState() {
    if( this.tarefaAtual == null ){
      this.estadoAtual = _Estado.CADASTRO;
    }else{
      this.estadoAtual = _Estado.RELATORIO_VISIVEL;
    }
  }
}

class _TarefasEdicaoTelaState extends State<TarefasEdicaoTela> {
  Controlador controlador = new Controlador();

  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  CampoDeTextoWidget campoNome;
  CampoDeTextoWidget campoDescricao;

  ListagemTempoDedicadoComponente listagemDeTempo;
  TempoDedicadoEdicaoComponente edicaoDeTempo;

  IntervalDatesChoosingComponent intervalDateChoosing;

  FutureBuilderWithCache futureBuilderWithCache = new FutureBuilderWithCache<Widget>( chacheOn: true );

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.InicializarVariaveis();
    return this.criarHome();
  }

  bool isSomeValueChanged(){
    String currentName = this.widget.tarefaAtual.nome;
    String currentDescription = this.widget.tarefaAtual.descricao;
    return ( currentName != this.campoNome.getText()
        || currentDescription != this.campoDescricao.getText() );
  }

  String validarCampoNome(String valor) {
    String msg = Tarefa.validarNome( valor );
    return ( msg.length > 0 ? msg : null );
  }

  void InicializarVariaveis(){
    if( this.campoNome == null){
      this.campoNome = new CampoDeTextoWidget("Nome da Tarefa", 1, this.validarCampoNome );
      this.campoNome.setKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME );
    }
    if( this.campoDescricao == null ){
      this.campoDescricao = new CampoDeTextoWidget("Descrição da tarefa", 6, null );
      this.campoDescricao.setKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO );
    }
    if( this.widget.estadoAtual == _Estado.EDICAO_VISIVEL ) {
      this._inicializarTarefa();
    }else if( this.widget.estadoAtual == _Estado.RELATORIO_VISIVEL ) {
      this._inicializarListagemDeTempoDedicado();
      this._inicializarEdicaoDeTempoDedicado();
    }
  }

  void _setStateWithEmptyFunction(){
    this.setState( (){} );
  }

  void _inicializarEdicaoDeTempoDedicado(){
    this.edicaoDeTempo = new TempoDedicadoEdicaoComponente(this.widget.tarefaAtual, context,
      formatter: DataHoraUtil.formatterDataSemAnoHoraBrasileira);
  }

  Future<void> clicouBotaoEditarTempoDedicado( TempoDedicado tempo ) async {
    int resposta = await this.edicaoDeTempo.exibirDialogConfirmacao( "Registro de Tempo Dedicado", tempo );
    if( resposta == 1 || resposta == 3 ){
      this._setStateWithEmptyFunction();
    }
  }

  void _inicializarListagemDeTempoDedicado(){
    this.listagemDeTempo ??= new ListagemTempoDedicadoComponente( this.widget.tarefaAtual, this.context,
        this._setStateWithEmptyFunction,
        this.clicouBotaoEditarTempoDedicado,
        setterState: this.setState,
    );
  }

  void _inicializarTarefa(){
    Tarefa tarefa = this.widget.tarefaAtual;
    this.campoNome.setText( tarefa.nome );
    this.campoDescricao.setText( tarefa.descricao );
  }

  Widget criarHome() {
    Scaffold scaffold1 = new Scaffold(
        appBar: ComunsWidgets.criarBarraSuperior(),
        backgroundColor: Estilos.corDeFundoPrincipal,
        drawer: ComunsWidgets.criarMenuDrawer(),
        body: this.gerarConteudoCentral());
    return scaffold1;
  }

  Widget gerarBotaoDeletar(){
    Widget item = new Padding( padding: const EdgeInsets.all(8.0) );
    if( this.widget.tarefaAtual != null ) {
      item = new Padding(
        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        child: new RaisedButton(
          key: new ValueKey(TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR),
          onPressed: this.pressionouDeletar,
          child: new Text("Deletar", style: Estilos.textStyleBotaoFormulario),
          color: Estilos.corRaisedButton,
        )
      );
    }
    return item;
  }

  Widget gerarConteudoCentral() {
    return new WillPopScope(
      onWillPop: this.clickedInBackButtonFromOS,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: this._gerarTituloDaPagina()
          ),
          this._gerarFormularioEdicaoDaTarefaOuBotaoEditar(),
          this.gerarAreaDeRegistrosDeTempoOuVazio(),
        ]),
      ),
    );
    //Form formulario = new Form( child: coluna, key: this.globalKey );
  }

  Widget _gerarTituloDaPagina(){
    String titulo = "";
    if( this.widget.estadoAtual == _Estado.CADASTRO){
      titulo = "Cadastro de uma nova Tarefa";
    }else if( this.widget.estadoAtual == _Estado.EDICAO_VISIVEL ){
      titulo =  "Edição de uma Tarefa";
    }else if( this.widget.estadoAtual == _Estado.RELATORIO_VISIVEL ){
      titulo =  "Relatórios da Tarefa";
    }
    return new Text( titulo,
        style: Estilos.textStyleListaTituloDaPagina,
        key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) );
  }
  
  Widget _gerarFormularioEdicaoDaTarefaOuBotaoEditar(){
    if( this.widget.estadoAtual == _Estado.EDICAO_VISIVEL || this.widget.estadoAtual == _Estado.CADASTRO ){
      return this._gerarFormularioEdicaoDaTarefa();
    }else if( this.widget.estadoAtual == _Estado.RELATORIO_VISIVEL ){
      return this._gerarBotoesEditarTarefaEVoltar();
    }
  }

  Widget _gerarBotoesEditarTarefaEVoltar(){
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: Padding(
            padding: const EdgeInsets.only( left: 8.0 ),
            child: ComunsWidgets.createRaisedButton("Editar cadastro da tarefa", null, () {
              this.widget.estadoAtual = _Estado.EDICAO_VISIVEL;
              this._setStateWithEmptyFunction();
            }),
          ),
        ),
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ComunsWidgets.createRaisedButton("Voltar", null, () async {
              await this.pressionouVoltar();
            }),
          )
        ),
      ],
    );
  }

  Widget _gerarFormularioEdicaoDaTarefa(){
    return new Form(
      key: this.globalKey,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: this.campoNome.getWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: this.campoDescricao.getWidget(),
          ),
          new Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                    key: new ValueKey( TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR ),
                    onPressed: this.pressionouSalvar,
                    child: new Text( "Salvar", style: Estilos.textStyleBotaoFormulario ),
                    color: Estilos.corRaisedButton,),
                ),
              ),
              Expanded(
                child: new RaisedButton(
                  key: new ValueKey( TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR ),
                  onPressed: this.pressionouVoltar,
                  child: new Text( "Voltar", style: Estilos.textStyleBotaoFormulario ),
                  color: Estilos.corRaisedButton,),
              ),
              Expanded(child: this.gerarBotaoDeletar()),
            ],
          ),
        ],
      ),
    );
  }

  Widget gerarAreaDeRegistrosDeTempoOuVazio(){
    if( this.widget.tarefaAtual != null ){
      return Padding(
        padding: EdgeInsets.fromLTRB(8.0, 40, 8.0, 0),
        child: new Column( children: [
          this.futureBuilderWithCache.generateFutureBuilder( this.exibirBotaoDetalharOuListaDetalhes() ),
        ],)
      );
    }else{
      return new Container();
    }
  }

  Future<Widget> exibirBotaoDetalharOuListaDetalhes() async {
    if( this.widget.estadoAtual == _Estado.EDICAO_VISIVEL ){
      return new RaisedButton(
        key: new ValueKey(TarefasEdicaoTela.KEY_STRING_BOTAO_DETALHES_TEMPOS),
        onPressed: this.pressionouMostrarDetalhes,
        child: new Text("Mostrar registros de tempo detalhados",
            style: Estilos.textStyleBotaoFormulario),
        color: Estilos.corRaisedButton,
      );
    }else if(  this.widget.estadoAtual == _Estado.RELATORIO_VISIVEL  ){
      return Column(
        children: [
          Row(
            children: [
              Expanded( child: await this.listagemDeTempo.gerarCampoDaDuracaoTotal()),
              SizedBox(
                width: 50.0,
                child: ComunsWidgets.createIconButton(Icons.settings, null, () async {
                  await this.clickedInSettingsIcon();
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
            child: await this.listagemDeTempo.gerarListViewDosTempos(),
          ),
        ],
      );
    }else{
      return new Container();
    }
  }

  Future<void> clickedInSettingsIcon() async {
    DateTime begin = this.listagemDeTempo.intervalReport.beginTime;
    DateTime end = this.listagemDeTempo.intervalReport.endTime;
    this.intervalDateChoosing = new IntervalDatesChoosingComponent( begin, end, this.context );
    DateTimeInterval selectedInterval = await this.intervalDateChoosing.showSearchDialog();
    if( selectedInterval != null ) {
      this.listagemDeTempo.intervalReport = selectedInterval;
      this._setStateWithEmptyFunction();
    }
  }

  Future<void> pressionouMostrarDetalhes() async {
    await this._seAlgumValorFoiAlteradoPerguntaSeUsuarioQuerSalvar( () async {
      this.setState(() {
        this.widget.estadoAtual = _Estado.RELATORIO_VISIVEL;
      });
    });
  }

  void resetarVariaveis() {
    this.widget.tarefaAtual = null;
    this.campoNome.setText("");
    this.campoDescricao.setText("");
  }

  void pressionouDeletar() async{
    ComunsWidgets.exibirDialogConfirmacao( this.context , "Tem certeza que deseja deletar essa tarefa?"
        , "Essa ação não pode ser desfeita").then( (resposta) {
      if( resposta == 1  ){
        this.controlador.deletarTarefa( this.widget.tarefaAtual );
        ComunsWidgets.mudarParaPaginaInicial();
      }
    });
  }

  ///    Invoke a Popup asking if the user wants to save the changed data. Is he clicks NO, execute operation()
  /// . If click Yes, walk to the validation step.
  Future<void> askIfUserWantsSavingData( void Function() operation ) async{
    int userAnswer = await ComunsWidgets.exibirDialogConfirmacao(this.context,
        "Deseja salvar as alterações feitas?", "");
    if( userAnswer != 1 ) {
      this._resetChangesInTaskFields();
      operation.call();
      return;
    }
    this._salvarSePassarNaValidacao( operation );
  }

  void _resetChangesInTaskFields(){
    if( this.widget.tarefaAtual != null ){
      this.campoNome.setText( this.widget.tarefaAtual.nome );
      this.campoDescricao.setText( this.widget.tarefaAtual.descricao );
    }
  }

  Future<void> _seAlgumValorFoiAlteradoPerguntaSeUsuarioQuerSalvar( void Function() operation ) async{
    if( !this.isSomeValueChanged() ){
      await operation.call();
      return;
    }
    this.askIfUserWantsSavingData( operation );
  }

  Future<void> pressionouVoltar() async{
    this._seAlgumValorFoiAlteradoPerguntaSeUsuarioQuerSalvar( () async {
      await this.voltarParaPaginaAnterior();
    });
  }

  void _salvarSePassarNaValidacao(  void Function() operation ){
    try{
      if( this.globalKey.currentState.validate() ) {
        Tarefa tarefa = this.widget.tarefaAtual ?? new Tarefa("sem nome", "");
        tarefa.nome = this.campoNome.getText();
        tarefa.descricao = this.campoDescricao.getText();
        this.controlador.salvarTarefa(tarefa);
        operation.call();
      }
    }on ValidationException catch(ex, stackTrace){
      ComunsWidgets.popupDeAlerta(this.context, "Não foi possível salvar.", ex.generateMsgToUser() );
    }catch(ex, stackTrace){
      ComunsWidgets.popupDeAlerta(this.context, "Ocorreu um erro inesperado ao tentar"
          " salvar os dados de uma tarefa.", "");
      print("$ex - ${stackTrace}");
    }
  }

  void pressionouSalvar(){
    this._salvarSePassarNaValidacao( (){
      this.voltarParaPaginaAnterior();
    });
  }

  Future<bool> clickedInBackButtonFromOS() async{
    await this._seAlgumValorFoiAlteradoPerguntaSeUsuarioQuerSalvar(() async {
      await this.voltarParaPaginaAnterior();
      return true;
    });
    return false;
  }

  Future<void> voltarParaPaginaAnterior() async{
    await ComunsWidgets.mudarParaPaginaInicial();
    this.resetarVariaveis();
  }

}

