import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

import 'WidgetTestsUtilProdutividade.dart';

void main() {
  new ListaDeTarefasTelaTest("Listagem de tarefas").runAll();
}

class ListaDeTarefasTelaTest extends WidgetTestsUtilProdutividade{
  ListaDeTarefasTelaTest(String screenName) : super(screenName);

  List<Tarefa> gerarNTarefas(int qtd) {
    List<Tarefa> lista = new List();
    for (int i = 0; i < qtd; i++) {
      Tarefa t = new Tarefa("nome$i", "descrição$i");
      t.id = i + 1;
      lista.add(t);
    }
    return lista;
  }

  @override
  void runAll() {

    this.testeDeOverflow();

    controlador = getControlador();

    super.criarTeste( "Foi gerada uma GridView?" , new ListaDeTarefasTela(), () async{
      super.tester.pump( new Duration( seconds: 1 )).then((value) {
        Finder finderListView = find.byType(StaggeredGridView);
        expect(finderListView, findsOneWidget);
      });
    });

//    super.criarTeste( "Adicionando tarefa, aumenta quantidade ?" , new ListaDeTarefasTela(), () async{
//      super.tester.pump( new Duration( seconds: 1 )).then((value) {
//        Finder finderListView = find.byType(ListView);
//        expect(finderListView, findsOneWidget);
//      });
//    });

//    testWidgets('Tela inicial - Geração da List view',
//            (WidgetTester tester) async {
//
//          await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()), new Duration( seconds: 3 ));
//
//          // Teste: Adicionar uma tarefa na lista
//          tarefas.add(new Tarefa("tarefa 3", "blablabla"));
//          await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
//          finderScrolls = find.byType(SingleChildScrollView);
//          expect(finderScrolls, findsNWidgets(1+tarefas.length));
//
//          // teste: remover tarefa da lista.
//          tarefas.removeLast();
//          await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
//          finderScrolls = find.byType(SingleChildScrollView);
//          expect(finderScrolls, findsNWidgets(1+tarefas.length));
//
//          // teste: remover todos da lista.
//          while (!tarefas.isEmpty) {
//            tarefas.removeLast();
//          }
//          await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
//          finderScrolls = find.byType(SingleChildScrollView);
//          expect(finderScrolls, findsOneWidget);
//    });

    super.criarTeste("Ícones ao lado das tarefas são gerados?", new ListaDeTarefasTela(), () async{
      List<Tarefa> tarefas = await controlador.getListaDeTarefas();
      tarefas.clear();
      tarefas.addAll(gerarNTarefas(3));
      super.pumpWidgetAndPumpAgain(new ListaDeTarefasTela(), 1, () {
        //Teste de encontrar todos os IconButton da tela. São 2(add e menu lateral) + 2 ícones para cada tarefa.
        Finder botoesFinder = find.byType(IconButton);
        expect(botoesFinder, findsNWidgets(2 + (2 * tarefas.length)));
        //__________________________________________________________________________
        //Teste de encontrar um ícone de lápis para cada tarefa.
        botoesFinder = find.byIcon( Icons.edit );
        expect( botoesFinder, findsNWidgets( tarefas.length ) );
        //__________________________________________________________________________
        //Teste de encontrar um ícone de relógio para cada tarefa.
        botoesFinder = find.byIcon( Icons.alarm );
        expect( botoesFinder, findsNWidgets( tarefas.length ) );
      });
    });

    testWidgets('Tela inicial - Ícone Lápis existe e direciona para tela de edição?',
            (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
      List<Tarefa> tarefas = await controlador.getListaDeTarefas();
      tarefas.clear();
      tarefas.addAll(gerarNTarefas(1));
      super.pumpWidgetAndPumpAgain( new ListaDeTarefasTela(), 1 , () async {
          //__________________________________________________________________________
          // Teste para verificar se foi criado um ícone de lápis.
          String stringKey = "${ListaDeTarefasTela.KEY_STRING_ICONE_LAPIS}${tarefas[0].id}";
          Finder botoesFinder = find.byKey(ValueKey(stringKey));
          expect( botoesFinder, findsOneWidget );
          //__________________________________________________________________________
          // Teste para verificar se após clicar no lápis está direcionando para a tela de edição de tarefas.
          await tester.tap(botoesFinder).then((value) {
            tester.pump().then((value) {
              Widget widget = ComunsWidgets.context.widget;
              expect( widget.runtimeType, TarefasEdicaoTela);
              TarefasEdicaoTela widget2 = widget as TarefasEdicaoTela;
              expect( widget2.tarefaAtual, isNotNull );
              //      print( "Widget do contexto: ${ComunsWidgets.context.widget}" );
            });
          });
      });
    });

    testWidgets('Tela inicial - Ícone Relógio existe e direciona para tela de Listagem de Tempo dedicado?',
            (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
      List<Tarefa> tarefas = await controlador.getListaDeTarefas();
      tarefas.clear();
      tarefas.addAll(gerarNTarefas(1));
      tester.pump( new Duration(seconds: 1) ).then((value) async {
        //__________________________________________________________________________
        // Teste para verificar se foi criado um ícone de lápis.
        String stringKey = "${ListaDeTarefasTela
            .KEY_STRING_ICONE_RELOGIO}${tarefas[0].id}";
        Finder botoesFinder = find.byKey(ValueKey(stringKey));
        expect(botoesFinder, findsOneWidget);
        //__________________________________________________________________________
        // Teste para verificar se após clicar no lápis está direcionando para a tela de edição de tarefas.
        await tester.tap(botoesFinder).then((value) {
          tester.pump().then((value) {
            Widget widget = ComunsWidgets.context.widget;
            expect(widget.runtimeType, ListaDeTempoDedicadoTela);
            ListaDeTempoDedicadoTela widget2 = widget as ListaDeTempoDedicadoTela;
            expect(widget2.tarefaAtual, isNotNull);
            //      print( "Widget do contexto: ${ComunsWidgets.context.widget}" );
          });
        });
      });
    });

    testWidgets('Tela inicial - Ícone ADD nova tarefa existe e funciona?',
            (WidgetTester tester) async {
          await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
          //__________________________________________________________________________
          // Teste para verificar se encontrou algum botão com ícone de add na página.
          Finder botaoAddFinder = find.byIcon(Icons.add);
          expect(botaoAddFinder, findsOneWidget);
          //__________________________________________________________________________
          // Teste para verificar se ao clicar no ícone de ADD direciona para a página de edição
          tester.tap( botaoAddFinder ).then((value) {
            tester.pump().then((value) {
              Widget widget = ComunsWidgets.context.widget;
              expect( widget.runtimeType, TarefasEdicaoTela);
              TarefasEdicaoTela widget2 = widget as TarefasEdicaoTela;
              expect( widget2.tarefaAtual, null );
            });
          });
        });

    testWidgets('Tela inicial - Página tem título?', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
      //__________________________________________________________________________
      //Teste para verificar se foi adicionado um título no incício da página.
      Finder finderTitulo = find.byKey( new ValueKey( ComunsWidgets.KEY_STRING_TITULO_PAGINA ) );
      expect( finderTitulo, findsOneWidget );
    });

  }


  Future<void> testeDeOverflow() async {
    List<Tarefa> tarefas = await super.controlador.getListaDeTarefas();
    tarefas.clear();
    // In the Mock returns 2 Tasks.
    controlador.salvarTarefa( new Tarefa("aa", "bbbb") );
    controlador.salvarTarefa( new Tarefa("bb", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );
    controlador.salvarTarefa( new Tarefa("aa", "bbbb") );
    controlador.salvarTarefa( new Tarefa("bb", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );

    super.executeSeveralOverflowTests(() => new ListaDeTarefasTela() );
  }

}

