import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';

import 'WidgetTestsUtil.dart';
import 'WidgetTestsUtilProdutividade.dart';

main(){
  new ListaDeTempoDedicadoTelaTest("Listagem De Tempo Dedicado").runAll();
}

class ListaDeTempoDedicadoTelaTest extends WidgetTestsUtilProdutividade{

  ListaDeTempoDedicadoTelaTest(String nomeTela) : super(nomeTela);


  void checarQtdItensNaListView(int qtd){
    Finder finderLista = find.byType( ListView );
    expect( finderLista, findsOneWidget );
    ListView listView = tester.widget(finderLista) as ListView;
    expect( listView.semanticChildCount , qtd );
  }

  @override
  void runAll() {
    ComunsWidgets.modoTeste = true;
    super.criarTeste("Tem título na página?", new ListaDeTempoDedicadoTela(this.criarTarefaValida()), () {
      super.findOneByKeyString( ComunsWidgets.KEY_STRING_TITULO_PAGINA );
    });

    Tarefa tAtual = this.criarTarefaValida();
    ListaDeTempoDedicadoTela telaPreenc = new ListaDeTempoDedicadoTela( tAtual );
    super.criarTeste("Ao entrar na página, o objeto Tarefa Atual é preenchido?", telaPreenc, () {
      expect( telaPreenc.tarefaAtual , isNotNull );
      expect( telaPreenc.tarefaAtual , tAtual );
    });

    ListaDeTempoDedicadoTela telaTN = new ListaDeTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Ao entrar na página, passando Tarefa null, lança exceção?", telaTN, () {
      expect( () => super.tester.pumpWidget( new ListaDeTempoDedicadoTela(null) ), throwsAssertionError );
    });

    super.criarTeste("Tem uma área de Detalhamento da Tarefa?", new ListaDeTempoDedicadoTela(this.criarTarefaValida()), () {
      super.findOneByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_PAINEL_TAREFA );
    });

    this.testarListView();

    super.criarTeste("Botão de Novo Registro, ele existe?", new ListaDeTempoDedicadoTela(this.criarTarefaValida()), () {
      super.findOneByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO );
    });

    super.criarTeste("Botão de Novo Registro, se clicar direciona pra tela de cadastro?", new ListaDeTempoDedicadoTela(this.criarTarefaValida()), () {
      super.tapWidgetWithKeyString( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO, () {
        expect( ComunsWidgets.context.widget.runtimeType, CadastroTempoDedicadoTela );
      });
    });

    ListaDeTempoDedicadoTela telaNovoRegistro = new ListaDeTempoDedicadoTela( this.criarTarefaValida() );
    super.criarTeste("Botão de Novo Registro, se clicar reseta as variáveis?", telaNovoRegistro, () {
      super.tapWidgetWithKeyString( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO, () {
        expect( telaNovoRegistro.tarefaAtual, null );
      });
    });

    Tarefa tarefaN2 = this.criarTarefaValida();
    ListaDeTempoDedicadoTela telaNovoRegistro2 = new ListaDeTempoDedicadoTela( tarefaN2 );
    super.criarTeste("Botão de Novo Registro. Após redirecionar, repassa a Tarefa pra tela seguinte?", telaNovoRegistro2, () {
      super.tapWidgetWithKeyString( ListaDeTempoDedicadoTela.KEY_STRING_BOTAO_NOVO, () {
        CadastroTempoDedicadoTela telaSeguinte = ComunsWidgets.context.widget as CadastroTempoDedicadoTela;
        expect( telaSeguinte.tarefaAtual , tarefaN2);
      });
    });

    super.executeSeveralOverflowTests(() => new ListaDeTempoDedicadoTela( this.criarTarefaValida() ) );
  }

  void testarListView(){
    Tarefa t1 = this.criarTarefaValida();
    List tarefas = controlador.getListaDeTarefas();
    tarefas.clear();
    super.controlador.salvarTarefa( t1 );
    List tempos = controlador.getAllTempoDedicado();
    tempos.clear();
    TempoDedicado t9 = this.criarTempoDedicadoValidoComVariosDados( t1 , 9, 80);
    tempos.add( t9 );
    tempos.add( this.criarTempoDedicadoValidoComVariosDados( t1 , 10, 30) );
    int x=1;
    super.criarTeste("Tem uma ListView? Foram gerados 2 itens na lista?", new ListaDeTempoDedicadoTela( t1 ), () {
      this.checarQtdItensNaListView( 2 );
      expect( find.byIcon( Icons.delete ), findsNWidgets( 2 ) );
      tempos.add( this.criarTempoDedicadoValidoComVariosDados( t1 , 11, 30) );
      super.initNewScreen(new ListaDeTempoDedicadoTela( t1 ), tester).then((value) {
        this.checarQtdItensNaListView( 3 );
        expect( find.byIcon( Icons.delete ), findsNWidgets( 3 ) );
      });
    });

    super.criarTeste("Foram criados N ícones de Edição?", new ListaDeTempoDedicadoTela( t1 ), () {
      List tempos = super.controlador.getTempoDedicadoOrderByInicio( t1 );
      expect( find.byIcon( Icons.edit ), findsNWidgets( tempos.length ));
    });

    super.criarTeste("Ao clicar num ícone de edição direciona pra página de edição?", new ListaDeTempoDedicadoTela( t1 ), () {
      List<TempoDedicado> tempos = super.controlador.getTempoDedicadoOrderByInicio( t1 );
      String keyStringPrimeiro = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_EDITAR}${tempos[0].id}";
      super.tapWidget( keyStringPrimeiro , FinderTypes.KEY_STRING, () {
        expect( ComunsWidgets.context.widget.runtimeType , CadastroTempoDedicadoTela);
        CadastroTempoDedicadoTela tela = ComunsWidgets.context.widget as CadastroTempoDedicadoTela;
        expect( tela.tempoDedicadoAtual.id, tempos[0].id );
      });
    });

    super.criarTeste("Ao clicar em um dos ícones de deletar, exibe popup?", new ListaDeTempoDedicadoTela( t1 ), () {
      String key = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${t9.id}";
      super.tapWidgetWithKeyString( key , () {
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG );
      });
    });

    ListaDeTempoDedicadoTela telaBotaoNao = new ListaDeTempoDedicadoTela( t1 );
    super.criarTeste("Ao clicar em um dos ícones de deletar, Se clicar no Não, faz nada?.", telaBotaoNao, () {
      String keyBotaoDeletar = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${t9.id}";
      super.tapWidgetWithKeyString( keyBotaoDeletar , () {
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , () {
          expect( telaBotaoNao.tarefaAtual, isNotNull);
          expect( ComunsWidgets.context.widget.runtimeType , ListaDeTempoDedicadoTela);
          this.checarQtdItensNaListView( 3 );
          expect( find.byIcon( Icons.delete ), findsNWidgets( 3 ) );
        });
      });      
    });

    ListaDeTempoDedicadoTela telaDelecao = new ListaDeTempoDedicadoTela( t1 );
    super.criarTeste("Ao clicar em um dos ícones de deletar, Se clicar no Sim, deleta?.", telaDelecao, () {
      String key = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${t9.id}";
      super.tapWidgetWithKeyString( key , () {
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , () {
          super.initNewScreen( new ListaDeTempoDedicadoTela( t1 ), tester).then((value) {
            expect( ComunsWidgets.context.widget.runtimeType , ListaDeTempoDedicadoTela);
            this.checarQtdItensNaListView( 2 );
            expect( find.byIcon( Icons.delete ), findsNWidgets( 2 ) );
          } );
        });
      });
    });

    super.criarTeste("Há um local onde é exibido o total de tempo gasto na tarefa?", new ListaDeTempoDedicadoTela( t1 ), () {
      super.findOneByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
    });

    super.criarTeste("O total de tempo gasto na tarefa está correto?", new ListaDeTempoDedicadoTela( t1 ), () {
      int minutos = this.controlador.getTotalGastoNaTarefaEmMinutos( t1 );
      String correta = DataHoraUtil.criarStringQtdHorasEMinutos( new Duration( minutes: minutos ) );
      String textoExibido = super.getValueTextFormFieldByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
      expect( textoExibido, correta );
    });

    super.criarTeste("O total de tempo gasto na tarefa está correto?", new ListaDeTempoDedicadoTela( t1 ), () {
      this.controlador.getAllTempoDedicado().clear();
      super.initNewScreen( new ListaDeTempoDedicadoTela( t1 ) , tester ).then((value) {
        String correta = ListaDeTempoDedicadoTela.TEXTO_SEM_REGISTROS;
        String textoExibido = super.getValueTextFormFieldByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
        expect( textoExibido, correta );
      });
    });

    this.checaSeExibeInformacoesDeTempoDedicadoSemDataHoraFim();
  }

  void checaSeExibeInformacoesDeTempoDedicadoSemDataHoraFim(){
    Tarefa t = this.criarTarefaValida();
    ListaDeTempoDedicadoTela tela = new ListaDeTempoDedicadoTela( t );
    super.criarTeste("Se tempo dedicado tem fim null, exibe seus dados sem exceção?", tela, () {
      List tarefas = controlador.getListaDeTarefas();
      tarefas.clear();
      tarefas.add( t );
      List tempos = controlador.getAllTempoDedicado();
      tempos.clear();
      TempoDedicado td9 = this.criarTempoDedicadoValidoComVariosDados( t , 9, 80);
      tempos.add( td9 );
//      super.tester.pumpWidget( new ListaDeTempoDedicadoTela( t ) );
      tempos.add( this.criarTempoDedicadoValidoComFimNull( t , 10 ) );
//      super.tester.pumpWidget( new ListaDeTempoDedicadoTela( t ) );
      MaterialApp app = new MaterialApp( home: new ListaDeTempoDedicadoTela( t ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: [const Locale('en', 'US')]);
      super.tester.pumpWidget( app ).then((value) {
        super.resetarMockDoControlador();
      });
    });
  }

}