import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/view/tarefas_edicao.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

class ComunsWidgets {

  static BuildContext context;

  static Widget criarBarraSuperior() {
    AppBar barraSuperior = new AppBar(
        title: new Text("Registro de Produtividade"),
        centerTitle: true,
        backgroundColor: Colors.blue);
    return barraSuperior;
  }

  static Widget gerarItemMenuDrawer(
      String titulo, IconData tipoIcone, Function funcao) {
    return new ListTile(
      title: new Text(titulo),
      leading: new Icon(tipoIcone),
      onTap: funcao,
    );
  }

  static Widget criarMenuDrawer() {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Registro de Produtividade',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    new Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
                    Text(
                      'Feito por: Amorim Company',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ])),
          ComunsWidgets.gerarItemMenuDrawer("Tarefas abertas", Icons.message, ComunsWidgets.mudarParaPaginaInicial),
          ComunsWidgets.gerarItemMenuDrawer("Criação de Tarefas", Icons.add, ComunsWidgets.mudarParaPaginaEdicaoDeTarefas),
          ComunsWidgets.gerarItemMenuDrawer("Registro de tempo dedicado", Icons.alarm, null),
          ComunsWidgets.gerarItemMenuDrawer("Configurações", Icons.settings, null),
          ComunsWidgets.gerarItemMenuDrawer("Sair", Icons.add_to_home_screen, ComunsWidgets.sairDoAplicativo),
        ],
      ),
    );
  }

  static void sairDoAplicativo() {
    print("clicou em sair");
    SystemNavigator.pop();
  }

  static void mudarParaTela( Widget widgetTela ){
    BuildContext contexto = ComunsWidgets.context;
    Navigator.push( contexto , new MaterialPageRoute(builder: (contexto) {
      return widgetTela;
    }));
  }

  static void mudarParaPaginaInicial() {
    ComunsWidgets.mudarParaTela( new ListaDeTarefasTela() );
  }

  static void mudarParaPaginaEdicaoDeTarefas() {
    ComunsWidgets.mudarParaTela( new TarefasEdicaoTela() );
  }
}
