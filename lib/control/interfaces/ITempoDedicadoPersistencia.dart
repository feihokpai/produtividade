import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

abstract class ITempoDedicadoPersistencia{
  void cadastrarTempo(TempoDedicado tempo);
  void editarTempo(TempoDedicado tempo);
  Future<void> deletarTempo(TempoDedicado tempo);
  Future<List<TempoDedicado>> getAllTempoDedicado();
  Future<List<TempoDedicado>> getTempoDedicado(Tarefa tarefa);
  /// Returna a lista de tempos de uma tarefa, ordenados do mais recente pro mais antigo.
  Future<List<TempoDedicado>> getTempoDedicadoOrderByInicio(Tarefa tarefa);
}