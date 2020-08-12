import 'package:flutter/material.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class TelaFakeTesteCampoDataHora extends StatefulWidget {
  static String KEY_STRING_COLUNA_PRINCIPAL = "colunaPrincipal";
  static String KEY_STRING_CAMPO_DATA_HORA = "campoDataHora";

  CampoDataHora campoDaPagina = null;

  @override
  _TelaFakeTesteCampoDataHoraState createState() => _TelaFakeTesteCampoDataHoraState();
}

class _TelaFakeTesteCampoDataHoraState extends State<TelaFakeTesteCampoDataHora> {

  CampoDataHora campoDataHora;

  @override
  Widget build(BuildContext context) {
    ComunsWidgets.context = context;
    this.inicializarCampos();
    return this.criarHome();
  }

  void inicializarCampos() {
    this.campoDataHora = new CampoDataHora("Data Hora aqui", context,
        chave: new ValueKey(TelaFakeTesteCampoDataHora.KEY_STRING_CAMPO_DATA_HORA));
    this.widget.campoDaPagina = this.campoDataHora;
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
    return Column(
      key: new ValueKey( TelaFakeTesteCampoDataHora.KEY_STRING_COLUNA_PRINCIPAL ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text( "Tela vazia usada para testes de Wdget",
                style: Estilos.textStyleListaTituloDaPagina,
                key: new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) ),
          ),
          this.campoDataHora.getWidget(),
        ]
    );
  }


}
