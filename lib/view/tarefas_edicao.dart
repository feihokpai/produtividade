import "package:flutter/material.dart";
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

class TarefasEdicaoTela extends StatefulWidget {

  Tarefa tarefaAtual;

  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "backButton";
  static final String KEY_STRING_BOTAO_DELETAR = "deleteButton";
  static final String KEY_STRING_CAMPO_NOME = "nameTextField";
  static final String KEY_STRING_CAMPO_DESCRICAO = "descriptionTextField";

  TarefasEdicaoTela();

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
    this._inicializarTarefa();
  }

  void _inicializarTarefa(){
    Tarefa tarefa = this.widget.tarefaAtual;
    if( tarefa != null ){
      this.campoNome.setText( tarefa.nome );
      this.campoDescricao.setText( tarefa.descricao );
    }
  }

  Widget criarHome() {
    Scaffold scaffold1 = new Scaffold(
        appBar: ComunsWidgets.criarBarraSuperior(),
        backgroundColor: Colors.grey,
        drawer: ComunsWidgets.criarMenuDrawer(),
        body: this.gerarConteudoCentral());
    return scaffold1;
  }

  Widget gerarConteudoCentral() {
    String tituloInicial = (this.widget.tarefaAtual == null) ? "Cadastro de uma nova Tarefa" : "Edição de uma Tarefa";
    return new Column(children: <Widget>[
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                    key: new ValueKey( TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR ),
                    onPressed: this.pressionouSalvar,
                    child: new Text( "Salvar", style: Estilos.textStyleBotaoFormulario ),
                    color: Colors.blue,),
                ),
                new RaisedButton(
                  key: new ValueKey( TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR ),
                  onPressed: this.pressionouVoltar,
                  child: new Text( "Voltar", style: Estilos.textStyleBotaoFormulario ),
                  color: Colors.blue,),
              ],
            ),
          ],
        ),
      ),
    ]);
    //Form formulario = new Form( child: coluna, key: this.globalKey );
  }

  void resetarVariaveis() {
    this.widget.tarefaAtual = null;
    this.campoNome.setText("");
    this.campoDescricao.setText("");
  }

  void pressionouVoltar(){
    this.resetarVariaveis();
    ComunsWidgets.mudarParaPaginaInicial();
  }

  void pressionouSalvar(){
    //##########################################################################
    print("pressionou salvar");
    //##########################################################################
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



}

