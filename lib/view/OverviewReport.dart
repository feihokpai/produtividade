import 'package:flutter/material.dart';
import 'package:registro_produtividade/control/Controlador.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/CampoDeTextoWidget.dart';

class OverviewReport{

  Controlador controlador = new Controlador();
  DateTimeInterval interval;
  
  OverviewReport(){

  }

  List<Widget> _resultFields = new List();

  Future<void> _generateTextFieldFromTask(Tarefa tarefa) async {
    int duracaoEmMinutos = await this.controlador.getTotalGastoNaTarefaEmMinutos(tarefa, interval: interval);
    if(duracaoEmMinutos == 0){
      return;
    }
    String totalDuration = DataHoraUtil.criarStringQtdHorasEMinutosAbreviados( new Duration( minutes: duracaoEmMinutos ) );
    int daysAmount = interval.daysAmount();
    double average = duracaoEmMinutos/daysAmount;
    String averageDuration = DataHoraUtil.criarStringQtdHorasEMinutosAbreviados( new Duration( minutes: average.toInt() ) );
    String content = "Total: ${totalDuration} - Média diária: ${averageDuration}";
    String label = "Tarefa: ${tarefa.nome}";
    CampoDeTextoWidget campo = new CampoDeTextoWidget(label, 1, null, editavel: false);
    campo.setText( content );
    this._resultFields.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
          child: campo.getWidget(),
        )
    );
  }
  
  Future<void> _generateResultFields( ) async {
    this._resultFields.clear();
    List<Tarefa> todasAsTarefas = await this.controlador.getListaDeTarefas();
    for( int i=0; i<todasAsTarefas.length; i++ ){
      Tarefa tarefa = todasAsTarefas[i];
      await this._generateTextFieldFromTask( tarefa );
    }
  }

  Future<Widget> generateReport( DateTimeInterval interval ) async {
    try {
      assert(interval != null);
      this.interval = interval;
      await this._generateResultFields();
      List<Widget> childrenWidgets = new List();
      childrenWidgets.addAll(this._resultFields);
      return new Column(
        children: childrenWidgets,
      );
    }catch( ex, stackTrace ){
      print( "Erro ao tentar gerar o relatório: ${ex} - ${stackTrace}" );
    }
  }
  
}