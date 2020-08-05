import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/LabelsApplication.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';

import 'package:intl/intl.dart';

enum _Estado{
  MODO1, // Exibindo para cadastro de tempo. Ainda não encerrado.
  MODO2, // Exibindo para cadastro de tempo. Encerrado, mas ainda não salvo.
  MODO3, // Exibindo para edição de tempo. Ainda não encerrado.
  MODO4, // Exibindo para edição de tempo. Encerrado e já salvo antes.
}

class CadastroTempoDedicadoTela extends StatefulWidget {

  _Estado estadoAtual = _Estado.MODO1;

  Tarefa tarefaAtual;
  TempoDedicado tempoDedicadoAtual;
  // Em alguns casos é útil por questões de testes de widget manter desligado o cronômetro
  bool cronometroLigado;
  LinguagemLabels labels = LabelsApplication.linguaAtual;
  static DateFormat formatterDataHora = DataHoraUtil.formatterDataHoraBrasileira;

  static final String KEY_STRING_CAMPO_HORA_INICIAL = "beginHour";
  static final String KEY_STRING_CAMPO_HORA_FINAL = "endHour";
  static final String KEY_STRING_CAMPO_CRONOMETRO = "timerField";
  static final String KEY_STRING_BOTAO_ENCERRAR = "endButton";
  static final String KEY_STRING_BOTAO_SALVAR = "saveButton";
  static final String KEY_STRING_BOTAO_VOLTAR = "returnButton";
  static final String KEY_STRING_BOTAO_DELETAR = "deleteButton";

  CadastroTempoDedicadoTela(Tarefa tarefa, {TempoDedicado tempoDedicado, bool cronometroLigado}){
    this.tarefaAtual = tarefa;
    this.tempoDedicadoAtual = tempoDedicado;
    this.cronometroLigado = cronometroLigado ?? (!ComunsWidgets.modoTeste);
  }

  @override
  _CadastroTempoDedicadoTelaState createState() => _CadastroTempoDedicadoTelaState();
}

class _CadastroTempoDedicadoTelaState extends State<CadastroTempoDedicadoTela> {

  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  CampoDataHora campoDataHoraInicial;
  CampoDeTextoWidget campoCronometro;
  CampoDataHora campoDataHoraFinal;

  DateTime dataInicialSelecionada;
  DateTime dataHoraEncerramento;
  Controlador controlador = new Controlador();

  @override
  Widget build(BuildContext context) {
    this.inicializarVariaveis();
    return this.criarHome();
  }

  void inicializarVariaveis() async{
    ComunsWidgets.context = this.context;
    this.inicializarCampos();
    this.iniciarCronometro();
  }

  void resetarVariaveis(){
    this.widget.tarefaAtual = null;
    this.dataHoraEncerramento = null;
    this.dataInicialSelecionada = null;
  }

  void inicializarCampos(){
    this.iniciarCampoDataHoraInicial();
    this.iniciarCampoCronometro();
    this.iniciarCampoDataHoraFinal();
  }

  ValueKey<String> criarKey(String keyString){
    return new ValueKey<String>( keyString );
  }

  void iniciarCampoCronometro(){
    Key chave = this.criarKey(CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO);
    this.campoCronometro = new CampoDeTextoWidget("Duração", 1, null, editavel: false, chave: chave );
    this.campoCronometro.setText( "00:00:00" );
  }

  void iniciarCampoDataHoraInicial(){
    // Se a data estiver nula, será atribuído a ela a data atual
    this.dataInicialSelecionada ??= new DateTime.now();
    String textoCampoInicial = DataHoraUtil.converterDateTimeParaDataHoraBr( this.dataInicialSelecionada );
    String StringKey = CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL;
    this.campoDataHoraInicial = new CampoDataHora("Início", this.context, dataMinima: new DateTime(2020),
        dataMaxima: new DateTime.now(), chave: new ValueKey( StringKey ),
        dateTimeFormatter: CadastroTempoDedicadoTela.formatterDataHora,
        onChange: (){
          this.setState(() { this.dataInicialSelecionada = this.campoDataHoraInicial.dataSelecionada; });
        }
    );
    this.campoDataHoraInicial.dataSelecionada = this.dataInicialSelecionada;
  }

  void iniciarCampoDataHoraFinal(){
    this.campoDataHoraFinal = new CampoDataHora("Fim", this.context, dataMaxima: new DateTime.now(),
        dataMinima: this.dataInicialSelecionada,
        chave: this.criarKey( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL ),
        dateTimeFormatter: CadastroTempoDedicadoTela.formatterDataHora,
        onChange: (){
          this.setState( () { this.dataHoraEncerramento = this.campoDataHoraFinal.dataSelecionada; });
        } );
    this.campoDataHoraFinal.dataSelecionada = this.dataHoraEncerramento;
  }

  void iniciarCronometro() async{
    // Este IF é necessário na primeira vez que entra aqui e alguns campos podem não ter sido inicializados.
    if( this.dataInicialSelecionada == null ){
      return;
    }
    DateTime dataFinal = this.dataHoraEncerramento ?? new DateTime.now();
    int segundos = dataFinal.difference(this.dataInicialSelecionada).inSeconds;
    String formatada = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration(seconds: segundos));
    if( !this.cronometroInativo() && !this.cronometroEncerrado() ) {
      Future.delayed(Duration(seconds: 1), () {
        this.campoCronometro.setText(formatada);
      }).then((value) {
        this.iniciarCronometro();
      });
    }else{
      this.campoCronometro.setText(formatada);
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

  Widget gerarConteudoCentral() {
    String tituloInicial = "Registro de Tempo dedicado";
    return new WillPopScope(
      onWillPop: this.voltarParaPaginaAnterior,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text( tituloInicial,
                    style: Estilos.textStyleListaTituloDaPagina,
                    key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
              ),
              new Form(
                key: this.globalKey,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: this.campoDataHoraInicial.getWidget()
                    ),
                    new Row(
                      children: <Widget>[
                        Expanded(
                          child: this.campoCronometro.getWidget(),
                        ),
                        Expanded(
                          child: new Container(),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: this.gerarBotaoEncerrar(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: this.gerarBotaoVoltar(),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: new Container(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: this.getCampoHoraFinalSeCronometroEncerrado(),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(child: this.getBotaoSalvarSeCronometroEncerrado()),
                        Expanded(child: this.getBotaoDeletarSeCronometroEncerrado()),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
    //Form formulario = new Form( child: coluna, key: this.globalKey );


  }

  void clicouBotaoEncerrar(){
    this.setState(() {
      this.dataHoraEncerramento = new DateTime.now();
      this.widget.estadoAtual = _Estado.MODO2;
    });
  }

  void salvarTempoDedicado(){
    TempoDedicado tempo = new TempoDedicado( this.widget.tarefaAtual, inicio: this.dataInicialSelecionada );
    tempo.fim = this.campoDataHoraFinal.dataSelecionada;
    this.controlador.salvarTempoDedicado( tempo );
    ComunsWidgets.mudarParaListagemTempoDedicado( tempo.tarefa ).then((value) {
      this.resetarVariaveis();
    });
  }

  void exibirCalendario() async {
    showDatePicker(context: this.context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1980),
        lastDate: new DateTime.now()).then((selecionada) {
      this.setState(() {
        //this.dataInicialSelecionada = selecionada;
        this.dataInicialSelecionada = new DateTime( selecionada.year,
            selecionada.month, selecionada.day, this.dataInicialSelecionada.hour,
            this.dataInicialSelecionada.minute, this.dataInicialSelecionada.second
        );
      });
    });
  }
  void exibirRelogio() async{
    showTimePicker(context: this.context, initialTime: new TimeOfDay.now() ).then((value) {
      TimeOfDay hora = value;
      this.setState(() {
        this.dataInicialSelecionada = new DateTime( this.dataInicialSelecionada.year,
            this.dataInicialSelecionada.month, this.dataInicialSelecionada.day,
            hora.hour,hora.minute, 0
        );
      });
    });
  }

  Future<bool> voltarParaPaginaAnterior(){
    ComunsWidgets.mudarParaListagemTempoDedicado( this.widget.tarefaAtual ).then( (value) {
      return true;
    });
  }

  bool cronometroInativo(){
    return !this.widget.cronometroLigado;
  }

  bool cronometroEncerrado(){
    return this.dataHoraEncerramento != null;
  }

  Widget getCampoHoraFinalSeCronometroEncerrado() {
    if( this.cronometroEncerrado() ){
      return this.campoDataHoraFinal.getWidget();
    }else{
      return new Container();
    }
  }

  Widget getBotaoSalvarSeCronometroEncerrado() {
    if( !this.cronometroEncerrado() ){
      return new Container();
    }else{
      return new  RaisedButton(
        key: this.criarKey( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR ),
        child: new Text("Salvar", style: Estilos.textStyleBotaoFormulario),
        color: Colors.blue,
        onPressed: this.salvarTempoDedicado,
      );
    }
  }

  void clicouBotaoVoltar() {
    ComunsWidgets.exibirDialogConfirmacao(context, "Voltando...",
        "Voltando para a tela anterior, o tempo continuará contando até que você encerre "
            "ou delete o registro. Deseja continuar?").then((resposta) {
              if( resposta == 1 ){
                this.salvarTempoDedicado();
//                ComunsWidgets.mudarParaTela( new ListaDeTempoDedicadoTela( this.widget.tarefaAtual ) ).then((value) {
//                  this.resetarVariaveis();
//                });
              }
    });
  }

  Widget gerarBotaoEncerrar() {
    if( this.widget.estadoAtual == _Estado.MODO1 || this.widget.estadoAtual == _Estado.MODO3 ) {
      return new RaisedButton(
        key: this.criarKey(CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR),
        child: new Text("Encerrar", style: Estilos.textStyleBotaoFormulario),
        color: Colors.blue,
        onPressed: this.clicouBotaoEncerrar,
      );
    }else{
      return new Container();
    }
  }

  Widget gerarBotaoVoltar() {
    if( this.widget.estadoAtual == _Estado.MODO1 || this.widget.estadoAtual == _Estado.MODO3 ) {
      return new RaisedButton(
        key: this.criarKey( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR ),
        child: new Text("Voltar", style: Estilos.textStyleBotaoFormulario),
        color: Colors.blue,
        onPressed: this.clicouBotaoVoltar
      );
    }else{
      return new Container();
    }
  }

  Widget getBotaoDeletarSeCronometroEncerrado() {
    if( this.widget.estadoAtual == _Estado.MODO2 || this.widget.estadoAtual == _Estado.MODO4 ) {
      return new RaisedButton(
          key: this.criarKey( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR ),
          child: new Text("Deletar", style: Estilos.textStyleBotaoFormulario),
          color: Colors.blue,
          onPressed: this.clicouBotaoDeletar
      );
    }else{
      return new Container();
    }
  }

  void clicouBotaoDeletar() {
    ComunsWidgets.exibirDialogConfirmacao(context, "Deletando...",
        "Tem certeza que deseja deletar esse registro?").then((resposta) {
      if( resposta == 1 ){
        ComunsWidgets.mudarParaListagemTempoDedicado( this.widget.tarefaAtual ).then((value) {
          this.resetarVariaveis();
        });
      }
    });
  }
}
