import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';

class ListaDeTarefasTela extends StatefulWidget {

  static String KEY_STRING_ICONE_LAPIS = "lapis";
  static String KEY_STRING_ICONE_RELOGIO = "relogio";

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

  Widget gerarConteudoCentral() {
    List<Tarefa> tarefas = this.controlador.getListaDeTarefas();
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
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
                    onPressed: this.clicouNoRelogio,
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  void clicouNoLapis(Tarefa tarefaParaEditar) {
    print("Clicou no lápis");
    ComunsWidgets.mudarParaPaginaEdicaoDeTarefas(tarefa: tarefaParaEditar);
  }

  void clicouNoRelogio() {
    print("Clicou no relógio");
  }
}
