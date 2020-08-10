import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

abstract class ITempoDedicadoPersistencia{
  void cadastrarTempo(TempoDedicado tempo);
  void editarTempo(TempoDedicado tempo);
  void deletarTempo(TempoDedicado tempo);
  List<TempoDedicado> getAllTempoDedicado();
  List<TempoDedicado> getTempoDedicado(Tarefa tarefa);
  List<TempoDedicado> getTempoDedicadoOrderByInicio(Tarefa tarefa);
}