import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/mocks/TarefaPersistenciaMock.dart';
import 'package:registro_produtividade/model/mocks/TempoDedicadoPersistenciaMock.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/rotas.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

// Função auxiliar para envolver os widgets a serem testados.

MaterialApp materialApp = new MaterialApp(home: new ListaDeTarefasTela());

Widget makeTestable(Widget widget) {
  return ModularApp( module: AppModule() );
}

Controlador getControlador(){
  AppModule module = new AppModule();
  initModule(
      module,
      changeBinds: [
        Bind<ITarefaPersistencia>((i) => new TarefaPersistenciaMock() ),
        Bind<ITempoDedicadoPersistencia>((i) => new TempoDedicadoPersistenciaMock() ),
      ]
  );
  Controlador controlador = new Controlador();
  return controlador;
}

void main() {

  Controlador controlador = getControlador();

  const double PORTRAIT_WIDTH = 400.0;
  const double PORTRAIT_HEIGHT = 800.0;
  const double LANDSCAPE_WIDTH = PORTRAIT_HEIGHT;
  const double LANDSCAPE_HEIGHT = PORTRAIT_WIDTH;
  Size defaultDimensions;

  testWidgets("Testa se ocorre Overflow na tela 400x800 em pé após inserir 4 registros de Tarefas", (tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    defaultDimensions = binding.window.physicalSize;

    controlador.getListaDeTarefas().clear();
    // In the Mock returns 2 Tasks.
    controlador.salvarTarefa( new Tarefa("aa", "bbbb") );
    controlador.salvarTarefa( new Tarefa("bb", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );

    await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));
    await tester.pumpWidget( new MaterialApp (home: new ListaDeTarefasTela()));

  });

  testWidgets("Testa se ocorre Overflow após deitar a tela 800x400 - 4 registros apenas", (tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Test in portrait
    await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));
    await tester.pumpWidget( new MaterialApp (home: new ListaDeTarefasTela()));
  });

  testWidgets("Testa se ocorre Overflow na tela 400x800 em pé após inserir 12 registros de Tarefas", (tester) async {
    controlador.salvarTarefa( new Tarefa("aa", "bbbb") );
    controlador.salvarTarefa( new Tarefa("bb", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );
    controlador.salvarTarefa( new Tarefa("cc", "cccc") );
    controlador.salvarTarefa( new Tarefa("dd", "cccc") );

    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));
    await tester.pumpWidget( new MaterialApp (home: new ListaDeTarefasTela()));

    await binding.setSurfaceSize(Size(defaultDimensions.width, defaultDimensions.height));
    tester.pumpAndSettle();
  });

  testWidgets("Testa se ocorre Overflow na tela 800x400 em pé após inserir 12 registros de Tarefas", (tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));
    await tester.pumpWidget( new MaterialApp (home: new ListaDeTarefasTela()));

    await binding.setSurfaceSize(Size(defaultDimensions.width, defaultDimensions.height));
    tester.pumpAndSettle();
  });

  controlador = getControlador();

  testWidgets('Tela inicial - Geração da List view',
      (WidgetTester tester) async {

    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    // Uma listview foi gerada.
    Finder finderListView = find.byType(ListView);
    expect(finderListView, findsOneWidget);

    // Teste: Verificar quantos SingleChildScrollView foram gerados;

    List<Tarefa> tarefas = controlador.getListaDeTarefas();
    Finder finderScrolls = find.byType(SingleChildScrollView);
    // "1+" porque tem um SingleChildScrollView como widget inicial.
    expect(finderScrolls, findsNWidgets( 1+tarefas.length));

    // Teste: Adicionar uma tarefa na lista
    tarefas.add(new Tarefa("tarefa 3", "blablabla"));
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNWidgets(1+tarefas.length));

    // teste: remover tarefa da lista.
    tarefas.removeLast();
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsNWidgets(1+tarefas.length));

    // teste: remover todos da lista.
    while (!tarefas.isEmpty) {
      tarefas.removeLast();
    }
    await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
    finderScrolls = find.byType(SingleChildScrollView);
    expect(finderScrolls, findsOneWidget);
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

  testWidgets('Tela inicial - Ícone Relógio existe e direciona para tela de Listagem de Tempo dedicado?',
          (WidgetTester tester) async {
        List<Tarefa> tarefas = controlador.getListaDeTarefas();
        tarefas.clear();
        tarefas.addAll(gerarNTarefas(1));
        await tester.pumpWidget(makeTestable(new ListaDeTarefasTela()));
        //__________________________________________________________________________
        // Teste para verificar se foi criado um ícone de lápis.
        String stringKey = "${ListaDeTarefasTela.KEY_STRING_ICONE_RELOGIO}${tarefas[0].id}";
        Finder botoesFinder = find.byKey(ValueKey(stringKey));
        expect( botoesFinder, findsOneWidget );
        //__________________________________________________________________________
        // Teste para verificar se após clicar no lápis está direcionando para a tela de edição de tarefas.
        await tester.tap(botoesFinder).then((value) {
          tester.pump().then((value) {
            Widget widget = ComunsWidgets.context.widget;
            expect( widget.runtimeType, ListaDeTempoDedicadoTela );
            ListaDeTempoDedicadoTela widget2 = widget as ListaDeTempoDedicadoTela;
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
