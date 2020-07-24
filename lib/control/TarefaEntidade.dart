import 'dart:io';

class Tarefa{
  int _id;
  String _nome;
  String descricao;
  int _status = Tarefa.ABERTA;
  bool arquivada = false;
  Tarefa _tarefaPai = null;
  DateTime dataHoraCadastro = null;
  DateTime _dataHoraConclusao = null;

  static const int ABERTA = 1;
  static const int CONCLUIDA = 2;
  static List<int> statusValidos = <int> [ ABERTA, CONCLUIDA ];

  static const int LIMITE_TAMANHO_NOME = 35;

  Tarefa( String nome, this.descricao ){
    this._id = 0; // Não passa pelo setter, pra evitar erro.
    this.nome = nome;
    this.dataHoraCadastro = DateTime.now();
  }

  int get status => this._status;

  void set status( int valor ){
    if( !Tarefa.statusValidos.contains( valor ) ){
      throw new Exception("Tentou passar para uma tarefa um status inválido: ${valor}");
    }
    this._status = valor;
  }

  int get id => this._id;

  void set id( int valor ){
    if( valor <= 0 ){
      throw new Exception("Não pode setar um valor abaixo de zero (${valor}) para o id de uma tarefa ");
    }
    this._id = valor;
  }

  String get nome => _nome;

  void set nome( String valor ){
    if( valor == null || valor.length == 0 ){
      throw new Exception( "O nome de uma tarefa não pode ser vazio" );
    }
    if( valor.length > Tarefa.LIMITE_TAMANHO_NOME ){
      throw new Exception( "O nome de uma tarefa não pode ter mais de ${Tarefa.LIMITE_TAMANHO_NOME} caracteres" );
    }
    this._nome = valor;
  }

  DateTime get dataHoraConclusao => this._dataHoraConclusao;

  void set dataHoraConclusao(DateTime valor){
    DateTime agora = DateTime.now();
    if( (valor.day - agora.day ) > 0 ){
      throw new Exception( "${valor} é posterior a data de hoje ${agora}. A data de conclusão não pode ser uma data futura" );
    }
    this._dataHoraConclusao = valor;
  }

  Tarefa get tarefaPai => this._tarefaPai;

  void set tarefaPai(Tarefa outra){
    if( outra == this ){
      throw new Exception("Não pode setar como pai de uma tarefa a própria tarefa");
    }
    this._tarefaPai = outra;
  }

  @override
  String toString(){
    return "id(${this.id}): nome(${this.nome}) - descrição: ${this.descricao}";
  }



  /*

  @override
  bool operator ==(Object outro) {
    return (outro is Tarefa && outro.id == this.id);
  }

  */
}