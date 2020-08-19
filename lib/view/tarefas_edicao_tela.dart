import "package:flutter/material.dart";
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';
import 'package:registro_produtividade/view/tempo_dedicado_edicao.dart';
import 'package:registro_produtividade/view/tempo_dedicado_listagem.dart';

class TarefasEdicaoTela extends StatefulWidget {

  Tarefa tarefaAtual;

  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "backButton";
  static final String KEY_STRING_BOTAO_DELETAR = "deleteButton";
  static final String KEY_STRING_BOTAO_DETALHES_TEMPOS = "showDetailsButton";
  static final String KEY_STRING_CAMPO_NOME = "nameTextField";
  static final String KEY_STRING_CAMPO_DESCRICAO = "descriptionTextField";

  TarefasEdicaoTela( {Tarefa tarefa} ){
    this.tarefaAtual = tarefa;
  }

  @deprecated
  /// Não usar mais. Usar o construtor padrão, em vez dele.
  TarefasEdicaoTela.modoEdicao( Tarefa tarefa ){
    this.tarefaAtual = tarefa;
  }

  @override
  _TarefasEdicaoTelaState createState() => _TarefasEdicaoTelaState();
}

class _TarefasEdicaoTelaState extends State<TarefasEdicaoTela> {
  Controlador controlador = new Controlador();

  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  CampoDeTextoWidget campoNome;
  CampoDeTextoWidget campoDescricao;

  ListagemTempoDedicadoComponente listagemDeTempo;
  TempoDedicadoEdicaoComponente edicaoDeTempo;
  bool exibirDetalhesDeTempo = false;

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.InicializarVariaveis();
    return this.criarHome();
  }

  String validarCampoNome(String valor) {
    String msg = Tarefa.validarNome( valor );
    return ( msg.length > 0 ? msg : null );
  }

  void InicializarVariaveis(){
    this.campoNome = new CampoDeTextoWidget("Nome da Tarefa", 1, this.validarCampoNome );
    this.campoNome.setKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME );
    this.campoDescricao = new CampoDeTextoWidget("Descrição da tarefa", 6, null );
    this.campoDescricao.setKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO );
    if( this.widget.tarefaAtual != null ) {
      this._inicializarTarefa();
      this._inicializarListagemDeTempoDedicado();
      this._inicializarEdicaoDeTempoDedicado();
    }
  }

  void _setStateWithEmptyFunction(){
    this.setState( (){} );
  }

  void _inicializarEdicaoDeTempoDedicado(){
    if( this.widget.tarefaAtual == null ) {
      return;
    }
    this.edicaoDeTempo = new TempoDedicadoEdicaoComponente(this.widget.tarefaAtual, context,
      onChangeDataHoraInicial: this._setStateWithEmptyFunction,
      onChangeDataHoraFinal: this._setStateWithEmptyFunction,
    );
  }

  Future<void> clicouBotaoEditarTempoDedicado( TempoDedicado tempo ) async {
    int resposta = await this.edicaoDeTempo.exibirDialogConfirmacao( "Registro de Tempo Dedicado", tempo );
    this._setStateWithEmptyFunction();
  }

  void _inicializarListagemDeTempoDedicado(){
    this.listagemDeTempo = new ListagemTempoDedicadoComponente( this.widget.tarefaAtual, this.context,
        this._setStateWithEmptyFunction,
        this.clicouBotaoEditarTempoDedicado,
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
        padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
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
    String tituloInicial = (this.widget.tarefaAtual == null) ? "Cadastro de uma nova Tarefa" : "Edição de uma Tarefa";
    return new WillPopScope(
      onWillPop: this.voltarParaPaginaAnterior,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text( tituloInicial,
                style: Estilos.textStyleListaTituloDaPagina,
                key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
          ),
          new Form(
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
          ),
          this.gerarAreaDeRegistrosDeTempoOuVazio(),
        ]),
      ),
    );
    //Form formulario = new Form( child: coluna, key: this.globalKey );
  }

  Widget gerarAreaDeRegistrosDeTempoOuVazio(){
    if( this.widget.tarefaAtual != null ){
      return Padding(
        padding: EdgeInsets.fromLTRB(8.0, 40, 8.0, 0),
        child: new Column( children: [
          ComunsWidgets.createFutureBuilderWidget( this.listagemDeTempo.gerarCampoDaDuracaoTotal() ),
          ComunsWidgets.createFutureBuilderWidget( this.exibirBotaoDetalharOuListaDetalhes() ),
        ],)
      );
    }else{
      return new Container();
    }
  }

  Future<Widget> exibirBotaoDetalharOuListaDetalhes() async {
    if( !this.exibirDetalhesDeTempo ){
      return new RaisedButton(
        key: new ValueKey(TarefasEdicaoTela.KEY_STRING_BOTAO_DETALHES_TEMPOS),
        onPressed: this.pressionouMostrarDetalhes,
        child: new Text("Mostrar registros de tempo detalhados",
            style: Estilos.textStyleBotaoFormulario),
        color: Estilos.corRaisedButton,
      );

    }else{
      return await this.listagemDeTempo.gerarListViewDosTempos();
    }
  }

  void pressionouMostrarDetalhes(){
    this.setState(() {
      this.exibirDetalhesDeTempo = true;
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

  void pressionouVoltar() async{
    ComunsWidgets.mudarParaPaginaInicial().then( (value) {
      this.resetarVariaveis();
    });
  }

  void pressionouSalvar(){
    try{
      if( this.globalKey.currentState.validate() ) {
        Tarefa tarefa = this.widget.tarefaAtual ?? new Tarefa("sem nome", "");
        tarefa.nome = this.campoNome.getText();
        tarefa.descricao = this.campoDescricao.getText();
        this.controlador.salvarTarefa(tarefa);
        ComunsWidgets.mudarParaPaginaInicial();
      }
    }catch(ex){
      print(ex);
    }
  }

  Future<bool> voltarParaPaginaAnterior() {
    ComunsWidgets.mudarParaPaginaInicial().then( (value) {
      this.resetarVariaveis();
      return true;
    });
  }



}

