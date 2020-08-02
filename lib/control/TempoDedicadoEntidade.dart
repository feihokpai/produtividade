import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';

class TempoDedicado implements Comparable<TempoDedicado>{
  int _id;
  Tarefa _tarefa;
  DateTime _inicio;
  DateTime _fim;

  TempoDedicado( Tarefa tarefa, { DateTime inicio, int id=0}){
    this.tarefa = tarefa;
    if( inicio == null ) {
      inicio = new DateTime.now();
    }
    this.inicio = inicio;
    this.id = id;
  }
  ///     Retorna a duração deste registro em minutos. Caso não tenha sido registrado um horário de fim
  /// retorna -1.
  int getDuracaoEmMinutos(){
    if( this.fim != null ){
      return this.fim.difference( this.inicio ).inMinutes;
    }
    return -1;
  }

  int get id => this._id;

  void set id(int valor){
    if( valor < 0 ){
      throw new Exception("O id de um registro de tempo dedicado não pode ser menor que zero.");
    }
    this._id = valor;
  }

  DateTime get inicio => this._inicio;
  set inicio(DateTime valor){
    if( valor == null ){
      throw new Exception("Não é permitida uma Data/hora de início de registro nula");
    }
    DateTime agora =  new DateTime.now();
    if( valor.day > agora.day ){
      throw new Exception("Não pode criar um registro de tempo dedicado com uma data posterior a de hoje.");
    }
    this._inicio = valor;
  }

  DateTime get fim => this._fim;

  set fim(DateTime valor){
    if( valor != null && valor.isBefore( this.inicio ) ){
      throw new Exception("Num registro de tempo dedicado o horário de fim deve ser posterior ao de início.");
    }
    this._fim = valor;
  }

  Tarefa get tarefa => this._tarefa;

  void set tarefa(Tarefa valor) {
    if( valor == null ){
      throw new Exception("Não pode criar um registro de tempo dedicado sem associar a ele uma Tarefa.");
    }
    if( valor.id == 0 ){
      throw new Exception("Não pode criar um registro de tempo dedicado sem associar a ele uma Tarefa com id=0.");
    }
    this._tarefa = valor;
  }

  @override
  int compareTo(TempoDedicado other){
    assert( other != null );
    if( this == other){
      return 0;
    }
    if( !DataHoraUtil.eDataMesmoDia(this.inicio, other.inicio) ){
      return this.inicio.isBefore( other.inicio ) ? -1 : 1;
    }else{
      if( DataHoraUtil.eMesmoHorarioAteSegundos(this.inicio, other.inicio) ) {
        return 0;
      }else{
        return ( DataHoraUtil.eHorarioAnteriorAteSegundos(this.inicio, other.inicio) ) ? -1 : 1;
      }
    }
  }

}

