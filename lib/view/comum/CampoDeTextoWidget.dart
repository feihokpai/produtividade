import "package:flutter/material.dart";
import 'package:registro_produtividade/view/estilos.dart';

class CampoDeTextoWidget{

  TextEditingController campoController = new TextEditingController();
  String _labelCampo;
  TextStyle _textStyleLabel = Estilos.textStyleLabelTextFormField;
  TextStyle _textStyleTexto = Estilos.textStyleListaPaginaInicial;
  int _linhas;

  String Function(String) funcaoValidacao;

  CampoDeTextoWidget( String label, int qtdLinhas, String Function(String) validacao ){
    this.linhas = qtdLinhas;
    this.labelCampo = label;
    this.funcaoValidacao = validacao;
  }

  String getText(){
    return this.campoController.text;
  }

  void setText(String valor){
    this.campoController.text = valor;
  }

  TextStyle get textStyleLabel => this._textStyleLabel;

  void set textStyleLabel( TextStyle style ){
    this._textStyleLabel = style;
  }

  TextStyle get textStyleTexto => this._textStyleTexto;

  void set textStyleTexto(TextStyle valor){
    this._textStyleTexto = valor;
  }

  int get linhas => this._linhas;
  void set linhas(int qtd) => this._linhas = qtd;

  // Retorna ele próprio ou "" se o valor for null
  String get labelCampo => ( _labelCampo ?? "" );
  void set labelCampo(String valor) => this._labelCampo = valor;

  Widget getWidget(){
    return new TextFormField( keyboardType: TextInputType.text
      , decoration: new InputDecoration(
          labelText: labelCampo,
          labelStyle: this.textStyleLabel,
          border: new OutlineInputBorder()
      ),
      style: this.textStyleTexto,
      controller: this.campoController,
      validator: this.funcaoValidacao,
      maxLines: this.linhas,
    );
  }

}