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
  void runAll() async{
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
      super.tester.pump(new Duration(seconds: 1)).then((value) {
        super.findOneByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_PAINEL_TAREFA );
      });
    });

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

    await this.testarListView();
  }

  Future<void> zerarECriarRegistrosDeTempo(int qtdRegistros, Tarefa tarefa ) async {
    List tarefas = await controlador.getListaDeTarefas();
    tarefas.clear();
    await controlador.salvarTarefa( tarefa );
    List tempos = await controlador.getAllTempoDedicado();
    tempos.clear();
    for(int i=0; i< qtdRegistros; i++){
      TempoDedicado t = this.criarTempoDedicadoValidoComVariosDados( tarefa , 0, (i+1)*50 );
      await controlador.salvarTempoDedicado( t );
    }
  }

  Future<void> testarListView()  async {
    Tarefa t1 = this.criarTarefaValida(id: 0);
    super.criarTeste("Tem uma ListView? Foram gerados 2 itens na lista?", new ListaDeTempoDedicadoTela( t1 ), () async{
      await this.zerarECriarRegistrosDeTempo( 2, t1 );
      super.pumpWidgetAndPumpAgain( new ListaDeTempoDedicadoTela( t1 ) , 2, () async {
        this.checarQtdItensNaListView( 2 );
        expect( find.byIcon( Icons.delete ), findsNWidgets( 2 ) );
        TempoDedicado t11 = this.criarTempoDedicadoValidoComVariosDados( t1 , 0, 30);
        await controlador.salvarTempoDedicado( t11 );
        super.pumpWidgetAndPumpAgain( new ListaDeTempoDedicadoTela( t1 ) , 2, () {
          this.checarQtdItensNaListView( 3 );
          expect( find.byIcon( Icons.delete ), findsNWidgets( 3 ) );
        });
      });
    });

    super.createAsynchronousTest("Foram criados N ícones de Edição?", new ListaDeTempoDedicadoTela( t1 ), 2, () async {
      List tempos = await super.controlador.getTempoDedicadoOrderByInicio( t1 );
      expect( find.byIcon( Icons.edit ), findsNWidgets( tempos.length ));
    });

    super.createAsynchronousTest("Ao clicar num ícone de edição direciona pra página de edição?",
        new ListaDeTempoDedicadoTela( t1 ), 2, () async {
      List<TempoDedicado> tempos = await super.controlador.getTempoDedicadoOrderByInicio( t1 );
      String keyStringPrimeiro = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_EDITAR}${tempos[0].id}";
      super.tapWidget( keyStringPrimeiro , FinderTypes.KEY_STRING, () {
        expect( ComunsWidgets.context.widget.runtimeType , CadastroTempoDedicadoTela);
        CadastroTempoDedicadoTela tela = ComunsWidgets.context.widget as CadastroTempoDedicadoTela;
        expect( tela.tempoDedicadoAtual.id, tempos[0].id );
      });
    });

    super.createAsynchronousTest("Ao clicar em um dos ícones de deletar, exibe popup?",
        new ListaDeTempoDedicadoTela( t1 ), 2, () {
      this.zerarECriarRegistrosDeTempo( 1 , this.criarTarefaValida( id: 0 ));
      int idRegistro = 1;
      String key = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${idRegistro}";
      super.tapWidgetWithKeyString( key , () {
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG );
      });
    });

    ListaDeTempoDedicadoTela telaBotaoNao = new ListaDeTempoDedicadoTela( t1 );
    super.createAsynchronousTest("Ao clicar em um dos ícones de deletar, Se clicar no Não, faz nada?.", telaBotaoNao, 2, () {
      this.zerarECriarRegistrosDeTempo( 1 , this.criarTarefaValida( id: 0 ));
      int idRegistro = 1;
      String keyBotaoDeletar = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${idRegistro}";
      super.tapWidgetWithKeyString( keyBotaoDeletar , () {
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , () {
          expect( telaBotaoNao.tarefaAtual, isNotNull);
          expect( ComunsWidgets.context.widget.runtimeType , ListaDeTempoDedicadoTela);
          this.checarQtdItensNaListView( 1 );
          expect( find.byIcon( Icons.delete ), findsNWidgets( 1 ) );
        });
      });
    });

    ListaDeTempoDedicadoTela telaDelecao = new ListaDeTempoDedicadoTela( t1 );
    super.createAsynchronousTest("Ao clicar em um dos ícones de deletar, Se clicar no Sim, deleta?.", telaDelecao, 2, () async{
      await this.zerarECriarRegistrosDeTempo( 2 , this.criarTarefaValida( id: 0 ));
      int idRegistro = 1;
      String key = "${ListaDeTempoDedicadoTela.KEY_STRING_ICONE_DELETAR}${idRegistro}";
      super.tapWidgetWithKeyString( key , () {
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , () {
          super.pumpWidgetAndPumpAgain( new ListaDeTempoDedicadoTela( this.criarTarefaValida( id: 1 ) ) , 2, () {
            expect( ComunsWidgets.context.widget.runtimeType , ListaDeTempoDedicadoTela);
            this.checarQtdItensNaListView( 1 );
            expect( find.byIcon( Icons.delete ), findsNWidgets( 1 ) );
          } );
        });
      });
    });

    super.createAsynchronousTest("Há um local onde é exibido o total de tempo gasto na tarefa?", new ListaDeTempoDedicadoTela( t1 ),2, () {
      super.findOneByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
    });

    super.createAsynchronousTest("O total de tempo gasto na tarefa está correto?", new ListaDeTempoDedicadoTela( t1 ), 2, () async {
      int minutos = await this.controlador.getTotalGastoNaTarefaEmMinutos( t1 );
      String correta = DataHoraUtil.criarStringQtdHorasEMinutos( new Duration( minutes: minutos ) );
      String textoExibido = super.getValueTextFormFieldByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
      expect( textoExibido, correta );
    });

    super.createAsynchronousTest("O total de tempo gasto na tarefa está correto quando não tem registros?", new ListaDeTempoDedicadoTela( t1 ), 2, () async {
      List<TempoDedicado> lista = await this.controlador.getAllTempoDedicado();
      lista.clear();
      super.pumpWidgetAndPumpAgain( new ListaDeTempoDedicadoTela( t1 ), 2, () {
        String correta = ListaDeTempoDedicadoTela.TEXTO_SEM_REGISTROS;
        String textoExibido = super.getValueTextFormFieldByKeyString( ListaDeTempoDedicadoTela.KEY_STRING_TOTAL_TEMPO );
        expect( textoExibido, correta );
      });
    });

    this.checaSeExibeInformacoesDeTempoDedicadoSemDataHoraFim();
  }

  void checaSeExibeInformacoesDeTempoDedicadoSemDataHoraFim(){

    Tarefa t = this.criarTarefaValida( );
    ListaDeTempoDedicadoTela tela = new ListaDeTempoDedicadoTela( t );
    super.criarTeste("Se tempo dedicado tem fim null, exibe seus dados sem exceção?", tela, () async {
      List tarefas = await controlador.getListaDeTarefas();
      tarefas.clear();
      await controlador.salvarTarefa( this.criarTarefaValida(id: 0) );
      List tempos = await controlador.getAllTempoDedicado();
      tempos.clear();
      TempoDedicado td9 = this.criarTempoDedicadoValidoComFimNull( this.criarTarefaValida(id: 1), 0 );
      await controlador.salvarTempoDedicado( td9 );
      super.pumpWidgetAndPumpAgain( new ListaDeTempoDedicadoTela( this.criarTarefaValida(id: 1) ) , 2, () {
//        find.byText( ListaDeTempoDedicadoTela. );
      });
    });
  }

}