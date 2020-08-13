import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ListaDeTarefasTela extends StatefulWidget {

  static String KEY_STRING_ICONE_LAPIS = "lapis";
  static String KEY_STRING_ICONE_RELOGIO = "relogio";
  static String KEY_STRING_ICONE_ADD_TAREFA = "add_tarefa";

  @override
  _ListaDeTarefasTelaState createState() => _ListaDeTarefasTelaState();
}

class _ListaDeTarefasTelaState extends State<ListaDeTarefasTela> {
  Controlador controlador = new Controlador();

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

  Future<Widget> gerarLayoutDasTarefas() async {
    Orientation orientation = MediaQuery.of(context).orientation;
    int qtdColunas = 1;
    if( orientation == Orientation.landscape ){
      qtdColunas = 2;
    }

    List<Tarefa> tarefas = await this.controlador.getListaDeTarefas();
    StaggeredGridView grid = new StaggeredGridView.countBuilder(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      crossAxisCount: qtdColunas,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: tarefas.length,
      itemBuilder: (BuildContext context, int index){
        return this.gerarRow( tarefas[index] );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
    return await grid;
  }

  Widget gerarRow( Tarefa tarefa ){
    String strKeyLapis = "${ListaDeTarefasTela.KEY_STRING_ICONE_LAPIS}${tarefa.id}";
    String strKeyRelogio = "${ListaDeTarefasTela.KEY_STRING_ICONE_RELOGIO}${tarefa.id}";
    return new Row(
      children:  <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: new Text(
              tarefa.nome,
              style: Estilos.textStyleListaPaginaInicial,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: new IconButton(
              key: new ValueKey( strKeyLapis ),
              icon: new Icon(Icons.edit),
              onPressed: () {
                this.clicouNoLapis(tarefa);
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: new IconButton(
              key: new ValueKey( strKeyRelogio ),
              icon: new Icon(Icons.alarm),
              onPressed: (){
                this.clicouNoRelogio(tarefa);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> gerarListaViewDasTarefas() async {
    List<Tarefa> tarefas = await this.controlador.getListaDeTarefas();
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      padding: EdgeInsets.fromLTRB(5, 20, 0, 0),
      itemCount: tarefas.length,
      itemBuilder: (context, indice) {
        // Este IF está aqui, porque às vezes, a lista não se atualiza corretamente na estimativa de
        // children. Aí se entrar aqui com um índice maior do que tem, dá erro.
        if( indice > (tarefas.length-1) ){
          return null;
        }
        Tarefa tarefa = tarefas[indice];
        return new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: this.gerarRow( tarefa ),
            )
        );
      },
    );
  }

  Widget gerarConteudoCentral(){

    return WillPopScope(
      onWillPop: pedirConfirmacaoAntesDeFechar,
      child: new SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text( "Tarefas em andamento",
                  style: Estilos.textStyleListaTituloDaPagina,
                  key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
            ),
            FutureBuilder<Widget>(
                future: gerarLayoutDasTarefas(),
                builder: (context, snapshot) {
                  if ( snapshot.connectionState == ConnectionState.waiting) {
                    return new CircularProgressIndicator();
                  }else{
                    return snapshot.data;
                  }
                },
            ),
            new IconButton(
              key: new ValueKey( ListaDeTarefasTela.KEY_STRING_ICONE_ADD_TAREFA ),
              icon: new Icon(Icons.add, size:50),
              onPressed: this.clicouNoIconeAddTarefa,
            ),
          ],
        ),
      ),
    );
  }

  void clicouNoLapis(Tarefa tarefaParaEditar) {
    ComunsWidgets.mudarParaPaginaEdicaoDeTarefas(tarefa: tarefaParaEditar);
  }

  void clicouNoRelogio(Tarefa tarefaParaEditar) {
    ComunsWidgets.mudarParaListagemTempoDedicado( tarefaParaEditar );
  }

  void clicouNoIconeAddTarefa(){
    ComunsWidgets.mudarParaPaginaEdicaoDeTarefas( );
  }

  Future<bool> pedirConfirmacaoAntesDeFechar(){
    ComunsWidgets.exibirDialogConfirmacao(this.context,
        "Você deseja sair do aplicativo?", "").then((resposta) {
       if( resposta == 1 ){
         SystemNavigator.pop();
         return true;
       }
    });
  }
}
