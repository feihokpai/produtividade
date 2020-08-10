import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

class TestsUtilProdutividade{
  Tarefa criarTarefaValida({int id=0}){
    Tarefa tarefa = new Tarefa("aaa", "bbb", id: id);
    return tarefa;
  }

  Tarefa criarTarefaValidaSemId(){
    Tarefa tarefa = new Tarefa("aaa", "bbb");
    return tarefa;
  }

  TempoDedicado criarTempoDedicadoValidoComVariosDados(Tarefa tarefa, int id, int duracaoMinutos){
    TempoDedicado td = new TempoDedicado(tarefa , inicio: DateTime.now().subtract(new Duration( minutes: duracaoMinutos )), id: id);
    td.fim = DateTime.now();
    return td;
  }

  TempoDedicado criarTempoDedicadoComFimPreenchido(Tarefa tarefa, int id, int duracaoMinutos){
    TempoDedicado td = new TempoDedicado(tarefa , inicio: DateTime.now().subtract(new Duration( minutes: duracaoMinutos )), id: id);
    td.fim = DateTime.now();
    return td;
  }

  /// Gera um objeto Tempo dedicado com início prenchido e fim null.
  TempoDedicado criarTempoDedicadoValidoComFimNull(Tarefa tarefa, int id){
    TempoDedicado td = new TempoDedicado(tarefa , inicio: DateTime.now().subtract(new Duration( minutes: 30 )), id: id);
    td.fim = null;
    return td;
  }
}