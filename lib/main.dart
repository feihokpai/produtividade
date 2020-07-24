import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/tarefas_edicao.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

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
  MaterialApp app1 = new MaterialApp( title: "Produtividade", home: new ListaDeTarefasTela() );
  MaterialApp app2 = new MaterialApp(
      title: "Edição de tarefas",
      home: new TarefasEdicaoTela(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],);
//
  runApp( app2 );
}

