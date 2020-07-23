import "package:flutter/material.dart";
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';

class TarefasEdicaoTela extends StatefulWidget {
  @override
  _TarefasEdicaoTelaState createState() => _TarefasEdicaoTelaState();
}

class _TarefasEdicaoTelaState extends State<TarefasEdicaoTela> {
  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  _CampoNomeTarefaDefinicao campoNome = new _CampoNomeTarefaDefinicao();
  _CampoDescricaoTarefaDefinicao campoDescricao = new _CampoDescricaoTarefaDefinicao();


  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    return this.criarHome();
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
    Column coluna = new Column(children: <Widget>[
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RaisedButton(
                onPressed: this.pressionouSalvar,
                child: new Text( "Salvar", style: Estilos.textStyleBotaoFormulario ),
                color: Colors.blue,),
            ),
          ],
        ),
      ),
    ]);
    //Form formulario = new Form( child: coluna, key: this.globalKey );
    return coluna;
  }

  void pressionouSalvar(){
    //##########################################################################
    print("pressionou salvar");
    //##########################################################################
  }

}

class _CampoNomeTarefaDefinicao{

  TextEditingController campoController = new TextEditingController();

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
      return "O nome da tarefa não pode ter mais de 20 caracteres.";
    }
  }
}


class _CampoDescricaoTarefaDefinicao{

  TextEditingController campoController = new TextEditingController();

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