import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

class ListaDeTempoDedicadoTela extends StatefulWidget {

  Tarefa tarefaAtual;

  static final String KEY_STRING_PAINEL_TAREFA = "tarefaPanel";
  static final String KEY_STRING_BOTAO_NOVO = "newButton";
  static final String KEY_STRING_ICONE_DELETAR = "deleteIcon";
  static final String KEY_STRING_ICONE_EDITAR = "editIcon";
  static final String KEY_STRING_TOTAL_TEMPO = "sumTime";

  static final String TEXTO_SEM_REGISTROS = "Ainda não há registros encerrados";

  ListaDeTempoDedicadoTela( Tarefa tarefa )
      : assert(tarefa != null, "Não pode iniciar a tela de listagem de tempo dedicado com tarefa nula"){
    this.tarefaAtual = tarefa;
  }

  @override
  _ListaDeTempoDedicadoTelaState createState() => _ListaDeTempoDedicadoTelaState();
}

class _ListaDeTempoDedicadoTelaState extends State<ListaDeTempoDedicadoTela> {

  CampoDeTextoWidget campoDescricaoTarefa;
  CampoDeTextoWidget campoDuracaoTotal;

  Controlador controlador = new Controlador();

  @override
  Widget build(BuildContext context) {
    this.inicializarVariaveis();
    return this.criarHome();
  }

  Future<void> inicializarVariaveis() async{
    ComunsWidgets.context = context;
    this.inicializarCampoDeTexto();
    await this.inicializarCampoDuracaoTotal();
  }

  void inicializarCampoDeTexto(){
    if( this.widget.tarefaAtual == null ) {
      return;
    }
    String nome = this.widget.tarefaAtual.nome;
    String descricao = this.widget.tarefaAtual.descricao;
    Key keyString = new ValueKey( ListaDeTempoDedicadoTela.KEY_STRING_PAINEL_TAREFA );
    this.campoDescricaoTarefa = new CampoDeTextoWidget( nome, 4, null, editavel: false, chave: keyString );
    this.campoDescricaoTarefa.setText( descricao );
  }

  Future<void> inicializarCampoDuracaoTotal() async {
    Key keyString = new ValueKey( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
    this.campoDuracaoTotal = new CampoDeTextoWidget("Total de tempo dedicado na tarefa", 1, null,
        editavel: false, chave: keyString );
//    await this.setarTextoCampoDuracaoTotal();
  }

  Future<void> setarTextoCampoDuracaoTotal() async {
    int minutos = await this.controlador.getTotalGastoNaTarefaEmMinutos( this.widget.tarefaAtual );
    String duracaoFormatada = DataHoraUtil.criarStringQtdHorasEMinutos( new Duration(minutes: minutos) );
    if( minutos == 0 ){
      duracaoFormatada = ListaDeTempoDedicadoTela.TEXTO_SEM_REGISTROS;
    }
    this.campoDuracaoTotal.setText( duracaoFormatada );
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
    return new WillPopScope(
      onWillPop: this.voltarParaPaginaAnterior,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text( "Registros de Tempo Dedicado",
                  style: Estilos.textStyleListaTituloDaPagina,
                  key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
            ),
            new FutureBuilder<Widget>(
              future: this.carregarDadosRegistroDaTarefa(),
                builder: (context, snapshot) {
                  if ( snapshot.connectionState == ConnectionState.waiting ) {
                    return Center( child: CircularProgressIndicator() );
                  }else if(  snapshot.connectionState == ConnectionState.done  ){
                    return snapshot.data;
                  }
                }
            ),
            new IconButton(
              key: new ValueKey( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO ),
              icon: new Icon(Icons.add, size:50),
              onPressed: this.clicouNoBotaoNovoRegistro,
            ),
            new Text("Novo Registro", style: Estilos.textStyleListaPaginaInicial,),
          ],
        ),
      ),
    );
  }

  Future<Widget> carregarDadosRegistroDaTarefa() async{
    return new Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: this.gerarCampoDaTarefa(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: await this.gerarCampoDaDuracaoTotal(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 150,
            decoration: new BoxDecoration(
              border: new Border.all(width: 0.5, color: Colors.black, ),
              borderRadius: BorderRadius.circular( 4.0 ),
            ),
            child: await this.gerarListView(),
          ),
        ),
      ],
    );
  }

  Widget gerarCampoDaTarefa() {
    return this.campoDescricaoTarefa.widget;
  }

  Future<Widget> gerarCampoDaDuracaoTotal() async{
    await this.setarTextoCampoDuracaoTotal();
    return this.campoDuracaoTotal.widget;
  }

  String getRegistroTempoDedicadoFormatado(TempoDedicado registro){
    String formatada = "";
    String dataInicio = DataHoraUtil.converterDateTimeParaDataBr( registro.inicio );
    String horaInicio = DataHoraUtil.converterDateTimeParaHoraResumidaBr( registro.inicio );
    formatada += "${dataInicio}: ${horaInicio}";
    if( registro.fim != null) {
      String dataFim = DataHoraUtil.converterDateTimeParaDataBr(registro.fim);
      String horaFim = DataHoraUtil.converterDateTimeParaHoraResumidaBr( registro.fim);
      formatada += " a ${horaFim}";
    }
    return formatada;
  }

  Future<Widget> gerarListView() async {
    List<TempoDedicado> registrosTempo = await this.controlador.getTempoDedicadoOrderByInicio( this.widget.tarefaAtual );
    return new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: registrosTempo.length,
          itemBuilder: (context, indice) {
            TempoDedicado registro = registrosTempo[indice];
            String descricaoRegistro = this.getRegistroTempoDedicadoFormatado( registro );
            String strKeyIconeDelecao = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${registro.id}";
            String strKeyIconeEdicao = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_EDITAR}${registro.id}";
            return Container(
              color: ( (indice % 2 == 0) ? Colors.black26 : Colors.black38 ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: new Row(
                  children:  <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: new Text(
                        descricaoRegistro,
                        style: Estilos.textStyleListaPaginaInicial,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: new IconButton(
                        key: new ValueKey( strKeyIconeEdicao ),
                        icon: new Icon(Icons.edit),
                        onPressed: () {
                          this.clicouNoIconeEdicao(registro);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: new IconButton(
                        key: new ValueKey( strKeyIconeDelecao ),
                        icon: new Icon(Icons.delete),
                        onPressed: () {
                          this.clicouNoIconeDelecao(registro);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  void reiniciarVariaveis(){
    this.widget.tarefaAtual = null;
  }

  void clicouNoBotaoNovoRegistro() async{
    ComunsWidgets.mudarParaEdicaoTempoDedicado( this.widget.tarefaAtual ).then((value) {
      this.reiniciarVariaveis();
    });
  }

  void clicouNoIconeDelecao(TempoDedicado registro) {
    ComunsWidgets.exibirDialogConfirmacao(this.context,
        "Você tem certeza de que deseja deletar esse registro",
        "Essa operação não pode ser revertida.").then( (resposta) {
      if( resposta == 1 ){
        this.setState(() {
          this.controlador.deletarRegistroTempoDedicado( registro );
        });
      }
    });
  }

  void clicouNoIconeEdicao(TempoDedicado registro) {
    ComunsWidgets.mudarParaEdicaoTempoDedicado( registro.tarefa, tempo: registro );
  }

  Future<bool> voltarParaPaginaAnterior() {
    ComunsWidgets.mudarParaPaginaInicial().then((value) {
      this.reiniciarVariaveis();
      return true;
    });
  }

}
