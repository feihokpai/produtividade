import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
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

  Map<int, ChronometerField> cronometrosGerados = new Map();
  List<TempoDedicado> temposAtivos = new List();
  List<Tarefa> tarefasParaListar = new List();
  bool recarregarDadosPersistidos = true;
  ///     This variable is important to show again the last result the screen, while the new data
  /// don't arrive. In this way we avoid the blink effect in each 1 second.
  Widget ultimoGridGerado = null;
  Orientation orientacaoAtual = null;
  bool mudouOrientacao = false;
  Controlador controlador = new Controlador();

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.inicializarVariaveis();
    return this.criarHome();
  }


  @override
  void dispose() {
    this.cronometrosGerados.forEach((key, field) {
      field.cancelTimerIfActivated();
    });
    super.dispose();
  }

  void inicializarVariaveis(){

  }
  
  Future<void> inicializarDadosPersistidos() async {
    if( this.recarregarDadosPersistidos ){
      this.tarefasParaListar = await this.controlador.getListaDeTarefas();
      this.temposAtivos = await this.controlador.getTempoDedicadoAtivos();
      recarregarDadosPersistidos = false;
    }
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
    await this.inicializarDadosPersistidos();
    Orientation orientation = MediaQuery.of(context).orientation;
    this.mudouOrientacao = ( orientation != this.orientacaoAtual );
    if( this.mudouOrientacao ){
      this.orientacaoAtual = orientation;
    }
    int qtdColunas = 1;
    if( orientation == Orientation.landscape ){
      qtdColunas = 2;
    }

    StaggeredGridView grid = new StaggeredGridView.countBuilder(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      mainAxisSpacing: 10,
      crossAxisCount: qtdColunas,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: this.tarefasParaListar.length,
      itemBuilder: (BuildContext context, int index){
        return this.gerarRow( this.tarefasParaListar[index] );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
    return await grid;
  }

  FutureBuilder<Widget> createFutureBuilderWidget(Future<Widget> widget){
    return FutureBuilder<Widget>(
      future: widget,
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ){
          this.ultimoGridGerado = snapshot.data;
          return snapshot.data;
        }else if ( snapshot.connectionState == ConnectionState.waiting) {
          if( !mudouOrientacao ) {
            return ultimoGridGerado ?? new CircularProgressIndicator();
          }else {
            return new CircularProgressIndicator();
          }
        }else if( snapshot.hasError ){
          String msgErro = "Erro ocorrido: ${snapshot.error}";
          print(msgErro);
          return new Container( child: Text( msgErro, style: Estilos.textStyleListaPaginaInicial, ), );
        }
      },
    );
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
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: new Text(
                    tarefa.nome,
                    style: Estilos.textStyleListaPaginaInicial,
                  ),
                ),
                this.generateChronometerWidgetIfActive( tarefa ),
              ],
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
            this.createFutureBuilderWidget( this.gerarLayoutDasTarefas() ),
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

  TempoDedicado _verifyTaskIsActive(Tarefa tarefa){
    TempoDedicado resultado = null;
    this.temposAtivos.forEach((tempo) {
      if( tempo.tarefa.id == tarefa.id ){
        resultado = tempo;
      }
    });
    return resultado;
  }

  void _setStateWithEmptyFunction(){
    this.setState( (){} );
  }

  Widget generateChronometerWidgetIfActive(Tarefa tarefa){
    TempoDedicado tempo = this._verifyTaskIsActive( tarefa );
    if( tempo != null ){
      ChronometerField field = this.cronometrosGerados[tarefa.id];
      if( field == null ){
        field = new ChronometerField("Duração", beginTime: tempo.inicio , functionUpdateUI: _setStateWithEmptyFunction );
        this.cronometrosGerados[tarefa.id] = field;
      }
      return Expanded( flex: 4, child: field.widget);
    }else{
      return Expanded( flex: 0,child: new Container());
    }
  }
}
