import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/json/IPersistenciaJSON.dart';
import 'package:registro_produtividade/model/json/PersistenciaJSON.dart';
import 'package:registro_produtividade/model/json/TarefaPersistenciaJson.dart';
import 'package:registro_produtividade/model/json/TempoDedicadoPersistenciaJson.dart';
import 'package:registro_produtividade/view/comum/rotas.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';
import 'package:registro_produtividade/view/registros_listagem_tela.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

class AppModule extends MainModule {

  static const String nomeArquivoTarefas = "tarefa.json";
  static const String nomeArquivoTarefasBackup = "tarefa_backup.json";
  static const String nomeArquivoTempoDedicado = "tempo.json";
  static const String nomeArquivoTempoDedicadoBackup = "tempo_backup.json";

  StatefulWidget telaInicial = new ListaDeTarefasTela();

  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [
    new Bind<ITarefaPersistencia>( (injects) => new TarefaPersistenciaJson() ),
    new Bind<ITempoDedicadoPersistencia>( (injects) => new TempoDedicadoPersistenciaJson() ),
    new Bind<IPersistenciaJSON>( (injects) => new PersistenciaJson() ),
  ];

  // Provide all the routes for your module
  @override
  List<Router> get routers => [
    Router( Rotas.LISTAGEM_TAREFA, child: this.listagemDeTarefas ),
    Router( Rotas.CADASTRO_TAREFA , child: this.edicaoDeTarefas ),
    Router( Rotas.EDICAO_TAREFA , child: this.edicaoDeTarefas ),
    Router( Rotas.LISTAGEM_TEMPO , child: this.listagemDeTempo ),
    Router( Rotas.CADASTRO_TEMPO , child: this.edicaoDeTempo ),
  ];

  // Provide the root widget associated with your module
  // In this case, it's the widget you created in the first step
  @override
  Widget get bootstrap => this.criarMaterialApp( this.telaInicial );

  Widget listagemDeTarefas(BuildContext context, ModularArguments argumentos){
    return new ListaDeTarefasTela();
  }

  Widget listagemDeTempo(BuildContext context, ModularArguments argumentos){
    dynamic tarefa = argumentos.data;
    Tarefa tarefaParaEditar = tarefa as Tarefa;
    return new ListaDeTempoDedicadoTela( tarefaParaEditar );
  }

  Widget edicaoDeTempo(BuildContext, ModularArguments argumentos){
    List<dynamic> argsList = argumentos.data as List<dynamic>;
    Tarefa tarefa = argsList[0] as Tarefa;
    TempoDedicado tempo = argsList[1] as TempoDedicado;
    bool cronometroLigado = argsList[2] as bool;
    return new CadastroTempoDedicadoTela( tarefa, tempoDedicado: tempo, cronometroLigado: cronometroLigado );
  }

  Widget criarMaterialApp(StatefulWidget tela){
    return new MaterialApp(
      home: tela,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      // set your initial route
      initialRoute: "/",
      navigatorKey: Modular.navigatorKey,
      // add Modular to manage the routing system
      onGenerateRoute: Modular.generateRoute,
    );
  }


  Widget edicaoDeTarefas(BuildContext, ModularArguments argumentos){
    dynamic tarefa = argumentos.data;
    if( tarefa == null ) {
      return new TarefasEdicaoTela();
    }else{
      Tarefa tarefaParaEditar = tarefa as Tarefa;
      return new TarefasEdicaoTela( tarefa: tarefaParaEditar, );
    }
  }
}