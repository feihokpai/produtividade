import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';

class TempoDedicadoPersistenciaJson extends ITempoDedicadoPersistencia{
  @override
  void cadastrarTempo(TempoDedicado tempo) {
    // TODO: implement cadastrarTempo
  }

  @override
  void deletarTempo(TempoDedicado tempo) {
    // TODO: implement deletarTempo
  }

  @override
  void editarTempo(TempoDedicado tempo) {
    // TODO: implement editarTempo
  }

  @override
  List<TempoDedicado> getAllTempoDedicado() {
    // TODO: implement getAllTempoDedicado
    throw UnimplementedError();
  }

  @override
  List<TempoDedicado> getTempoDedicado(Tarefa tarefa) {
    // TODO: implement getTempoDedicado
    throw UnimplementedError();
  }

  @override
  List<TempoDedicado> getTempoDedicadoOrderByInicio(Tarefa tarefa) {
    // TODO: implement getTempoDedicadoOrderByInicio
    throw UnimplementedError();
  }

}