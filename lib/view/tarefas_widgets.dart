import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/estilos.dart';

class ListaDeTarefasTela extends StatefulWidget {
  @override
  _ListaDeTarefasTelaState createState() => _ListaDeTarefasTelaState();
}

class _ListaDeTarefasTelaState extends State<ListaDeTarefasTela> {

  Controlador controlador = new Controlador();

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.fromLTRB(5, 20, 0, 0),
      itemCount: tarefas.length,
      itemBuilder: (context, indice) {
        Tarefa tarefa = tarefas[ indice ];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: new Text(
                  tarefa.nome, style: Estilos.textStyleListaPaginaInicial,)
                ,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: new IconButton(
                  icon: new Icon(Icons.edit),
                  onPressed: this.clicouNoLapis,
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.alarm),
                onPressed: this.clicouNoRelogio,
              ),
            ],
          ),
        );
      },
    );
  }

  void clicouNoLapis() {
    print("Clicou no lápis");
  }

  void clicouNoRelogio() {
    print("Clicou no relógio");
  }

}
