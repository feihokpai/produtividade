import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';

class Controlador{
  List<Tarefa> tarefas;
  List<TempoDedicado> registrosTempoDedicado;

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
      Tarefa t1 = new Tarefa("Passear com a Luna", "Todos os dias pela manhã eu preciso passear com a Luna "
          "pelas redondezas. Aqui estou adicionando muito mais texto, para ver como vai se comportar os text area "
          "onde esse texto será exibido. Será que dá Bug? O texto ainda tá curto. Precisa crescer mais, mais e "
          "mais. Ficando gigante, estoura. Será?");
      Tarefa t2 = new Tarefa("Estudar React", "Diariamente estudar React Js para me tornar um mestre");
      t1.id = 1;
      t2.id = 2;
      this.tarefas = <Tarefa>[ t1, t2 ];
    }
    return tarefas;
  }

  void _criarRegistrosTempoDedicado(){
    if( this.registrosTempoDedicado == null ){
      List<Tarefa> tarefas = this.getListaDeTarefas();
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
            tarefas[0], inicio: agora.subtract(new Duration(hours: 2)), id: 3);
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

  List<TempoDedicado> getAllTempoDedicado(){
    this._criarRegistrosTempoDedicado();
    return this.registrosTempoDedicado;
  }

  List<TempoDedicado> getTempoDedicado(Tarefa tarefa){
    this._criarRegistrosTempoDedicado();
    List<TempoDedicado> lista = new List();
    this.registrosTempoDedicado.forEach((tempo) {
      if( tempo.tarefa.id == tarefa.id ){
        lista.add( tempo );
      }
    });
    return lista;
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

  void deletarRegistroTempoDedicado(TempoDedicado registro) {
    this.registrosTempoDedicado.removeWhere(( atual) => atual.id == registro.id );
  }

  /// Retorna o total de tempo gasto numa tarefa em Minutos.
  int getTotalGastoNaTarefaEmMinutos(Tarefa tarefa){
    List<TempoDedicado> tempos = this.getTempoDedicado( tarefa );
    int somatorio = 0;
    tempos.forEach((tempo) { 
      somatorio += tempo.getDuracaoEmMinutos();
    });
    return somatorio;
  }

}