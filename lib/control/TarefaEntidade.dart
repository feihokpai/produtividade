class Tarefa{
  int _id;
  String nome;
  String descricao;
  int _status = Tarefa.ABERTA;
  bool arquivada = false;
  Tarefa tarefaPai = null;
  DateTime dataHoraCadastro = null;
  DateTime dataHoraConclusao = null;

  static const int ABERTA = 1;
  static const int CONCLUIDA = 2;
  List<int> statusValidos = <int> [ ABERTA, CONCLUIDA ];

  static const int LIMITE_TAMANHO_NOME = 20;

  Tarefa( this.nome, this.descricao ){
    this.dataHoraCadastro = DateTime.now();
  }

  int get status => this._status;

  void set status( int valor ){
    if( !this.statusValidos.contains( valor ) ){
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

  /*

  static const String ID_KEY = "chave";
  static const String DESCRICAO_KEY = "texto";
  static const String STATUS_KEY = "status";



  Tarefa.fromMap( Map<String, dynamic> mapa ){
    this.id = mapa[ID_KEY];
    this.descricao = mapa[DESCRICAO_KEY];
    this.status = mapa[STATUS_KEY];
  }



  Map<String, dynamic> toMap(){
    Map<String, dynamic> mapa = new Map();
    mapa[ID_KEY] = this.id;
    mapa[DESCRICAO_KEY] = this.descricao;
    mapa[STATUS_KEY] = this.status;
    return mapa;
  }

  @override
  bool operator ==(Object outro) {
    return (outro is Tarefa && outro.id == this.id);
  }

  @override
  String toString(){
    return "${this.id}: status(${this.status}): ${this.descricao}";
  }
  */
}