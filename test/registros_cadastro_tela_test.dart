import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';

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
    this.clicandoEmVoltarExibeDialogEDirecionaPraPaginaAnterior();
    this.clicandoEmSalvarCriaRegistroEDirecionaPraPaginaAnterior();
    this.clicandoEmDeletarNaoCriaRegistroEDirecionaPraPaginaAnterior();

    super.executeSeveralOverflowTests(() => new CadastroTempoDedicadoTela( this.criarTarefaValida() ) );
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

  void clicandoEmVoltarExibeDialogEDirecionaPraPaginaAnterior( ){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em voltar, mostra dialog?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        List keysDeveriamEstarVisiveis = <String>[
          ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
          ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
        ];
        super.checarSeComponentesEstaoPresentes(
            keysDeveriamEstarVisiveis, "Modo Cadastro:",
            telaPronta: telaCampoInicial, criarTestesIndividuais: false );
      });
    });

    telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em voltar, e depois em NÃO, fica na mesma tela", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
        });
      });
    });

    telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em voltar, e depois em SIM, volta pra tela anterior?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
        });
      });
    });

    Tarefa tarefa = this.criarTarefaValida();
    telaCampoInicial = new CadastroTempoDedicadoTela( tarefa );
    super.criarTeste("Modo Cadastro: Se clicar em voltar, e depois em NÃO, não salva o Registro", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        List lista = this.controlador.getTempoDedicadoOrderByInicio( tarefa );
        int qtd = lista.length;
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( novaQtd, qtd );
        });
      });
    });

    tarefa = this.criarTarefaValida();
    telaCampoInicial = new CadastroTempoDedicadoTela( tarefa );
    super.criarTeste("Modo Cadastro: Se clicar em voltar, e depois em SIM, salva o Registro", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        List lista = this.controlador.getTempoDedicadoOrderByInicio( tarefa );
        int qtd = lista.length;
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( novaQtd, qtd+1 );
        });
      });
    });

  }

  void clicandoEmSalvarCriaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em salvar, volta pra página anterior", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
        });
      });
    });

    Tarefa tarefa = this.criarTarefaValida();
    telaCampoInicial = new CadastroTempoDedicadoTela( tarefa );
    super.criarTeste("Modo Cadastro: Se clicar em salvar, cria novo registro?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( novaQtd, 1+qtd );
        });
      });
    });
  }

  void clicandoEmDeletarNaoCriaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Modo Cadastro: Se clicar em deletar, exibe DIALOG", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          List keysDeveriamEstarVisiveis = <String>[
            ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
            ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
          ];
          super.checarSeComponentesEstaoPresentes(
              keysDeveriamEstarVisiveis, "Modo Cadastro:",
              telaPronta: telaCampoInicial, criarTestesIndividuais: false );
        });
      });
    });

    Tarefa tarefa = this.criarTarefaValida();
    telaCampoInicial = new CadastroTempoDedicadoTela( tarefa );
    super.criarTeste("Modo Cadastro: Se clicar em deletar, clicando em não, mantem na tela e não deleta", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
            int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
            expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
            expect( novaQtd , qtd );
          });
        });
      });
    });

    tarefa = this.criarTarefaValida();
    telaCampoInicial = new CadastroTempoDedicadoTela( tarefa );
    super.criarTeste("Modo Cadastro: Se clicar em deletar, clicando em SIM, muda de tela e não salva", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG, FinderTypes.KEY_STRING, () {
            int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
            expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
            expect( novaQtd , qtd );
          });
        });
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
    this.testesModoEdicaoModo1();
    this.testesModoEdicaoModo2();
  }

  CadastroTempoDedicadoTela criarTelaModoEdicao1(){
    Tarefa t1 = this.criarTarefaValida();
    TempoDedicado td1 = super.criarTempoDedicadoValidoComFimNull(t1, 9);
    return new CadastroTempoDedicadoTela( t1, tempoDedicado: td1 );
  }

  void testesModoEdicaoModo1(){
    List keysPresentesEdicao = <String>[
      ComunsWidgets.KEY_STRING_TITULO_PAGINA,
      keyCampoInicial,
      keyDataInicial,
      keyHoraInicial,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR
    ];
    super.checarSeComponentesEstaoPresentes(keysPresentesEdicao, "Modo Edição 1", telaPronta: this.criarTelaModoEdicao1() );

    List keysAusentesEdicao = <String>[
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL,
      keyDataFinal,
      keyHoraFinal,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR,
      ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
      ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
    ];
    super.checarSeComponentesEstaoOcultos(keysAusentesEdicao, "Modo Edição 1", telaPronta: this.criarTelaModoEdicao1() );

    this.modoEdicao1ClicandoEmVoltarExibeDialogEDirecionaPraPaginaAnterior();

    List keysPresentesAposEncerrar = <String>[
      ComunsWidgets.KEY_STRING_TITULO_PAGINA,
      keyCampoInicial,
      keyDataInicial,
      keyHoraInicial,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL,
      keyDataFinal,
      keyHoraFinal,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR,
    ];

    CadastroTempoDedicadoTela tela = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Botão encerrar - se clicar exibe itens antes ocultos", tela, () {
      super.tapWidget(CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR, FinderTypes.KEY_STRING, () {
        super.checarSeComponentesEstaoPresentes(keysPresentesAposEncerrar, "Modo Edição 1",
            telaPronta: tela, criarTestesIndividuais: false );
      });
    });

    List keysAusentesAposEncerrar = <String>[
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR,
      ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
      ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
    ];
    tela = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Botão encerrar - se clicar oculta itens?", tela, () {
      super.tapWidget(CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR, FinderTypes.KEY_STRING, () {
        super.checarSeComponentesEstaoOcultos( keysAusentesAposEncerrar, "Modo Edição 1",
            telaPronta: tela, criarTestesIndividuais: false );
      });
    });

    this.modoEdicao1EntrandoNaTelaOsCamposDataHoraEstaoPreenchidos();
//    this.modoEdicao1TrocandoDataHoraInicialCampoDeTextoEAtualizado();
    this.modoEdicao1ClicandoEmSalvarEditaRegistroEDirecionaPraPaginaAnterior();
    this.modoEdicao1ClicandoEmDeletarDeletaRegistroEDirecionaPraPaginaAnterior();
  }


  void modoEdicao1EntrandoNaTelaOsCamposDataHoraEstaoPreenchidos(){
    CadastroTempoDedicadoTela tela = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se entrar na tela, campo data inicial está preenchido?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
      expect( (valor.length > 0) , true);
    });

    tela = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se entrar na tela, campo data inicial está preenchido corretamente?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
      DateTime dataHoraPreenchida = CadastroTempoDedicadoTela.formatterDataHora.parse( valor );
      expect( DataHoraUtil.eMesmoHorarioAteSegundos(dataHoraPreenchida, tela.tempoDedicadoAtual.inicio ), true );
    });
  }

//  void modoEdicao1TrocandoDataHoraInicialCampoDeTextoEAtualizado() async{
//    CadastroTempoDedicadoTela tela = this.criarTelaModoEdicao1();
//    super.criarTeste("Modo Edição 1: Se entrar na tela e mudar a hora no relógio, altera o valor no campo?", tela, () async {
//      String valorInicial = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
//      await super.selectHourInHourPickList( this.keyHoraInicial , HourClockDialog.AM_SIX_FIFTEEN );
//      String valorDepois = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
//      DateTime dataHoraDepois = CadastroTempoDedicadoTela.formatterDataHora.parse( valorDepois );
//      expect( dataHoraDepois.hour,  6 );
//      expect( dataHoraDepois.minute,  15 );
//      super.selectHourInHourPickList( this.keyHoraInicial , HourClockDialog.AM_SIX_FIFTEEN ).then((value) {
//        String valorDepois = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
//        DateTime dataHoraDepois = CadastroTempoDedicadoTela.formatterDataHora.parse( valorDepois );
//        expect( dataHoraDepois.hour,  6 );
//        expect( dataHoraDepois.minute,  15 );
//      });
//      super.tapWidget( keyHoraInicial, FinderTypes.KEY_STRING , (){
//        Offset centro = tester.getCenter( find.byKey( new ValueKey('time-picker-dial') ) );
//        // Abaixo vai clicar primeiro às 6h
//        super.tester.tapAt(new Offset(centro.dx, centro.dy + 5)).then((value) {
//          super.tester.pump().then((value) {
//            super.tapWidget( "Ok" , FinderTypes.TEXT, () {
//              String valorDepois = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
//              expect( (valorDepois != valorInicial) , true );
//            });
//          });
//        });
//      });
//    });
//  }

  void modoEdicao1ClicandoEmVoltarExibeDialogEDirecionaPraPaginaAnterior( ){
    CadastroTempoDedicadoTela telaCampoInicial = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se clicar em voltar, mostra dialog?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        List keysDeveriamEstarVisiveis = <String>[
          ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
          ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
        ];
        super.checarSeComponentesEstaoPresentes(
            keysDeveriamEstarVisiveis, "Modo Edição 1:",
            telaPronta: telaCampoInicial, criarTestesIndividuais: false );
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se clicar em voltar, e depois em NÃO, fica na mesma tela", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se clicar em voltar, e depois em SIM, volta pra tela anterior?", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    Tarefa tarefa = telaCampoInicial.tarefaAtual;
    super.criarTeste("Modo Edição 1: Se clicar em voltar, e depois em SIM, salva o Registro, mas não cria um novo", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR , FinderTypes.KEY_STRING, () {
        int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( novaQtd, qtd );
        });
      });
    });

  }

  void modoEdicao1ClicandoEmSalvarEditaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se clicar em salvar, volta pra página anterior", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    Tarefa tarefa = telaCampoInicial.tarefaAtual;
    super.criarTeste("Modo Edição 1: Se clicar em salvar, edita o registro anterior e não cria um novo", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( novaQtd, qtd );
        });
      });
    });
  }

  void modoEdicao1ClicandoEmDeletarDeletaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = this.criarTelaModoEdicao1();
    super.criarTeste("Modo Edição 1: Se clicar em deletar, exibe DIALOG", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          List keysDeveriamEstarVisiveis = <String>[
            ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
            ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
          ];
          super.checarSeComponentesEstaoPresentes(
              keysDeveriamEstarVisiveis, "Modo Cadastro:",
              telaPronta: telaCampoInicial, criarTestesIndividuais: false );
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    Tarefa tarefa = telaCampoInicial.tarefaAtual;
    super.criarTeste("Modo Edição 1: Se clicar em deletar, clicando em não, mantem na tela e não deleta", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
            int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
            expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
            expect( novaQtd , qtd );
          });
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao1();
    tarefa = telaCampoInicial.tarefaAtual;
    super.criarTeste("Modo Edição 1: Se clicar em deletar, clicando em SIM, muda de tela e deleta registro", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR , FinderTypes.KEY_STRING, () {
        super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
          int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG, FinderTypes.KEY_STRING, () {
            int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
            expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
            expect( novaQtd , qtd-1 );
          });
        });
      });
    });
  }


  CadastroTempoDedicadoTela criarTelaModoEdicao2({int idTempoDedicado=0}){
    Tarefa t1 = this.criarTarefaValida();
    TempoDedicado td1 = super.criarTempoDedicadoComFimPreenchido(t1, idTempoDedicado, 30);
    return new CadastroTempoDedicadoTela( t1, tempoDedicado: td1 );
  }

  void testesModoEdicaoModo2(){
    List keysPresentesEdicao = <String>[
      ComunsWidgets.KEY_STRING_TITULO_PAGINA,
      keyCampoInicial,
      keyDataInicial,
      keyHoraInicial,
      keyCampoFinal,
      keyHoraFinal,
      keyDataFinal,
      CadastroTempoDedicadoTela.KEY_STRING_CAMPO_CRONOMETRO,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR,
    ];
    CadastroTempoDedicadoTela telaPronta1 = this.criarTelaModoEdicao2();
    super.checarSeComponentesEstaoPresentes(keysPresentesEdicao, "Modo Edição 2", telaPronta: telaPronta1);

    List keysOcultasEdicao = <String>[
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_ENCERRAR,
      CadastroTempoDedicadoTela.KEY_STRING_BOTAO_VOLTAR,
      ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
      ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG,
    ];
    telaPronta1 = this.criarTelaModoEdicao2();
    super.checarSeComponentesEstaoOcultos(keysOcultasEdicao, "Modo Edição 2", telaPronta: telaPronta1);

    this.modoEdicao2EntrandoNaTelaOsCamposDataHoraEstaoPreenchidos();
    this.modoEdicao2ClicandoEmSalvarEditaRegistroEDirecionaPraPaginaAnterior();
    this.modoEdicao2ClicandoEmDeletarDeletaRegistroEDirecionaPraPaginaAnterior();

    super.executeSeveralOverflowTests(() => this.criarTelaModoEdicao2( ) );
  }

  void modoEdicao2EntrandoNaTelaOsCamposDataHoraEstaoPreenchidos(){
    CadastroTempoDedicadoTela tela = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se entrar na tela, campo data inicial está preenchido?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
      expect( (valor.length > 0) , true);
    });

    tela = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se entrar na tela, campo data inicial está preenchido corretamente?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_INICIAL );
      DateTime dataHoraPreenchida = CadastroTempoDedicadoTela.formatterDataHora.parse( valor );
      expect( DataHoraUtil.eMesmoHorarioAteSegundos(dataHoraPreenchida, tela.tempoDedicadoAtual.inicio ), true );
    });

    tela = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se entrar na tela, campo data final está preenchido?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL );
      expect( (valor.length > 0) , true);
    });

    tela = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se entrar na tela, campo data final está preenchido corretamente?", tela, (){
      String valor = super.getValueTextFormFieldByKeyString( CadastroTempoDedicadoTela.KEY_STRING_CAMPO_HORA_FINAL );
      DateTime dataHoraPreenchida = CadastroTempoDedicadoTela.formatterDataHora.parse( valor );
      expect( DataHoraUtil.eMesmoHorarioAteSegundos(dataHoraPreenchida, tela.tempoDedicadoAtual.fim ), true );
    });
  }

  void modoEdicao2ClicandoEmSalvarEditaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se clicar em salvar, volta pra página anterior", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao2();
    Tarefa tarefa = telaCampoInicial.tarefaAtual;
    this.controlador.salvarTempoDedicado( telaCampoInicial.tempoDedicadoAtual );
    super.criarTeste("Modo Edição 2: Se clicar em salvar, edita o registro anterior e não cria um novo", telaCampoInicial, (){
      int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_SALVAR , FinderTypes.KEY_STRING, () {
        int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        expect( novaQtd, qtd );
      });
    });
  }

  void modoEdicao2ClicandoEmDeletarDeletaRegistroEDirecionaPraPaginaAnterior(){
    CadastroTempoDedicadoTela telaCampoInicial = this.criarTelaModoEdicao2();
    super.criarTeste("Modo Edição 2: Se clicar em deletar, exibe DIALOG", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
        List keysDeveriamEstarVisiveis = <String>[
          ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG,
          ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG
        ];
        super.checarSeComponentesEstaoPresentes(
            keysDeveriamEstarVisiveis, "Modo Cadastro:",
            telaPronta: telaCampoInicial, criarTestesIndividuais: false );
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao2();
    Tarefa tarefa = telaCampoInicial.tarefaAtual;
    super.criarTeste("Modo Edição 2: Se clicar em deletar, clicando em não, mantem na tela e não deleta", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
        int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
          expect( novaQtd , qtd );
        });
      });
    });

    telaCampoInicial = this.criarTelaModoEdicao2( );
    tarefa = telaCampoInicial.tarefaAtual;
    this.controlador.salvarTempoDedicado( telaCampoInicial.tempoDedicadoAtual );
    super.criarTeste("Modo Edição 2: Se clicar em deletar, clicando em SIM, muda de tela e deleta registro", telaCampoInicial, (){
      super.tapWidget( CadastroTempoDedicadoTela.KEY_STRING_BOTAO_DELETAR , FinderTypes.KEY_STRING, () {
        int qtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
        super.tapWidget( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG, FinderTypes.KEY_STRING, () {
          int novaQtd = this.controlador.getTempoDedicadoOrderByInicio( tarefa ).length;
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTempoDedicadoTela );
          expect( novaQtd , qtd-1 );
        });
      });
    });
  }

}