import 'dart:io';

import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';

class Tarefa extends EntidadeDominio{
  String _nome;
  String descricao;
  int _status = Tarefa.ABERTA;
  bool arquivada = false;
  Tarefa _tarefaPai = null;
  DateTime _dataHoraCadastro = null;
  DateTime _dataHoraConclusao = null;

  static const int ABERTA = 1;
  static const int CONCLUIDA = 2;
  static List<int> statusValidos = <int> [ ABERTA, CONCLUIDA ];

  static const int LIMITE_TAMANHO_NOME = 70;

  Tarefa( String nome, this.descricao, {int id=0} ){
    this.id = id;
    this.nome = nome;
    this._dataHoraCadastro = DateTime.now();
  }

  DateTime get dataHoraCadastro => this._dataHoraCadastro;

  void set dataHoraCadastro(DateTime dataHoraCadastro){
    assert( dataHoraCadastro != null, "A data e hora de cadastro não podem ser nulas" );
    this._dataHoraCadastro = dataHoraCadastro;
  }

  int get status => this._status;

  void set status( int valor ){
    if( !Tarefa.statusValidos.contains( valor ) ){
      throw new Exception("Tentou passar para uma tarefa um status inválido: ${valor}");
    }
    this._status = valor;
  }

  String get nome => _nome;

  void set nome( String valor ){
    String msg = Tarefa.validarNome( valor );
    if( msg.length > 0 ){
      throw new Exception( msg );
    }
    this._nome = valor;
  }

  ///     Valida o valor passado como sendo um nome de uma tarefa. Se estiver tudo ok, retorna "", senão retorna uma
  /// string explicando os detalhes do erro.
  static String validarNome(String valor){
    if( valor == null || valor.length == 0 ){
      return "O nome de uma tarefa não pode ser vazio" ;
    }
    if( valor.length > Tarefa.LIMITE_TAMANHO_NOME ){
      return "Nome inválido. Tamanho ${valor.length}. Máximo permitido ${Tarefa.LIMITE_TAMANHO_NOME} caracteres.";
    }
    if( valor.trim().length == 0 ){
      return "Nome inválido. Não pode iniciar com espaços e precisa começar com uma letra";
    }
    if( !valor.startsWith( new RegExp(r'[A-Z]|[a-z]') ) ){
      return "Nome inválido. Precisa começar com uma letra";
    }
    return "";
  }

  DateTime get dataHoraConclusao => this._dataHoraConclusao;

  void set dataHoraConclusao(DateTime valor){
    if( valor != null ) {
      DateTime agora = DateTime.now();
      if ((valor.day - agora.day) > 0) {
        throw new Exception(
            "${valor} é posterior a data de hoje ${agora}. A data de conclusão não pode ser uma data futura");
      }
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

  ///     Retorna uma instância da classe Tarefa com o id passado como parâmetro, com um nome qualquer
  /// e com descrição null.
  static Tarefa gerarTarefaSomenteComId( int id ){
    return new Tarefa("nem nome", null, id: id);
  }



  /*

  @override
  bool operator ==(Object outro) {
    return (outro is Tarefa && outro.id == this.id);
  }

  */
}