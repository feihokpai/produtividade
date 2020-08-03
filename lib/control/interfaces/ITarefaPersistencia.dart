import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';

abstract class ITarefaPersistencia{
  void cadastrarTarefa(Tarefa tarefa);
  void editarTarefa(Tarefa tarefa);
  void deletarTarefa(Tarefa tarefa);
  List<Tarefa> getAllTarefa();
}