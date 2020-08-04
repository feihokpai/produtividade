import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/mocks/TarefaPersistenciaMock.dart';
import 'package:registro_produtividade/model/mocks/TempoDedicadoPersistenciaMock.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/comum/rotas.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

class AppModule extends MainModule {

  StatefulWidget telaInicial = new ListaDeTarefasTela();

  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [
    new Bind<ITarefaPersistencia>( (injects) => new TarefaPersistenciaMock() ),
    new Bind<ITempoDedicadoPersistencia>( (injects) => new TempoDedicadoPersistenciaMock() ),
  ];

  // Provide all the routes for your module
  @override
  List<Router> get routers => [
    Router('/', child: this.listagemDeTarefas ),
    Router( Rotas.CADASTRO_TAREFA , child: this.edicaoDeTarefas ),
    Router( Rotas.EDICAO_TAREFA , child: this.edicaoDeTarefas ),
  ];

  // Provide the root widget associated with your module
  // In this case, it's the widget you created in the first step
  @override
  Widget get bootstrap => this.criarMaterialApp( this.telaInicial );

  Widget listagemDeTarefas(BuildContext, ModularArguments argumentos){
    return new MaterialApp(
      home: new ListaDeTarefasTela(),
      // set your initial route
      initialRoute: "/",
      navigatorKey: Modular.navigatorKey,
      // add Modular to manage the routing system
      onGenerateRoute: Modular.generateRoute,
    );
    return new ListaDeTarefasTela();
  }

  Widget criarMaterialApp(StatefulWidget tela){
    return new MaterialApp(
      home: tela,
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