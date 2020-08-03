import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/mocks/TarefaPersistenciaMock.dart';
import 'package:registro_produtividade/model/mocks/TempoDedicadoPersistenciaMock.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

class AppModule extends MainModule {

  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [
    new Bind<ITarefaPersistencia>( (injects) => new TarefaPersistenciaMock() ),
    new Bind<ITempoDedicadoPersistencia>( (injects) => new TempoDedicadoPersistenciaMock() ),
  ];

  // Provide all the routes for your module
  @override
  List<Router> get routers => [
    Router('/', child: (_, __) => new ListaDeTarefasTela() ),
  ];

  // Provide the root widget associated with your module
  // In this case, it's the widget you created in the first step
  @override
  Widget get bootstrap => new ListaDeTarefasTela();

  ITarefaPersistencia injetarTarefaMock( Inject<dynamic> lista ){
    return new TarefaPersistenciaMock();
  }

  ITempoDedicadoPersistencia injetarTempoDedicadoMock( Inject<dynamic> lista ){
    return new TempoDedicadoPersistenciaMock();
  }
}