import 'package:registro_produtividade/control/TarefaEntidade.dart';

class Controlador{
  List<Tarefa> tarefas;

  static Controlador _instance;

  Controlador._construtorInterno(){

  }

  factory Controlador( ){
    // Se a instância for nula, chama o construtor privado pra criar uma nova.
    Controlador._instance = _instance ?? new Controlador._construtorInterno();
    return Controlador._instance;
  }

  List<Tarefa> getListaDeTarefas(){
    if( this.tarefas == null ){
      Tarefa t1 = new Tarefa("Passear com a Luna", "Todos os dias pela manhã eu preciso passear com a Luna pelas redondezas");
      Tarefa t2 = new Tarefa("Estudar React", "Diariamente estudar React Js para me tornar um mestre");
      t1.id = 1;
      t2.id = 2;
      this.tarefas = <Tarefa>[ t1, t2 ];
    }
    return tarefas;
  }

  void salvarTarefa( Tarefa tarefa ){
    if( tarefa.id == 0 ) {
      tarefa.id = this._getProximoIdTarefaDisponivel();
      this.tarefas.add(tarefa);
    }else{
      // Por agora não faz nada.
    }
    print( "Quantidade de tarefas depois da inserção: ${tarefas.length}" );
  }

  void deletarTarefa(Tarefa tarefa){
    this.getListaDeTarefas().removeWhere( (tarefaAtual) => tarefaAtual.id == tarefa.id );
  }

  int _getProximoIdTarefaDisponivel() {
    int maior = 0;
    this.getListaDeTarefas().forEach( (tarefa) {
      if( tarefa.id > maior ){
        maior = tarefa.id;
      }
    });
    return (maior+1);
  }

}