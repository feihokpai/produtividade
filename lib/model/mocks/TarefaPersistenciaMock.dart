import 'package:mockito/mockito.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';

class TarefaPersistenciaMock extends Mock implements ITarefaPersistencia{
  // É estático aqui no Mock pra facilitar o uso por outros Mocks.
  static List<Tarefa> tarefas;

  TarefaPersistenciaMock():super(){
    this.criarDados();
  }

  Future<void> cadastrarTarefa(Tarefa tarefa){
    this._salvarOuEditar(tarefa);
  }
  Future<void> editarTarefa(Tarefa tarefa){
    this._salvarOuEditar(tarefa);
  }

  Future<void> deletarTarefa(Tarefa tarefa){
    TarefaPersistenciaMock.tarefas.removeWhere( (tarefaAtual) => tarefaAtual.id == tarefa.id );
  }

  Future<List<Tarefa>> getAllTarefa() async{
    return TarefaPersistenciaMock.tarefas;
  }

  Future<List<Tarefa>> getTarefasPorId( List<int> ids ) async {
    return await tarefas.where((tarefa) => ids.contains( tarefa.id )).toList();
  }

  void _salvarOuEditar(Tarefa tarefa){
    if( tarefa.id == 0 ) {
      tarefa.id = this._getProximoIdTarefaDisponivel();
      TarefaPersistenciaMock.tarefas.add(tarefa);
    }else{
      // Por agora não faz nada.
    }
  }

  int _getProximoIdTarefaDisponivel() {
    int maior = 0;
    TarefaPersistenciaMock.tarefas.forEach( (tarefa) {
      if( tarefa.id > maior ){
        maior = tarefa.id;
      }
    });
    return (maior+1);
  }

  void criarDados() {
    Tarefa t1 = new Tarefa("Passear com a Luna", "Todos os dias pela manhã eu preciso passear com a Luna "
        "pelas redondezas. Aqui estou adicionando muito mais texto, para ver como vai se comportar os text area "
        "onde esse texto será exibido. Será que dá Bug? O texto ainda tá curto. Precisa crescer mais, mais e "
        "mais. Ficando gigante, estoura. Será?");
    Tarefa t2 = new Tarefa("Estudar React", "Diariamente estudar React Js para me tornar um mestre");
    t1.id = 1;
    t2.id = 2;
    TarefaPersistenciaMock.tarefas = <Tarefa>[ t1, t2 ];
  }
}