import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/localization/ProdutividadeLocalization.dart';
import 'package:registro_produtividade/view/comum/TimersProdutividade.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/comum/rotas.dart';

class ComunsWidgets {

  static BuildContext context;
  static Locale currentLocale;
  static bool modoTeste = false;

  static String KEY_STRING_TITULO_PAGINA = "titulo_pagina";
  static String KEY_STRING_BOTAO_SIM_DIALOG = "yesButtonDialog";
  static String KEY_STRING_BOTAO_NAO_DIALOG = "noButtonDialog";

  static Widget criarBarraSuperior() {
    AppBar barraSuperior = new AppBar(
        title: new Text("Registro de Produtividade"),
        centerTitle: true,
        backgroundColor: Estilos.corBarraSuperior,
        actions: ComunsWidgets._createActionsAppBar(),
    );
    return barraSuperior;
  }

  static Future<void> changeLanguage(String value) async {
    ComunsWidgets.currentLocale = new Locale( value );
    await ProdutividadeLocalizations.delegate.load( ComunsWidgets.currentLocale );
    await ComunsWidgets.mudarParaPaginaInicial();
    print("Mudou de lingua -> ${value}");
  }

  static String getLabel( String namelabel ){
    return ProdutividadeLocalizations.of( ComunsWidgets.context ).getTranslatedValue( namelabel );
  }

  static List<Widget> _createActionsAppBar(){
    return <Widget>[
      Container(
        width: 90,
        child: new DropdownButton<String>(
          isExpanded: true,
          underline: SizedBox(),
            icon: new Icon(
              Icons.language,
              color: Estilos.corTextoBarraSuperior,
            ),
            items: <DropdownMenuItem<String>>[
              new DropdownMenuItem<String>( value: "pt", child: new Text("Português")),
              new DropdownMenuItem<String>( value: "en", child: new Text("English")),
            ],
            onChanged: ComunsWidgets.changeLanguage,
        ),
      ),
    ];
  }

  static void fecharPopup( BuildContext context, int codigoRetorno ){
    Navigator.of(context).pop( codigoRetorno );
  }

  static List<Widget> definirBotoes( BuildContext context, int qtdBotoes, List<String> nomesBotoes){
    List<Widget> botoes = new List();
    if( nomesBotoes == null ){
      nomesBotoes = <String>[ "Sim", "Não" ];
    }
    for( int i=0; i< qtdBotoes ; i++ ){
      int codigoRetorno = i+1;
      Widget botao = ComunsWidgets.createRaisedButton( nomesBotoes[i] , null, () => fecharPopup(context, codigoRetorno) );
      botoes.add( botao );
    }
    return botoes;
  }

  ///     Exibe um Pop-up com o título e descrição passados como parâmetro. Você pode definir a quantidade
  /// de botões que irão aparecer pelo parâmetro [qtdBotoes] e seus nomes pela lista [nomesBotoes].
  ///     Se deseja apenas mostrar "Sim" e "Não", não atribua valores aos parâmetros [qtdBotoes] e [nomesBotoes].
  /// Retorna 1 se apertar o primeiro botão (posição 0 na lista), 2 para o segundo (posição 1) e
  /// assim sucessivamente.
  static Future<int> exibirDialogConfirmacao( BuildContext context, String titulo, String descricao,
  { int qtdBotoes=2, List<String> nomesBotoes=null }) async{
    List<Widget> botoes = ComunsWidgets.definirBotoes( context, qtdBotoes, nomesBotoes );
    int valor =  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          backgroundColor: Estilos.corDeFundoPrincipal,
          title: Text( titulo ),
          content: Text( descricao ),
          actions: botoes
        );;
      },
    );
    // Retorna por default valor, mas se ela for nula, retorna 0.
    return valor ?? 0;
  }

  static void popupDeAlerta( BuildContext context, String titulo, String descricao ){
    ComunsWidgets.exibirDialogConfirmacao( context, titulo, descricao, qtdBotoes: 1,
        nomesBotoes: <String>["OK"] );
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
              decoration: BoxDecoration(color: Estilos.corMenuLateral),
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
          ComunsWidgets.gerarItemMenuDrawer("Relatórios", Icons.show_chart, ComunsWidgets.mudarParaPaginaDeRelatorios),
        ],
      ),
    );
  }

  static ValueKey<String> createKey(String keyString){
    return new ValueKey<String>( keyString );
  }

  static RaisedButton createRaisedButton(String label, String keyString, void Function() onpressed){
    keyString ??= "RaisedButton_"+( UniqueKey().toString() )+DataHoraUtil.timestampMili();
    return new RaisedButton(
      key: ComunsWidgets.createKey( keyString ),
      child: new Text( label, style: Estilos.textStyleBotaoFormulario),
      color: Estilos.corRaisedButton,
      onPressed: onpressed,
    );
  }
  
  static IconButton createIconButton( IconData iconData, String keyString, void Function() onPressedFunction ){
    keyString ??= "IconButton_${DataHoraUtil.timestampMili()}";
    return new IconButton(
      key: new ValueKey<String>( keyString ),
      icon: new Icon( iconData ),
      onPressed: onPressedFunction,
    );
  }

  static void sairDoAplicativo() {
    print("clicou em sair");
    SystemNavigator.pop();
  }

  static Future<dynamic> mudarParaPaginaInicial() async{
    ComunsWidgets.operationsBeforeChangeScreen();
    Navigator.pushNamed(context, Rotas.LISTAGEM_TAREFA ).then((value) {
      return value;
    });
  }

  static void operationsBeforeChangeScreen(){
    TimersProdutividade.cancelAllTimers();
  }

  static Future<void> mudarParaPaginaEdicaoDeTarefas( {Tarefa tarefa}) {
    ComunsWidgets.operationsBeforeChangeScreen();
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

  static Future<dynamic> mudarParaPaginaDeRelatorios() async{
    dynamic value = Navigator.pushNamed( context, Rotas.RELATORIOS );
    return value;
  }
}
