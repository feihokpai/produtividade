import 'package:mockito/mockito.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';

import 'TarefaPersistenciaMock.dart';

class TempoDedicadoPersistenciaMock extends Mock implements ITempoDedicadoPersistencia{

  List<TempoDedicado> registrosTempoDedicado;

  TempoDedicadoPersistenciaMock(): super(){
    this._criarRegistrosIniciais();
  }

  void _criarRegistrosIniciais() {
    List<Tarefa> tarefas = TarefaPersistenciaMock.tarefas;
    this.registrosTempoDedicado = new List();
    DateTime agora = new DateTime.now();
    if( tarefas.length > 0 ) {
      TempoDedicado td1 = new TempoDedicado(
          tarefas[0], inicio: agora.subtract(new Duration(hours: 2)), id: 1);
      td1.fim = agora.subtract(new Duration(minutes: 50));
      TempoDedicado td2 = new TempoDedicado(
          tarefas[0], inicio: agora.subtract(new Duration(hours: 4)), id: 2);
      td2.fim = agora.subtract(new Duration(hours: 3));
      TempoDedicado td3 = new TempoDedicado(
          tarefas[0], inicio: agora.subtract(new Duration(hours: 3)), id: 3);
      td3.fim = agora.subtract(new Duration(hours: 1));
      this.registrosTempoDedicado.add( td1 );
      this.registrosTempoDedicado.add( td2 );
      this.registrosTempoDedicado.add( td3 );
    }
    if( tarefas.length > 1) {
      TempoDedicado td4 = new TempoDedicado(
          tarefas[1], inicio: agora.subtract(new Duration(minutes: 55)),
          id: 4);
      td4.fim = agora.subtract(new Duration(minutes: 30));
      this.registrosTempoDedicado.add( td4 );
    }
  }

  void cadastrarTempo(TempoDedicado tempo){
    this._salvarOuEditar(tempo);
  }
  void editarTempo(TempoDedicado tempo){
    this._salvarOuEditar(tempo);
  }

  void _salvarOuEditar(TempoDedicado tempo){
    if( tempo.id == 0) {
      tempo.id = this.getProximoIdTempoDisponivel();
      this.registrosTempoDedicado.add(tempo);
    }
  }

  int getProximoIdTempoDisponivel(){
    int maior = 0;
    this.registrosTempoDedicado.forEach((element) {
      if( element.id > maior){
        maior = element.id;
      }
    });
    return maior+1;
  }

  void deletarTempo(TempoDedicado tempo){
    this.registrosTempoDedicado.removeWhere(( atual) => atual.id == tempo.id );
  }

  Future<List<TempoDedicado>> getAllTempoDedicado() async{
    return this.registrosTempoDedicado;
  }

  Future<List<TempoDedicado>> getTempoDedicado(Tarefa tarefa) async{
    if( tarefa == null ){
      return new List();
    }
    List<TempoDedicado> lista = new List();
    this.registrosTempoDedicado.forEach((tempo) {
      if( tempo.tarefa.id == tarefa.id ){
        lista.add( tempo );
      }
    });
    return lista;
  }

  Future<List<TempoDedicado>> getTempoDedicadoOrderByInicio(Tarefa tarefa) async{
    List<TempoDedicado> lista = await this.getTempoDedicado( tarefa );
    lista.sort();
    return lista.reversed.toList();
  }

}