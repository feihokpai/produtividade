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

class CadastroTempoDedicadoTela extends StatefulWidget {

  Tarefa tarefaAtual;
  LinguagemLabels labels = LabelsApplication.linguaAtual;

  CadastroTempoDedicadoTela(Tarefa tarefa){
    this.tarefaAtual = tarefa;
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
    this.iniciarCronometro();
    this.inicializarCampos();
  }

  void resetarVariaveis(){
    this.widget.tarefaAtual = null;
    this.dataHoraEncerramento = null;
    this.dataInicialSelecionada = null;
  }

  void inicializarCampos(){
    // Se a data estiver nula, será atribuído a ela a data atual
    this.dataInicialSelecionada ??= new DateTime.now();
    String textoCampoInicial = DataHoraUtil.converterDateTimeParaDataHoraBr( this.dataInicialSelecionada );
    this.campoDataHoraInicial = new CampoDataHora("Início", this.context, dataMinima: new DateTime(2020),
        dataMaxima: new DateTime.now(), onChange: (){
          this.setState(() { this.dataInicialSelecionada = this.campoDataHoraInicial.dataSelecionada; });
        }
    );
    this.campoDataHoraInicial.dataSelecionada = this.dataInicialSelecionada;
    this.campoDataHoraFinal = new CampoDataHora("Fim", this.context, dataMaxima: new DateTime.now(),
        dataMinima: this.dataInicialSelecionada, onChange: (){
          this.setState( () { this.dataHoraEncerramento = this.campoDataHoraFinal.dataSelecionada; });
    } );
    this.campoDataHoraFinal.dataSelecionada = this.dataHoraEncerramento;
    this.campoCronometro = new CampoDeTextoWidget("Duração", 1, null, editavel: false);
    this.campoCronometro.setText( "00:00:00" );
  }

  void iniciarCronometro() async{
    // Este IF é necessário na primeira vez que entra aqui e alguns campos podem não ter sido inicializados.
    if( this.dataInicialSelecionada == null ){
      return;
    }
    DateTime dataFinal = this.dataHoraEncerramento ?? new DateTime.now();
    int segundos = dataFinal.difference(this.dataInicialSelecionada).inSeconds;
    String formatada = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration(seconds: segundos));
    if( this.dataHoraEncerramento == null ) {
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
                          child: new RaisedButton(
                            child: new Text("Encerrar", style: Estilos.textStyleBotaoFormulario),
                            color: Colors.blue,
                            onPressed: this.clicouBotaoEncerrar,),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: this.campoDataHoraFinal.getWidget(),
                    ),
                    new RaisedButton(
                      child: new Text("Salvar", style: Estilos.textStyleBotaoFormulario),
                      color: Colors.blue,
                      onPressed: this.salvarTempoDedicado,),
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
    });
  }

  void salvarTempoDedicado(){
    TempoDedicado tempo = new TempoDedicado( this.widget.tarefaAtual, inicio: this.dataInicialSelecionada );
    tempo.fim = this.campoDataHoraFinal.dataSelecionada;
    this.controlador.salvarTempoDedicado( tempo );
    ComunsWidgets.mudarParaTela( new ListaDeTempoDedicadoTela( tempo.tarefa ) ).then((value) {
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
    ComunsWidgets.mudarParaTela( new ListaDeTempoDedicadoTela( this.widget.tarefaAtual ) ).then( (value) {
      return true;
    });
  }
}
