import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';

class Controlador{

  ITarefaPersistencia tarefaDao;
  ITempoDedicadoPersistencia tempoDedicadoDao;

  static Controlador _instance;

  Controlador._construtorInterno(){
    this.tarefaDao = Modular.get<ITarefaPersistencia>();
    this.tempoDedicadoDao = Modular.get<ITempoDedicadoPersistencia>();
  }

  factory Controlador( ){
    // Se a instância for nula, chama o construtor privado pra criar uma nova.
    Controlador._instance = _instance ?? new Controlador._construtorInterno();
    return Controlador._instance;
  }

  Future<List<Tarefa>> getListaDeTarefas() async{
    return this.tarefaDao.getAllTarefa();
  }

  Future<void> salvarTarefa( Tarefa tarefa ) async {
    if( tarefa.id == 0) {
      await this.tarefaDao.cadastrarTarefa(tarefa);
    }else{
      await this.tarefaDao.editarTarefa(tarefa);
    }
  }

  void deletarTarefa(Tarefa tarefa){
    this.tarefaDao.deletarTarefa(tarefa);
  }

  Future<List<TempoDedicado>> getAllTempoDedicado(){
    return this.tempoDedicadoDao.getAllTempoDedicado();
  }

  Future<List<TempoDedicado>> getTempoDedicadoOrderByInicio(Tarefa tarefa) async {
    return await this.tempoDedicadoDao.getTempoDedicadoOrderByInicio( tarefa );
  }

  void deletarRegistroTempoDedicado(TempoDedicado registro) {
    this.tempoDedicadoDao.deletarTempo( registro );
  }

  /// Retorna o total de tempo gasto numa tarefa em Minutos.
  Future<int> getTotalGastoNaTarefaEmMinutos(Tarefa tarefa) async {
    List<TempoDedicado> tempos = await this.getTempoDedicadoOrderByInicio( tarefa );
    int somatorio = 0;
    tempos.forEach((tempo) { 
      somatorio += tempo.getDuracaoEmMinutos();
    });
    return somatorio;
  }

  void salvarTempoDedicado(TempoDedicado tempo) {
    if( tempo.id == 0) {
      this.tempoDedicadoDao.cadastrarTempo(tempo);
    }else{
      this.tempoDedicadoDao.editarTempo(tempo);
    }
  }

}