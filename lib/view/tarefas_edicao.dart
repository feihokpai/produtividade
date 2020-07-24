import "package:flutter/material.dart";
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

class TarefasEdicaoTela extends StatefulWidget {

  Tarefa tarefaAtual;

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
  _CampoNomeTarefaDefinicao campoNome = new _CampoNomeTarefaDefinicao();
  _CampoDescricaoTarefaDefinicao campoDescricao = new _CampoDescricaoTarefaDefinicao();

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.preencherVariaveisParaEdicao();
    return this.criarHome();
  }

  void preencherVariaveisParaEdicao(){
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
    return new Column(children: <Widget>[
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
                    onPressed: this.pressionouSalvar,
                    child: new Text( "Salvar", style: Estilos.textStyleBotaoFormulario ),
                    color: Colors.blue,),
                ),
                new RaisedButton(
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

  void pressionouVoltar(){
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

class _CampoNomeTarefaDefinicao{

  TextEditingController campoController = new TextEditingController();

  String getText(){
    return this.campoController.text;
  }

  void setText(String valor){
    this.campoController.text = valor;
  }

  Widget getWidget(){
    return new TextFormField( keyboardType: TextInputType.text
        , decoration: new InputDecoration(
            labelText: "Nome da Tarefa:",
            labelStyle: Estilos.textStyleLabelTextFormField,
            border: new OutlineInputBorder()
        ),
        style: Estilos.textStyleListaPaginaInicial,
        controller: this.campoController,
        validator: this.validar
    );
  }

  String validar(String valor){
    if( valor.isEmpty ){
      return "Não pode salvar uma tarefa sem nome";
    }
    if( valor.length > Tarefa.LIMITE_TAMANHO_NOME){
      return "Tamanho ${valor.length}. Máximo permitido ${Tarefa.LIMITE_TAMANHO_NOME} caracteres.";
    }
  }
}


class _CampoDescricaoTarefaDefinicao{

  TextEditingController campoController = new TextEditingController();

  String getText(){
    return this.campoController.text;
  }

  void setText(String valor){
    this.campoController.text = valor;
  }

  Widget getWidget(){
    return new TextFormField(
        maxLines: 6,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
            labelText: "Descrição da Tarefa:",
            labelStyle: Estilos.textStyleLabelTextFormField,
            border: new OutlineInputBorder()
        ),
        style: Estilos.textStyleListaPaginaInicial,
        controller: this.campoController,
        validator: this.validar
    );
  }

  String validar(String valor){
//    if( valor.length > Tarefa.LIMITE_TAMANHO_NOME){
//      return "O nome da tarefa não pode ter mais de 20 caracteres.";
//    }
    // TODO Impleemntar alguma validação
    return null;
  }
}