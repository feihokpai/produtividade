import 'dart:async';

import 'package:flutter/material.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/TimersProdutividade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class FakeScreenTestChronometerField extends StatefulWidget {

  static String KEY_STRING_FIELD_CHRONOMETER = "Chronometer";
  static String KEY_STRING_BUTTON_START_STOP = "buttonStartStop";

  ChronometerField chronometerFieldReference=null;

  @override
  _FakeScreenTestChronometerFieldState createState() => _FakeScreenTestChronometerFieldState();
}

class _FakeScreenTestChronometerFieldState extends State<FakeScreenTestChronometerField> {

  ChronometerField chronometerField;
  ChronometerField chronometerField2;
  ChronometerField chronometerField3;

  Timer _timer;

  @override
  Widget build(BuildContext context) {
    TimersProdutividade2.printLogs = true;
    ComunsWidgets.context = context;
    this.initializeFields();
    return this.createHome();
  }

  void emptyFunction(){
  }

  void initializeFields() {
    this.chronometerField ??= new ChronometerField( "Duration",
      key: new ValueKey<String>( FakeScreenTestChronometerField.KEY_STRING_FIELD_CHRONOMETER ),
      functionUpdateUI : () => this.setState( this.emptyFunction )
    );
    this.widget.chronometerFieldReference = this.chronometerField;

    this.chronometerField2 ??= new ChronometerField( "Duration",
      key: new ValueKey<String>( FakeScreenTestChronometerField.KEY_STRING_FIELD_CHRONOMETER+"2" ),
      functionUpdateUI : () => this.setState( this.emptyFunction )
    );

    this.chronometerField3 ??= new ChronometerField( "Duration",
      key: new ValueKey<String>( FakeScreenTestChronometerField.KEY_STRING_FIELD_CHRONOMETER+"3" ),
      functionUpdateUI : () => this.setState( this.emptyFunction )
    );
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text( "Test Screen to component Chronometer Field",
                style: Estilos.textStyleListaTituloDaPagina,
                key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
          ),
          this.chronometerField.getWidget(),
          new RaisedButton(
              key: new ValueKey<String>( FakeScreenTestChronometerField.KEY_STRING_BUTTON_START_STOP ),
              onPressed: ()=> this.clickedStartStop( this.chronometerField ),
              child: new Text("Start/Stop", style: Estilos.textStyleBotaoFormulario),
          ),
          this.chronometerField2.getWidget(),
          new RaisedButton(
            onPressed: () => this.clickedStartStop( this.chronometerField2 ),
            child: new Text("Start/Stop", style: Estilos.textStyleBotaoFormulario),
          ),
        ]
    );
  }


  @override
  void dispose() {
    TimersProdutividade2.cancelTimerIfActivated( this.widget );
    super.dispose();
  }

  void _setStateWithEmptyFunction(){
    this.setState( () {} );
  }

  void clickedStartStop( ChronometerField field ) async{
    bool actived = field.isActive();
    if( !actived ){
      await field.start();
      TimersProdutividade2.createAPeriodicTimer( this.widget, frequencyInMiliseconds: 1000, operation: this._setStateWithEmptyFunction );
    }else{
      await field.pause();
      if( !this.existsSomeChronometerActive() ){
        TimersProdutividade2.cancelTimerIfActivated( this.widget );
      }
    }
  }

  bool existsSomeChronometerActive(){
    return (this.chronometerField.isActive() || this.chronometerField2.isActive() || this.chronometerField3.isActive() );
  }
}
