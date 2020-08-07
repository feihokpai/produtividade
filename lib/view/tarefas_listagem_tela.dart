import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

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

  Widget gerarListaViewDasTarefas(){
    List<Tarefa> tarefas = this.controlador.getListaDeTarefas();
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      padding: EdgeInsets.fromLTRB(5, 20, 0, 0),
      itemCount: tarefas.length,
      itemBuilder: (context, indice) {
        Tarefa tarefa = tarefas[indice];
        String strKeyLapis = "${ListaDeTarefasTela.KEY_STRING_ICONE_LAPIS}${tarefa.id}";
        String strKeyRelogio = "${ListaDeTarefasTela.KEY_STRING_ICONE_RELOGIO}${tarefa.id}";
        return new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                children:  <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: new Text(
                      tarefa.nome,
                      style: Estilos.textStyleListaPaginaInicial,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: new IconButton(
                      key: new ValueKey( strKeyLapis ),
                      icon: new Icon(Icons.edit),
                      onPressed: () {
                        this.clicouNoLapis(tarefa);
                      },
                    ),
                  ),
                  new IconButton(
                    key: new ValueKey( strKeyRelogio ),
                    icon: new Icon(Icons.alarm),
                    onPressed: (){
                      this.clicouNoRelogio(tarefa);
                    },
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  Widget gerarConteudoCentral() {

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
            this.gerarListaViewDasTarefas(),
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
         Navigator.of(this.context).pop(true);
         return true;
       }
    });
  }
}
