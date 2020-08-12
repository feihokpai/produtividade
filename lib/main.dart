import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/LabelsApplication.dart';
import 'package:registro_produtividade/model/mocks/TarefaPersistenciaMock.dart';
import 'package:registro_produtividade/model/mocks/TempoDedicadoPersistenciaMock.dart';
import 'package:registro_produtividade/view/comum/TelaFakeTesteCampoDataHora.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

void main() {
  print("________________________________");
//  var now = new DateTime.now();
//  print("Hello World");
//  print(now);
//  print( "Formatada: ${DataHoraUtil.dataDeHoje()}" );
//  print( "Criando um DateTime a partir de 22/07/2020. Trouxe: ${DataHoraUtil.converterDataStringParaDateTime("22/07/2020")}" );
//  print( "DateTime para String SQL Lite: ${DataHoraUtil.converterDateTimeParaDateStringSqllite( now )}" );

//  DateTime agora = DateTime.now();
//  DateTime amanha = agora.add( new Duration( days: 1 ) );
//  DateTime amanhaInicioDia = amanha.subtract( new Duration( hours: amanha.hour, minutes: amanha.minute, seconds: (amanha.second-10) ) );
//  print( agora.difference( amanha ).inDays );
//  print( amanha.difference( agora ).inDays );
//  print( amanhaInicioDia );
  MaterialApp app1 = new MaterialApp(
      title: "Produtividade",
      home: new ListaDeTarefasTela(),
      localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      initialRoute: "/",
      navigatorKey: Modular.navigatorKey,
      // add Modular to manage the routing system
      onGenerateRoute: Modular.generateRoute,
  );;
  MaterialApp app2 = new MaterialApp(
      title: "Edição de tarefas",
      home: new TarefasEdicaoTela(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],);
  MaterialApp app3 = new MaterialApp(
      title: "Tela para testes do Campo Data Hora",
      home: new TelaFakeTesteCampoDataHora(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
  );
  //__________________________________________
  // Definições da linguagem
//  LabelsApplication configuracoesLinguagem = new LabelsApplication( LabelsApplication.pt_br );
  //__________________________________________
  // Configuração do banco
//  Controlador controlador = new Controlador();
//  controlador.tarefaDao = new TarefaPersistenciaMock();
//  controlador.tempoDedicadoDao = new TempoDedicadoPersistenciaMock();
  //__________________________________________
  runApp( ModularApp(module: AppModule()) );
}

