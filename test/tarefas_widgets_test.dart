import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comuns_widgets.dart';
import 'package:registro_produtividade/view/tarefas_edicao.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

// Função auxiliar para envolver os widgets a serem testados.

MaterialApp materialApp = new MaterialApp(home: new ListaDeTarefasTela());

Widget makeTestable(Widget widget) {
  materialApp = new MaterialApp(home: widget);
  return materialApp;
}

void main() {
  testWidgets('Tela inicial - Geração da List view',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    // Uma listview foi gerada.
    Finder finderListView = find.byType(ListView);
    expect(finderListView, findsOneWidget);

    // Teste: Verificar quantos SingleChildScrollView foram gerados;
    Controlador controlador = new Controlador();
    List<Tarefa> tarefas = controlador.getListaDeTarefas();
    Finder finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNWidgets(tarefas.length));

    // Teste: Adicionar uma tarefa na lista
    tarefas.add(new Tarefa("tarefa 3", "blablabla"));
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNWidgets(tarefas.length));

    // teste: remover tarefa da lista.
    tarefas.removeLast();
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNWidgets(tarefas.length));

    // teste: remover todos da lista.
    while (!tarefas.isEmpty) {
      tarefas.removeLast();
    }
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNothing);
  });

  List<Tarefa> gerarNTarefas(int qtd) {
    List<Tarefa> lista = new List();
    for (int i = 0; i < qtd; i++) {
      Tarefa t = new Tarefa("nome$i", "descrição$i");
      t.id = i + 1;
      lista.add(t);
    }
    return lista;
  }

  testWidgets('Tela inicial - Ícones ao lado das tarefas são gerados?', (WidgetTester tester) async {
    // Preenchendo a lista de tarefas com novos valores.
    Controlador controlador = new Controlador();
    List<Tarefa> tarefas = controlador.getListaDeTarefas();
    tarefas.clear();
    tarefas.addAll(gerarNTarefas(3));
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    //__________________________________________________________________________
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

  testWidgets('Tela inicial - Ícone Lápis existe e direciona para tela de edição?',
  (WidgetTester tester) async {
    Controlador controlador = new Controlador();
    List<Tarefa> tarefas = controlador.getListaDeTarefas();
    tarefas.clear();
    tarefas.addAll(gerarNTarefas(1));
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
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
