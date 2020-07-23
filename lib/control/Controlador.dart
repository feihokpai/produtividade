import 'package:registro_produtividade/control/TarefaEntidade.dart';

class Controlador{
  List<Tarefa> getListaDeTarefas(){
    List<Tarefa> tarefas = <Tarefa>[
      new Tarefa("Passear com a Luna", "Todos os dias pela manhã eu preciso passear com a Luna pelas redondezas"),
      new Tarefa("Estudar React", "Diariamente estudar React Js para me tornar um mestre"),
    ];
    return tarefas;
  }
}