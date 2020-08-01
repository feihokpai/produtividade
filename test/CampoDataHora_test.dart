import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/comum/CampoDataHora.dart';
import 'package:registro_produtividade/view/comum/TelaFakeTesteCampoDataHora.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

import 'WidgetTestsUtil.dart';
import 'WidgetTestsUtilProdutividade.dart';

main(){
  new CampoDataHoraTest("Componente CampoDataHora").runAll();
}

class CampoDataHoraTest extends WidgetTestsUtilProdutividade{

  String keyCampo = TelaFakeTesteCampoDataHora.KEY_STRING_CAMPO_DATA_HORA;
  String keyData;
  String keyHora;

  CampoDataHoraTest(String screenName) : super(screenName){
    this.keyData = CampoDataHora.PREFIXO_KEY_STRING_ICONE_DATE_PICKER+keyCampo;
    this.keyHora = CampoDataHora.PREFIXO_KEY_STRING_ICONE_TIME_PICKER+keyCampo;
  }

  TelaFakeTesteCampoDataHora telaFake(){
    return new TelaFakeTesteCampoDataHora();
  }

  @override
  void runAll() async{

    List camposPresentes = <String>[ this.keyCampo, this.keyData, this.keyHora ];
    super.checarSeComponentesEstaoPresentes( camposPresentes, "Presença: ", telaPronta: this.telaFake(), );

    super.criarTeste("Campo de texto está vazio?", this.telaFake(), () {
      String valorCampo = super.getValueTextFormFieldByKeyString( this.keyCampo );
      expect( valorCampo.length , 0 );
    });

    this.testarPreenchimentoCampoAposSelecionarDataMesmoMes();

    this.testarPreenchimentoCampoAposSelecionarDataMesAnterior();

    this.testarPreenchimentoCampoAposSelecionarHora();

    super.criarTeste("Construtor CampoDataHora pode ser preenchido com label null", this.telaFake(), () {
      expect( new CampoDataHora(null, ComunsWidgets.context).linhas, 1 );
    });

    super.criarTeste("Construtor CampoDataHora não pode ter context null", this.telaFake(), () {
      expect( ()=> new CampoDataHora("aaaa", null).linhas, throwsAssertionError );
    });

    super.criarTeste("Construtor CampoDataHora não pode ter data máxima anterior a mínima", this.telaFake(), () {
      DateTime minima = DataHoraUtil.criarDataHojeInicioDoDia();
      DateTime maxima = DataHoraUtil.criarDataOntemFimDoDia();
      expect( (){ new CampoDataHora("aaaa", ComunsWidgets.context, dataMaxima: maxima, dataMinima: minima).linhas; },
        throwsAssertionError
      );
    });

    super.criarTeste("Construtor CampoDataHora pode ter data máxima igual a mínima, independente da hora", this.telaFake(), () {
      DateTime agora = DateTime.now();
      DateTime minima = DataHoraUtil.criarDataHojeFimDoDia();
      DateTime maxima = DataHoraUtil.criarDataHojeInicioDoDia();
      print("$minima - $maxima");
      expect( new CampoDataHora("aaaa", ComunsWidgets.context, dataMaxima: maxima, dataMinima: minima).linhas,
          1
      );
    });

    super.criarTeste("Construtor CampoDataHora se atribuir Formatter null, atribui o padrão", this.telaFake(), () {
      expect( new CampoDataHora("aaaa", ComunsWidgets.context, dateTimeFormatter: null).formatter,
          CampoDataHora.formatterPadrao
      );
    });

//    super.criarTeste("Construtor CampoDataHora se atribuir Formatter não nulo, muda realmente o formatter", this.telaFake(), () {
//      expect( new CampoDataHora("aaaa", ComunsWidgets.context, dateTimeFormatter:
//            DataHoraUtil.formatterHoraResumidaBrasileira).formatter,
//          DataHoraUtil.formatterHoraResumidaBrasileira
//      );
//    });

  }

  void testarPreenchimentoCampoAposSelecionarDataMesmoMes() {
    super.criarTeste("Campo de texto é preenchido corretamente ao selecionar data do mesmo mês?", this.telaFake(), () {
      super.tapWidget( this.keyData, FinderTypes.KEY_STRING , () {
        super.tapWidget( "10" , FinderTypes.TEXT, () {
          super.tapWidget( "Ok" , FinderTypes.TEXT, () {
            String valorCampo = super.getValueTextFormFieldByKeyString( this.keyCampo );
            DateTime dataHoraSelecionada = CampoDataHora.formatterPadrao.parse( valorCampo );
            String valorEsperado = CampoDataHora.formatterPadrao.format( dataHoraSelecionada );
            expect( valorCampo , valorEsperado);
            DateTime agora = new DateTime.now();
            expect( dataHoraSelecionada.month , agora.month);
            expect( dataHoraSelecionada.year , agora.year);
            expect( dataHoraSelecionada.hour , agora.hour);
            expect( dataHoraSelecionada.minute , agora.minute);
            // Não vou comparar segundos, pra evitar diferenças muito pequenas.
          });
        });
      });
    });
  }

  void testarPreenchimentoCampoAposSelecionarDataMesAnterior() {
    super.criarTeste("Campo de texto é preenchido corretamente ao selecionar data do mês anterior?", this.telaFake(), () {
      super.tapWidget( this.keyData, FinderTypes.KEY_STRING , () {
        super.tapWidget( Icons.edit , FinderTypes.ICON, () {
          String textoData = DataHoraUtil.formatterDataBrasileira.format( DateTime.now() );
          EditableText campo = super.tester.widget( find.text( textoData ) ) as EditableText;
          campo.controller.text = "05/04/2020";
          super.tapWidget( "Ok" , FinderTypes.TEXT, () {
            String valorCampo = super.getValueTextFormFieldByKeyString( this.keyCampo );
            DateTime dataHoraSelecionada = CampoDataHora.formatterPadrao.parse( valorCampo );
            DateTime agora = new DateTime.now();
            expect( dataHoraSelecionada.day , 5);
            expect( dataHoraSelecionada.month , 4);
            expect( dataHoraSelecionada.year , 2020);
            expect( dataHoraSelecionada.hour , agora.hour);
            expect( dataHoraSelecionada.minute , agora.minute);
            // Não vou comparar segundos, pra evitar diferenças muito pequenas.
            String valorEsperado = CampoDataHora.formatterPadrao.format( dataHoraSelecionada );
            expect( valorCampo , valorEsperado);
          });
        });
      });
    });
  }

  void testarPreenchimentoCampoAposSelecionarHora() {
    super.criarTeste("Campo de texto é preenchido corretamente ao selecionar hora?", this.telaFake(), () {
      super.tapWidget( this.keyHora, FinderTypes.KEY_STRING , () {
        Offset centro = tester.getCenter( find.byKey(new ValueKey('time-picker-dial') ) );
        // Abaixo vai clicar primeiro às 6h
        super.tester.tapAt( new Offset(centro.dx, centro.dy+5 ) ).then((value) {
          super.tester.pump().then((value) {
            // Abaixo vai clicar em 15m
            super.tester.tapAt( new Offset(centro.dx+5, centro.dy ) ).then((value) {
              super.tester.pump().then((value) {
                super.tapWidget( "Ok" , FinderTypes.TEXT, () {
                  String valorCampo = super.getValueTextFormFieldByKeyString( this.keyCampo );
                  DateTime dataHoraSelecionada = CampoDataHora.formatterPadrao.parse( valorCampo );
                  DateTime agora = new DateTime.now();
                  expect( dataHoraSelecionada.day , agora.day);
                  expect( dataHoraSelecionada.month , agora.month);
                  expect( dataHoraSelecionada.year , agora.year);
                  expect( dataHoraSelecionada.hour , 6);
                  expect( dataHoraSelecionada.minute , 15);
                  expect( dataHoraSelecionada.second , 0);
                  String valorEsperado = CampoDataHora.formatterPadrao.format( dataHoraSelecionada );
                  expect( valorCampo , valorEsperado);
                });
              });
            });
          });
        });
      });
    });
  }


}