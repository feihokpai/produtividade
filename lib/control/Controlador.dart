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

  List<Tarefa> getListaDeTarefas(){
    return this.tarefaDao.getAllTarefa();
  }

  void salvarTarefa( Tarefa tarefa ){
    if( tarefa.id == 0) {
      this.tarefaDao.cadastrarTarefa(tarefa);
    }else{
      this.tarefaDao.editarTarefa(tarefa);
    }
  }

  void deletarTarefa(Tarefa tarefa){
    this.tarefaDao.deletarTarefa(tarefa);
  }

  List<TempoDedicado> getAllTempoDedicado(){
    return this.tempoDedicadoDao.getAllTempoDedicado();
  }

  List<TempoDedicado> getTempoDedicadoOrderByInicio(Tarefa tarefa){
    return this.tempoDedicadoDao.getTempoDedicadoOrderByInicio( tarefa );
  }

  void deletarRegistroTempoDedicado(TempoDedicado registro) {
    this.tempoDedicadoDao.deletarTempo( registro );
  }

  /// Retorna o total de tempo gasto numa tarefa em Minutos.
  int getTotalGastoNaTarefaEmMinutos(Tarefa tarefa){
    List<TempoDedicado> tempos = this.getTempoDedicadoOrderByInicio( tarefa );
    int somatorio = 0;
    tempos.forEach((tempo) { 
      somatorio += tempo.getDuracaoEmMinutos();
    });
    return somatorio;
  }

  void salvarTempoDedicado(TempoDedicado tempo) {
    if( tempo == 0) {
      this.tempoDedicadoDao.cadastrarTempo(tempo);
    }else{
      this.tempoDedicadoDao.editarTempo(tempo);
    }
  }

}