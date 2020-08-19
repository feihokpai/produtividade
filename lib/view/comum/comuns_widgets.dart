import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/comum/rotas.dart';

class ComunsWidgets {

  static BuildContext context;
  static bool modoTeste = false;

  static String KEY_STRING_TITULO_PAGINA = "titulo_pagina";
  static String KEY_STRING_BOTAO_SIM_DIALOG = "yesButtonDialog";
  static String KEY_STRING_BOTAO_NAO_DIALOG = "noButtonDialog";

  static Widget criarBarraSuperior() {
    AppBar barraSuperior = new AppBar(
        title: new Text("Registro de Produtividade"),
        centerTitle: true,
        backgroundColor: Estilos.corBarraSuperior);
    return barraSuperior;
  }

  ///     Exibe um Pop-up com o título e descrição passados como parâmetro. Mostra os botões "Sim" e "Não".
  /// Retorna 0 se o usuário clicar fora da janela, 1 se o usuário clicar em sim e 2 se clicar em não.
  static Future<int> exibirDialogConfirmacao( BuildContext context, String titulo, String descricao ) async{
    int valor =  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text( titulo ),
          content: Text( descricao ),
          actions: [
            new  FlatButton(
              key: new ValueKey( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG ),
              child: Text("SIM"),
              onPressed: () => Navigator.of(context).pop( 1 ) ,
            ),
            new  FlatButton(
              key: new ValueKey( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG ),
              child: Text("NÃO"),
              onPressed: () => Navigator.of(context).pop( 2 ),
            )
          ],
        );;
      },
    );
    // Retorna por default valor, mas se ela for nula, retorna 0.
    return valor ?? 0;
  }

  static FutureBuilder<Widget> createFutureBuilderWidget(Future<Widget> widget){
    return FutureBuilder<Widget>(
      future: widget,
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ){
          return snapshot.data;
        }else if ( snapshot.connectionState == ConnectionState.waiting) {
          return new CircularProgressIndicator();
        }else if( snapshot.hasError ){
          String msgErro = "Erro ocorrido: ${snapshot.error}";
          print(msgErro);
          return new Container( child: Text( msgErro, style: Estilos.textStyleListaPaginaInicial, ), );
        }
      },
    );
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
              decoration: BoxDecoration(color: Estilos.corBarraSuperior),
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Registro de Produtividade',
                      style: Estilos.textStyleTituloMenuLateral,
                    ),
                    new Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
                    Text(
                      'Feito por: Amorim Company',
                      style: Estilos.textStyleSubtituloMenuLateral,
                      textAlign: TextAlign.left,
                    ),
                  ])),
          ComunsWidgets.gerarItemMenuDrawer("Tarefas abertas", Icons.message, ComunsWidgets.mudarParaPaginaInicial),
          ComunsWidgets.gerarItemMenuDrawer("Criação de Tarefas", Icons.add, ComunsWidgets.mudarParaPaginaEdicaoDeTarefas),
          ComunsWidgets.gerarItemMenuDrawer("Configurações", Icons.settings, null),
        ],
      ),
    );
  }

  static void sairDoAplicativo() {
    print("clicou em sair");
    SystemNavigator.pop();
  }

  static Future<dynamic> mudarParaPaginaInicial() async{
    Navigator.pushNamed(context, Rotas.LISTAGEM_TAREFA ).then((value) {
      return value;
    });
  }

  static Future<void> mudarParaPaginaEdicaoDeTarefas( {Tarefa tarefa}) {
    if( tarefa == null ) {
      Navigator.pushNamed(context, Rotas.CADASTRO_TAREFA );
    }else{
      Navigator.pushNamed(context, Rotas.EDICAO_TAREFA, arguments: tarefa );
    }
  }

  static Future<dynamic> mudarParaListagemTempoDedicado(Tarefa tarefa) async{
    Navigator.pushNamed(context, Rotas.LISTAGEM_TEMPO, arguments: tarefa).then((value) {
      return value;
    });
  }

  static Future<dynamic> mudarParaEdicaoTempoDedicado(Tarefa tarefa, {TempoDedicado tempo, bool cronometroLigado}) async{
    List<dynamic> argumentos = [tarefa, tempo, cronometroLigado];
    Navigator.pushNamed(context, Rotas.CADASTRO_TEMPO, arguments: argumentos).then((value) {
      return value;
    });
  }
}
