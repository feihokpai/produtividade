import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/tarefas_widgets.dart';

void main() {
  print("________________________________");
  var now = new DateTime.now();
  print("Hello World");
  print(now);
  print( "Formatada: ${DataHoraUtil.dataDeHoje()}" );
  print( "Criando um DateTime a partir de 22/07/2020. Trouxe: ${DataHoraUtil.converterDataStringParaDateTime("22/07/2020")}" );
  print( "DateTime para String SQL Lite: ${DataHoraUtil.converterDateTimeParaDateStringSqllite( now )}" );

  MaterialApp app1 = new MaterialApp( title: "Produtividade", home: new ListaDeTarefasTela() );
  runApp( app1 );
}

