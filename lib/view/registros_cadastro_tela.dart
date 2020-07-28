import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';

class CadastroTempoDedicadoTela extends StatefulWidget {

  Tarefa tarefaAtual;

  CadastroTempoDedicadoTela(Tarefa tarefa){
    this.tarefaAtual = tarefa;
  }

  @override
  _CadastroTempoDedicadoTelaState createState() => _CadastroTempoDedicadoTelaState();
}

class _CadastroTempoDedicadoTelaState extends State<CadastroTempoDedicadoTela> {
  @override
  Widget build(BuildContext context) {
    this.inicializarVariaveis();
    return Container();
  }

  void inicializarVariaveis() {
    ComunsWidgets.context = this.context;
  }
}
