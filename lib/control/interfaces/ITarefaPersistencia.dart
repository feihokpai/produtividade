import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

abstract class ITarefaPersistencia{
  void cadastrarTarefa(Tarefa tarefa);
  void editarTarefa(Tarefa tarefa);
  void deletarTarefa(Tarefa tarefa);
  List<Tarefa> getAllTarefa();
}