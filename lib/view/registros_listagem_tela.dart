import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';

class ListaDeTempoDedicadoTela extends StatefulWidget {

  Tarefa tarefaAtual;

  static final String KEY_STRING_PAINEL_TAREFA = "tarefaPanel";
  static final String KEY_STRING_BOTAO_NOVO = "newButton";
  static final String KEY_STRING_LISTA_REGISTROS = "listViewRegistros";
  static final String KEY_STRING_REGISTRO = "listViewRegistros";
  static final String KEY_STRING_ICONE_DELETAR = "deleteIcon";

  ListaDeTempoDedicadoTela( Tarefa tarefa ){
    this.tarefaAtual = tarefa;
  }

  @override
  _ListaDeTempoDedicadoTelaState createState() => _ListaDeTempoDedicadoTelaState();
}

class _ListaDeTempoDedicadoTelaState extends State<ListaDeTempoDedicadoTela> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text( "Registros de Tempo Dedicado",
              style: Estilos.textStyleListaTituloDaPagina,
              key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
        ),
        this.gerarCampoDaTarefa(),
        this.gerarListView(),
        new IconButton(
          key: new ValueKey( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO ),
          icon: new Icon(Icons.add, size:50),
          onPressed: this.clicouNoBotaoNovoRegistro,
        ),
      ],
    );
  }

  Widget gerarCampoDaTarefa() {
    return new Text("campo da tarefa");
  }

  Widget gerarListView() {
    return new Text("ListView");
  }

  void clicouNoBotaoNovoRegistro() {

  }
}
