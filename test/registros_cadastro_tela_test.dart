import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';

import 'WidgetTestsUtil.dart';
import 'WidgetTestsUtilProdutividade.dart';

void main(){
  new CadastroTempoDedicadoTelaTest("Cadastro de Tempo Dedicado").runAll();
}

class CadastroTempoDedicadoTelaTest extends WidgetTestsUtilProdutividade{
  CadastroTempoDedicadoTelaTest(String screenName) : super(screenName);

  String keyCampoInicial = CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL;
  String keyDataInicial = CampoDataHora.PREFIXO_KEY_STRING_ICONE_DATE_PICKER+CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL;
  String keyHoraInicial = CampoDataHora.PREFIXO_KEY_STRING_ICONE_TIME_PICKER+CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL;
  String keyCampoFinal = CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL;
  String keyDataFinal = CampoDataHora.PREFIXO_KEY_STRING_ICONE_DATE_PICKER+CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL;
  String keyHoraFinal = CampoDataHora.PREFIXO_KEY_STRING_ICONE_TIME_PICKER+CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL;

  @override
  void runAll() {
    ComunsWidgets.modoTeste = true;
    this.testesModoCadastro();
    this.testesModoEdicao();
  }

  void testesModoCadastro() {
    List keysPresentesCadastro = <String>[
      ComunsWidgets.KEY_STRING_TITULO_PAGINA,
      keyCampoInicial,
      keyDataInicial,
      keyHoraInicial,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR,
    ];
    CadastroTempoDedicadoTela telaPronta1 = new CadastroTempoDedicadoTela( this.criarTarefaValida(), cronometroLigado: false, );
    super.checarSeComponentesEstaoPresentes(
        keysPresentesCadastro, "Modo Cadastro:",
        telaPronta: telaPronta1
    );

    List keysAusentesCadastro = <String>[
      keyCampoFinal,
      keyDataFinal,
      keyHoraFinal,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR,
    ];
    CadastroTempoDedicadoTela telaPronta2 = new CadastroTempoDedicadoTela( this.criarTarefaValida(), cronometroLigado: false, );
    super.checarSeComponentesEstaoOcultos( keysAusentesCadastro, "Modo Cadastro:", telaPronta: telaPronta2);

    this.testaDataInicialSetadaCorretamenteNoCampo();
    this.clicandoEmEncerrarExibeCamposEBotoesOcultos();
    this.clicandoEmEncerrarOcultaBotoes();

  }

  void clicandoEmEncerrarExibeCamposEBotoesOcultos(){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em encerrar, exibe campos e botões ocultos?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        List keysDeveriamEstarExibidas = <String>[
          keyCampoFinal,
          keyDataFinal,
          keyHoraFinal,
          CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR,
          CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR
        ];
        super.checarSeComponentesEstaoPresentes(
            keysDeveriamEstarExibidas, "Modo Cadastro:",
            telaPronta: telaCampoInicial, criarTestesIndividuais: false
        );
      });
    });
  }

  void clicandoEmEncerrarOcultaBotoes(){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em encerrar, oculta botões?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        List keysDeveriamEstarOcultas = <String>[
          CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR,
          CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR,
        ];
        super.checarSeComponentesEstaoOcultos(
            keysDeveriamEstarOcultas, "Modo Cadastro:",
            telaPronta: telaCampoInicial, criarTestesIndividuais: false
        );
      });
    });
  }

  void testaDataInicialSetadaCorretamenteNoCampo(){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida(), cronometroLigado: false, );
    super.criarTeste("Modo Cadastro: Testa se data hora inicial é setada como a atual ao entrar na tela",
        telaCampoInicial, () {
          String valorEncontrado = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
          DateTime dataHoraNoCampo = CadastroTempoDedicadoTela.formatterDataHora.parse( valorEncontrado );
          int diferenca = new DateTime.now().difference( dataHoraNoCampo ).inMinutes;
          expect( diferenca , 0 );
    } );
  }

  void testesModoEdicao() {
    List keysPresentesEdicao = <String>[
      ComunsWidgets.KEY_STRING_TITULO_PAGINA,
      keyCampoFinal,
      keyDataInicial,
      keyHoraInicial,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO,
    ];
    CadastroTempoDedicadoTela telaPronta1 = new CadastroTempoDedicadoTela( this.criarTarefaValida(), cronometroLigado: false, );
    super.checarSeComponentesEstaoPresentes(keysPresentesEdicao, "Modo Edição", telaPronta: telaPronta1);

    List keysAusentesEdicao = <String>[
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR
    ];
    CadastroTempoDedicadoTela telaPronta2 = new CadastroTempoDedicadoTela( this.criarTarefaValida(), cronometroLigado: false, );
    super.checarSeComponentesEstaoOcultos( keysAusentesEdicao, "Modo Edição:", telaPronta: telaPronta2);
  }


}