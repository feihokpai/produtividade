import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/view/OverviewReport.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';
import 'package:registro_produtividade/view/comum/FutureBuilderWithCache.dart';
import 'package:registro_produtividade/view/comum/IntervalDatesChoosingComponent.dart';
import 'package:registro_produtividade/view/comum/Labels.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class ReportsTela extends StatefulWidget {
  @override
  ReportsTelaState createState() => ReportsTelaState();
}

class ReportsTelaState extends State<ReportsTela> {

  static final int OVERVIEW_REPORT = 1;
  DateTimeInterval intervalReport;
  CampoDeTextoWidget intervalReportField;
  int selectedReport = 1;
  bool pesquisaAtivada = false;
  
  Widget _searchResult = new Container();
  FutureBuilderWithCache<Widget> futureBuilder = new FutureBuilderWithCache();


  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.initVariables();
    return this.createHome();
  }

  void initVariables(){
    this.defineReportInterval();
  }

  void defineReportInterval(){
    if( this.intervalReport == null ) {
      DateTime today = DataHoraUtil.resetHourMantainDate(DateTime.now());
      DateTime sevenDaysAgo = today.subtract(new Duration(days: 6));
      this.intervalReport = new DateTimeInterval(sevenDaysAgo, today);
    }
  }

  Widget createHome() {
    Scaffold scaffold1 = new Scaffold(
        appBar: ComunsWidgets.criarBarraSuperior(),
        backgroundColor: Estilos.corDeFundoPrincipal,
        drawer: ComunsWidgets.criarMenuDrawer(),
        body: this.generateCentralContent());
    return scaffold1;
  }

  Widget generateCentralContent() {
    String title =  ComunsWidgets.getLabel( Labels.title_report_screen );
    return new WillPopScope(
      onWillPop: this.returnToTheMainPage,
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text( title,
                    style: Estilos.textStyleListaTituloDaPagina,
                    key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: this.createDropDownButton(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                  child: this.createRowIntervalFieldAndButton(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: this.createSearchButton(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: futureBuilder.generateFutureBuilder( this._doSearch() ),
              ),
            ],
          ),
        ),
    );
  }

  Widget createRowIntervalFieldAndButton(){
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: this.createIntervalReportField()
        ),
        Expanded(
          flex: 2,
          child: ComunsWidgets.createIconButton(Icons.settings, null, () {
            this.showDateChoosingComponent();
          }),
        ),
      ],
    );
  }

  Widget createSearchButton(){
    String labelButton = ComunsWidgets.getLabel( Labels.button_generate_report );
    return ComunsWidgets.createRaisedButton( labelButton, null, () async {
      this.pesquisaAtivada = true;
      this._setStateWithEmptyFunction();
    });
  }

  Future<Widget> _doSearch( ) async {
    if( !this.pesquisaAtivada ){
      return new Container();
    }
    this.pesquisaAtivada = false;
    if( this.selectedReport == OVERVIEW_REPORT ){
      OverviewReport report = new OverviewReport();
      return await report.generateReport( this.intervalReport );
    }
  }

  Future<void> showDateChoosingComponent() async {
    DateTime begin = this.intervalReport.beginTime;
    DateTime end = this.intervalReport.endTime;
    IntervalDatesChoosingComponent popup = new IntervalDatesChoosingComponent( begin, end, this.context );
    DateTimeInterval selectedInterval = await popup.showSearchDialog();
    if( selectedInterval != null ){
      this.intervalReport = selectedInterval;
      this._setStateWithEmptyFunction();
    }
  }

  void _setStateWithEmptyFunction(){
    this.setState(() { });
  }

  void resetVariables(){

  }

  Future<bool> returnToTheMainPage() async {
    await ComunsWidgets.mudarParaPaginaInicial();
    this.resetVariables();
    return true;
  }

  String formatedValueOfInterValReport(){
    DateFormat formatter = ComunsWidgets.linguaDefinidaComoIngles() ?
        DataHoraUtil.formatterDataAmericana : DataHoraUtil.formatterDataBrasileira;
    String begin = formatter.format( this.intervalReport.beginTime );
    String end = formatter.format( this.intervalReport.endTime );
    return "$begin - $end";
  }

  Widget createIntervalReportField(){
    String labelField = ComunsWidgets.getLabel( Labels.label_report_interval_field );
    this.intervalReportField ??= new CampoDeTextoWidget( labelField, 1, null, editavel: false);
    this.intervalReportField.setText( this.formatedValueOfInterValReport() );
    return this.intervalReportField.getWidget();
  }

  Widget createDropDownButton() {
    String nomeRelatorioResumoGeral = ComunsWidgets.getLabel( Labels.summary_report_name );
    return new DropdownButton<int>(
        value: this.selectedReport,
        items: <DropdownMenuItem<int>>[
          new DropdownMenuItem<int>(child: Text(nomeRelatorioResumoGeral), value: OVERVIEW_REPORT,),
        ],
        onChanged: ( selected ){
          this.selectedReport = selected;
          this._setStateWithEmptyFunction();
        });
  }
}
