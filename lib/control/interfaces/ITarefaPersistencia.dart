import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

abstract class ITarefaPersistencia{
  Future<void> cadastrarTarefa(Tarefa tarefa);
  Future<void> editarTarefa(Tarefa tarefa);
  Future<void> deletarTarefa(Tarefa tarefa);
  Future<List<Tarefa>> getAllTarefa();
  Future<List<Tarefa>> getTarefasPorId( List<int> ids );
}