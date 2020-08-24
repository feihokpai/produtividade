import "package:flutter/material.dart";
import 'package:registro_produtividade/view/comum/estilos.dart';

class CampoDeTextoWidget{

  TextEditingController campoController = new TextEditingController();
  String _labelCampo;
  TextStyle _textStyleLabel = Estilos.textStyleLabelTextFormField;
  TextStyle _textStyleTexto = Estilos.textStyleTextFormField;
  TextFormField _widget;
  ValueKey<String> _key;
  /// Quantidade de linhas do campo de texto.
  int _linhas;
  /// Máximo de linhas que a mensagem de erro pode ocupar.
  int _linhasErro = 2;
  bool editavel = true;

  String Function(String) funcaoValidacao;

  CampoDeTextoWidget( String label, int qtdLinhas, String Function(String) validacao, {ValueKey<String> chave, bool editavel=true} ){
    this.linhas = qtdLinhas;
    this.labelCampo = label;
    this.funcaoValidacao = validacao;
    this._key = chave ?? new ValueKey<String>( this.toString() );
    this.editavel = editavel;
  }

  void setKeyString(String valor){
    if( this._widget != null ){
      throw new Exception( "Não pode setar a key depois que o widget já foi criado. Somente use setKeyString()"
          " se não tiver atribuído o valor no construtor ou não tiver chamado este mesmo método para o mesmo objeto antes." );
    }
    this._key = new ValueKey<String>( valor );
  }

  ValueKey<String> get key => this._key;

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

  int get linhasErro => this._linhasErro;

  void set linhasErro(int valor){
    if( this._widget != null ){
      throw new Exception("O componente já foi criado. Não pode mais alterar o campo errorMaxLines.");
    }
    this._linhasErro = linhasErro;
  }

  // Retorna ele próprio ou "" se o valor for null
  String get labelCampo => ( _labelCampo ?? "" );
  void set labelCampo(String valor) => this._labelCampo = valor;

  TextFormField get widget{
    if( this._widget == null ){
      this._widget = new TextFormField(
        key: this._key,
        readOnly: !(this.editavel),
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            labelText: labelCampo,
            labelStyle: this.textStyleLabel,
            errorMaxLines: this.linhasErro,
            filled: true,
            fillColor: (this.editavel ? Estilos.corTextFieldEditavel : Estilos.corTextFieldNaoEditavel ),
            enabledBorder: new OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: Estilos.corBarraSuperior),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: (this.editavel ? 3.0 : 1.0), color: Estilos.corBarraSuperior),
            ),
        ),
        style: this.textStyleTexto,
        controller: this.campoController,
        validator: this.funcaoValidacao,
        maxLines: this.linhas,
      );
    }
    return this._widget;
  }

  Widget getWidget(){
    return this.widget;
  }

}