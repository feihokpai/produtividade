import 'package:flutter_modular/flutter_modular.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/DateTimeInterval.dart';
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

  ///     Retorna todas as tarefas cadastradas, ordenadas tendo como prioridade as tarefas que tiveram
  /// algum tempo registrado mais recentemente.
  Future<List<Tarefa>> getListaDeTarefasOrderByDataInicio() async{
    try {
      List<Tarefa> tarefas = new List();
      List<TempoDedicado> tempos = await this.getAllTempoDedicadoOrderByInicio();
      if( tempos.isEmpty ){
        tarefas = await this.getListaDeTarefas();
      }else{
        List<int> idsTarefasParaAdicionar = new List();
        tempos.forEach( (tempo) async {
          int idTarefa = tempo.tarefa.id;
          if( !idsTarefasParaAdicionar.contains( idTarefa ) ){
            idsTarefasParaAdicionar.add( idTarefa );
          }
        });
        tarefas = await this._trazerTarefasNaOrdem( idsTarefasParaAdicionar );
        this._addRestanteDasTarefas( tarefas );
      }
      return tarefas;
    }on Exception catch( ex, stack){
      print( "Erro ao carregar a lista de tarefas: ${ex}" );
    }
  }

  Future<List<Tarefa>> _trazerTarefasNaOrdem( List<int> ids ) async{
    List<Tarefa> tarefas = new List();
    await ids.forEach((idTarefa) async {
      Tarefa tarefa = await this.tarefaDao.getTarefa( idTarefa );
      tarefas.add( tarefa );
    });
    return tarefas;
  }

  /// Add in task list in parameter the tasks inserted in database not yet included in her.
  Future<void>_addRestanteDasTarefas( List<Tarefa> tarefas ) async{
    List<Tarefa> todas = await this.getListaDeTarefas();
    todas.forEach((tarefa) {
      if( !tarefas.contains( tarefa ) ){
        tarefas.add( tarefa );
      }
    });
  }

  Future<void> salvarTarefa( Tarefa tarefa ) async {
    if( tarefa.id == 0) {
      await this.tarefaDao.cadastrarTarefa(tarefa);
    }else{
      await this.tarefaDao.editarTarefa(tarefa);
    }
  }

  Future<void> deletarTarefa(Tarefa tarefa) async {
    List<TempoDedicado> tempos = await this.getTempoDedicadoOrderByInicio( tarefa );
    await this.tarefaDao.deletarTarefa(tarefa);
    tempos.forEach((tempo) => this.deletarRegistroTempoDedicado(tempo) );
  }

  Future<List<TempoDedicado>> getAllTempoDedicado() async {
    return await this.tempoDedicadoDao.getAllTempoDedicado();
  }

  Future<List<TempoDedicado>> getAllTempoDedicadoOrderByInicio() async {
    List<TempoDedicado> tempos = await this.getAllTempoDedicado();
    tempos.sort();
    return tempos.reversed.toList();
  }

  /// Returna a lista de tempos de uma tarefa, ordenados do mais recente pro mais antigo.
  Future<List<TempoDedicado>> getTempoDedicadoOrderByInicio(Tarefa tarefa, {DateTimeInterval interval}) async {
    try{
      List<TempoDedicado> lista = await this.tempoDedicadoDao.getTempoDedicadoOrderByInicio( tarefa );
      if( interval != null ) {
        lista.removeWhere((tempo) => !tempo.isBetween(interval));
      }
      return lista;
    }catch(ex){
      print( "Erro ao tentar listar os registros de tempo dedicado: ${ex}" );
    }
  }

  void deletarRegistroTempoDedicado(TempoDedicado registro) {
    this.tempoDedicadoDao.deletarTempo( registro );
  }

  int getSomatorioTempoGasto(List<TempoDedicado> tempos){
    int somatorio = 0;
    tempos.forEach((tempo) {
      somatorio += tempo.getDuracaoEmMinutos();
    });
    return somatorio;
  }

  /// Retorna o total de tempo gasto numa tarefa em Minutos.
  Future<int> getTotalGastoNaTarefaEmMinutos(Tarefa tarefa, {DateTimeInterval interval}) async {
    List<TempoDedicado> tempos = await this.getTempoDedicadoOrderByInicio( tarefa, interval: interval );
    return this.getSomatorioTempoGasto( tempos );
  }

  /// Retorna o total de tempo gasto numa tarefa em Minutos.
  Future<int> getTotalGastoNaTarefaEmMinutosNoDia(Tarefa tarefa, DateTime data) async {
    List<TempoDedicado> tempos = await this.getTempoDedicadoOrderByInicio( tarefa );
    tempos = tempos.where((tempo) => DataHoraUtil.eDataMesmoDia( tempo.inicio , data) ).toList();
    return this.getSomatorioTempoGasto( tempos );
  }

  void salvarTempoDedicado(TempoDedicado tempo) {
    if( tempo.id == 0) {
      this.tempoDedicadoDao.cadastrarTempo(tempo);
    }else{
      this.tempoDedicadoDao.editarTempo(tempo);
    }
  }


  Future<List<TempoDedicado>> getTempoDedicadoAtivos() async {
    List<TempoDedicado> todos = await this.getAllTempoDedicado();
    List<Tarefa> todas = await this.getListaDeTarefas();
    List<TempoDedicado> filtrados = todos.where((tempo) => tempo.fim == null ).toList();
    filtrados.forEach((tempo) {
      tempo.tarefa = todas.where( (tarefa) => tarefa.id == tempo.tarefa.id ).first;
    });
    return filtrados;
  }

}