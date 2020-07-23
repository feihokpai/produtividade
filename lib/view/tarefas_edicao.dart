import "package:flutter/material.dart";
import 'package:registro_produtividade/view/comuns_widgets.dart';

class TarefasEdicaoTela extends StatefulWidget {

  @override
  _TarefasEdicaoTelaState createState() => _TarefasEdicaoTelaState();
}

class _TarefasEdicaoTelaState extends State<TarefasEdicaoTela> {
  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    return this.criarHome();
  }

  Widget criarHome() {
    Scaffold scaffold1 = new Scaffold(
        appBar: ComunsWidgets.criarBarraSuperior(),
        backgroundColor: Colors.grey,
        drawer: ComunsWidgets.criarMenuDrawer()
//        body: this.gerarConteudoCentral()
        );
    return scaffold1;
  }

//  Widget gerarConteudoCentral() {
//
//  }
}
