import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComunsWidgets {
  static Widget criarBarraSuperior() {
    AppBar barraSuperior = new AppBar(
        title: new Text("Registro de Produtividade"),
        centerTitle: true,
        backgroundColor: Colors.blue);
    return barraSuperior;
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
          new ListTile(
              title: new Text("Tarefas abertas"),
              leading: new Icon(Icons.message)),
          new ListTile(
              title: new Text("Registro de tempo dedicado"),
              leading: new Icon(Icons.alarm)),
          new ListTile(
              title: new Text("Configurações"),
              leading: new Icon(Icons.settings)),
          new ListTile(
              title: new Text("Sair"),
              leading: new Icon(Icons.add_to_home_screen),
            onTap: (){ ComunsWidgets.sairDoAplicativo(); },
          ),
        ],
      ),
    );
  }

  static void sairDoAplicativo(){
    print("clicou em sair");
    SystemNavigator.pop( );
  }
}
