import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

import 'comum/CampoDeTextoWidget.dart';

class ListagemTempoDedicadoComponente{

  static final String KEY_STRING_ICONE_DELETAR = "deleteIcon";
  static final String KEY_STRING_ICONE_EDITAR = "editIcon";
  static final String KEY_STRING_TOTAL_TEMPO = "sumTime";
  static final String TEXTO_SEM_REGISTROS = "Ainda não há registros encerrados";

  CampoDeTextoWidget campoDuracaoTotal;
  BuildContext context;

  Tarefa _tarefaAtual = null;

  void Function() funcaoAposDeletar;
  void Function(TempoDedicado) funcaoParaEditar;

  int _duracaoMinutos = 0;

  Controlador controlador = new Controlador();

  ListagemTempoDedicadoComponente( Tarefa tarefa, BuildContext context, void Function() funcaoAposDeletar,
      void Function(TempoDedicado) funcaoParaEditar)
      : assert(tarefa != null, "Tentou gerar componente de listagem de tempo dedicado, mas não repassou"
      "nenhuma Tarefa válida.")
  {
    this._tarefaAtual = tarefa;
    this.context = context;
    this.funcaoAposDeletar = funcaoAposDeletar;
    this.funcaoParaEditar = funcaoParaEditar;
    this._inicializarCampoDuracaoTotal();
  }

  void _inicializarCampoDuracaoTotal(){
    Key keyString = new ValueKey( ListagemTempoDedicadoComponente.KEY_STRING_TOTAL_TEMPO );
    this.campoDuracaoTotal = new CampoDeTextoWidget("Total de tempo dedicado na tarefa", 1, null,
        editavel: false, chave: keyString );
  }

  Future<void> _setarTextoCampoDuracaoTotal() async {
    this._duracaoMinutos = await this.controlador.getTotalGastoNaTarefaEmMinutos( this._tarefaAtual );
    String duracaoFormatada = DataHoraUtil.criarStringQtdHorasEMinutos( new Duration(minutes: this._duracaoMinutos) );
    if( this._duracaoMinutos == 0 ){
      duracaoFormatada = ListagemTempoDedicadoComponente.TEXTO_SEM_REGISTROS;
    }
    this.campoDuracaoTotal.setText( duracaoFormatada );
  }

  Future<int> get duracaoMinutos async => await this._duracaoMinutos;

  Future<Widget> gerarCampoDaDuracaoTotal() async{
    await this._setarTextoCampoDuracaoTotal();
    return this.campoDuracaoTotal.widget;
  }

  String _getRegistroTempoDedicadoFormatado(TempoDedicado registro){
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

  BoxDecoration gerarBoxDecorationDosItensDaLista(int indice, int qtd){
    int indiceUltimo = qtd-1;
    BorderRadius borderRadius;
    if(indice == 0){
      borderRadius =  BorderRadius.only( topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0) );
    }else if( indice == indiceUltimo ){
      borderRadius = BorderRadius.only( bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0) );
    }else{
      borderRadius = BorderRadius.zero;
    }
    return new BoxDecoration(
        color: ( (indice % 2 == 0) ? Estilos.corListaTipo1 : Estilos.corListaTipo2 ),
        borderRadius: borderRadius
    );
  }

  Future<Widget> gerarListViewDosTempos() async {
    List<TempoDedicado> registrosTempo = await this.controlador.getTempoDedicadoOrderByInicio( this._tarefaAtual );
    return Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 1.0, color: Colors.black54, style: BorderStyle.solid),//, style: BorderStyle.solid ),
        borderRadius: BorderRadius.circular( 4.0 ),
//        borderRadius: BorderRadius.only(topRight:  Radius.circular(40)),
      ),
      child: new ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: registrosTempo.length,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, indice) {
          TempoDedicado registro = registrosTempo[indice];
          String descricaoRegistro = this._getRegistroTempoDedicadoFormatado( registro );
          String strKeyIconeDelecao = "${ListagemTempoDedicadoComponente.KEY_STRING_ICONE_DELETAR}${registro.id}";
          String strKeyIconeEdicao = "${ListagemTempoDedicadoComponente.KEY_STRING_ICONE_EDITAR}${registro.id}";
          return Container(
            decoration: this.gerarBoxDecorationDosItensDaLista(indice, registrosTempo.length),
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
                        this._clicouNoIconeEdicao(registro);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: new IconButton(
                      key: new ValueKey( strKeyIconeDelecao ),
                      icon: new Icon(Icons.delete),
                      onPressed: () {
                        this._clicouNoIconeDelecao(registro);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _clicouNoIconeDelecao(TempoDedicado registro) {
    ComunsWidgets.exibirDialogConfirmacao(this.context,
        "Você tem certeza de que deseja deletar esse registro",
        "Essa operação não pode ser revertida.").then( (resposta) async {
      if( resposta == 1 ){
        await this.controlador.deletarRegistroTempoDedicado( registro );
        if( this.funcaoAposDeletar != null ){
          this.funcaoAposDeletar.call();
        }
      }
    });
  }

  void _clicouNoIconeEdicao(TempoDedicado registro) {
    this.funcaoParaEditar.call( registro );
  }

}