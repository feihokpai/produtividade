import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:registro_produtividade/view/tempo_dedicado_edicao.dart';
import 'package:registro_produtividade/view/tempo_dedicado_listagem.dart';

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

  TempoDedicadoEdicaoComponente componenteEdicaoDeTempo;

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.inicializarVariaveis();
    return this.criarHome();
  }


  @override
  void dispose() {
    this.cancelAllChronemeters();
    if( this.componenteEdicaoDeTempo != null ){
      this.componenteEdicaoDeTempo.dispose();
    }
    super.dispose();
  }


  void cancelAllChronemeters(){
    this.cronometrosGerados.forEach((key, field) {
      field.cancelTimerIfActivated();
    });
  }
  
  void onScreenExit(){
    this.cancelAllChronemeters();
    this.resetVariables();
  }

  void resetVariables(){
    this.temposAtivos = new List();
    this.tarefasParaListar = new List();
    this.cronometrosGerados.clear();
    this.recarregarDadosPersistidos = true;
    this.ultimoGridGerado = null;
    this.orientacaoAtual = null;
    this.mudouOrientacao = false;
    this.controlador = new Controlador();
  }

  void inicializarVariaveis(){
  }
  
  Future<void> inicializarDadosPersistidos() async {
    if( this.recarregarDadosPersistidos ){
      this.tarefasParaListar = await this.controlador.getListaDeTarefasOrderByDataInicio();
      this.temposAtivos = await this.controlador.getTempoDedicadoAtivos();
      this.desativarTimersDeCronometrosEncerrados();
      recarregarDadosPersistidos = false;
    }
  }

  void desativarTimersDeCronometrosEncerrados(){
    this.tarefasParaListar.forEach((tarefa) {
      this.removeCronometroDaListaECancelaTimer( tarefa );
    });
  }

  Widget criarHome() {
    Scaffold scaffold1 = new Scaffold(
        appBar: ComunsWidgets.criarBarraSuperior(),
        backgroundColor: Estilos.corDeFundoPrincipal,
        drawer: ComunsWidgets.criarMenuDrawer(),
        body: this.gerarConteudoCentral());
    return scaffold1;
  }

  Future<Widget> gerarLayoutDasTarefas() async {
    await this.inicializarDadosPersistidos();
    if( this.tarefasParaListar.isEmpty ){
      return new Container();
    }
    Orientation orientation = MediaQuery.of(context).orientation;
    this.mudouOrientacao = ( this.orientacaoAtual != null && orientation != this.orientacaoAtual );
    this.orientacaoAtual = orientation;
    int qtdColunas = 1;
    if( orientation == Orientation.landscape ){
      qtdColunas = 2;
    }

    StaggeredGridView grid = new StaggeredGridView.countBuilder(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      mainAxisSpacing: 2,
      crossAxisCount: qtdColunas,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: this.tarefasParaListar.length,
      itemBuilder: (BuildContext context, int index){
        return Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: this.gerarRow( this.tarefasParaListar[index] ),
        );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
    return await grid;
  }

  bool algumTimerAtivo(){
    return this.temposAtivos.length > 0;
  }

  FutureBuilder<Widget> createFutureBuilderWidget(Future<Widget> widget){
    return FutureBuilder<Widget>(
      future: widget,
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ){
          if( this.algumTimerAtivo() ) {
            this.ultimoGridGerado = snapshot.data;
          }
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
        }else{
          return Container();
        }
      },
    );
  }

  Widget gerarRow( Tarefa tarefa ){
    String strKeyLapis = "${ListaDeTarefasTela.KEY_STRING_ICONE_LAPIS}${tarefa.id}";
    return Container(
      decoration: new BoxDecoration(
        color: Estilos.corTextFieldEditavel,
        border: new Border.all(width: 0.5, color: Estilos.corBarraSuperior/*Colors.black54*/, style: BorderStyle.solid),//, style: BorderStyle.solid ),
        borderRadius: BorderRadius.circular( 4.0 ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: new Row(
          children:  <Widget>[
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: GestureDetector(
                          onTap: ()=> this.clicouNoNomeDaTarefa(tarefa),
                          child: new Text(
                            tarefa.nome,
                            style: Estilos.textStyleListaPaginaInicial,
                          ),
                        ),
                      ),
                    ),
                    this.generateChronometerWidgetIfActive( tarefa ),
                  ],
                ),
              ),
            ),
            this.generateAlarmIconOrEmpty( tarefa ),
          ],
        ),
      ),
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

  Future<void> clicouNoNomeDaTarefa(Tarefa tarefaParaEditar) async {
    await ComunsWidgets.mudarParaPaginaEdicaoDeTarefas(tarefa: tarefaParaEditar);
    this.onScreenExit();
  }

  Future<void> clicouNoRelogio(Tarefa tarefaParaEditar) async {
    TempoDedicado tempo = new TempoDedicado( tarefaParaEditar, inicio: DateTime.now() );
    await this.controlador.salvarTempoDedicado( tempo );
    this._recarregarDadosDaTela();
  }

  void _recarregarDadosDaTela(){
    this.recarregarDadosPersistidos=true;
    this._setStateWithEmptyFunction();
  }

  Future<void> _exibirComponenteEdicaoDeTempo( Tarefa tarefaParaEditar ) async {
    this.componenteEdicaoDeTempo = new TempoDedicadoEdicaoComponente(tarefaParaEditar, context,
        formatter: DataHoraUtil.formatterDataSemAnoHoraBrasileira);
    TempoDedicado tempo = this._verifyTaskIsActive( tarefaParaEditar.id );
    String titulo = tempo == null ? "Cadastro" : "Edição";
    titulo += " de tempo dedicado";
    int resposta = await this.componenteEdicaoDeTempo.exibirDialogConfirmacao(titulo, tempo);
    if( resposta == 1 || resposta == 3){
      this._recarregarDadosDaTela();
    }
  }

  Future<void> clicouNoIconeAddTarefa() async {
    await ComunsWidgets.mudarParaPaginaEdicaoDeTarefas( );
    this.onScreenExit();
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

  TempoDedicado _verifyTaskIsActive(int idTarefa){
    TempoDedicado resultado = null;
    this.temposAtivos.forEach((tempo) {
      if( tempo.tarefa.id == idTarefa ){
        resultado = tempo;
      }
    });
    return resultado;
  }

  void _setStateWithEmptyFunction(){
    this.setState( (){} );
  }

  Widget generateAlarmIconOrEmpty( Tarefa tarefa ){
    String strKeyRelogio = "${ListaDeTarefasTela.KEY_STRING_ICONE_RELOGIO}${tarefa.id}";
    if( this._verifyTaskIsActive( tarefa.id ) == null ){
      return Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ComunsWidgets.createIconButton(Icons.alarm, strKeyRelogio, () {
            this.clicouNoRelogio(tarefa);
          }),
        ),
      );
    }else{
      return new Container();
    }
  }

  void removeCronometroDaListaECancelaTimer(Tarefa tarefa){
    ChronometerField field = this.getCronometro(tarefa);
    if( field != null ) {
      field.cancelTimerIfActivated();
      this.cronometrosGerados.remove(tarefa.id);
    }
  }

  ChronometerField getCronometro(Tarefa tarefa){
    return this.cronometrosGerados[tarefa.id];
  }

  ChronometerField retornaCronometroAtualizadoDeletaDesatualizado(Tarefa tarefa, TempoDedicado tempo){
    ChronometerField field = this.getCronometro(tarefa);
    if( field == null ){
      return this.gerarNovoCronometro( tempo );
    }
    DateTime inicioCronometro = field.beginTime;
    DateTime inicioAtualizado = tempo.inicio;
    if (inicioAtualizado.difference(inicioCronometro).inMinutes > 0) {
      this.removeCronometroDaListaECancelaTimer( tarefa );
      field = this.gerarNovoCronometro( tempo );
    }
    return field;
  }

  ChronometerField gerarNovoCronometro( TempoDedicado tempo ){
    ChronometerField field = new ChronometerField("Duração", beginTime: tempo.inicio , functionUpdateUI: _setStateWithEmptyFunction );
    this.cronometrosGerados[tempo.tarefa.id] = field;
    return field;
  }

  Widget generateChronometerWidgetIfActive(Tarefa tarefa){
    TempoDedicado tempo = this._verifyTaskIsActive( tarefa.id );
    if( tempo != null ){
      ChronometerField field = this.retornaCronometroAtualizadoDeletaDesatualizado(tarefa, tempo);
      return new LimitedBox(
        child: GestureDetector(
          onTap: ()=> this._exibirComponenteEdicaoDeTempo( tarefa ),
          child: Container(
              child: AbsorbPointer(
                  child: field.widget
              )
          )
        ),
        maxWidth: 85,
      );
    }else{
      return Expanded( flex: 0,child: new Container());
    }
  }
}
