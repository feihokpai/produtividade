import 'dart:io';

import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';

class Tarefa extends EntidadeDominio{
  String _nome;
  String descricao;
  int _status = Tarefa.ABERTA;
  bool arquivada = false;
  Tarefa _tarefaPai = null;
  DateTime _dataHoraCadastro = null;
  DateTime _dataHoraConclusao = null;
  List<TempoDedicado> _temposDedicados = new List();

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

  static void _assertsCompareByCreationDate(Tarefa tarefa1, Tarefa tarefa2){
    String msg = "Tentou comparar as datas de criação de duas tarefas, mas não foi possível porque ";
    String msgTarefaNull = msg+"alguma das tarefas foi passada como null. ${tarefa1} e ${tarefa2}";
    assert(tarefa1 != null && tarefa2 != null, msgTarefaNull );

    String msgDataCadastroNull = msg+"alguma das tarefas foi passada sem data de cadastro."
        " Valores: ${tarefa1.dataHoraCadastro} e ${tarefa2.dataHoraCadastro}";
    assert(tarefa1.dataHoraCadastro != null && tarefa2.dataHoraCadastro != null, msgDataCadastroNull );
  }

  /// Receives 2 Tarefa objects and returns:
  /// -1: if tarefa1 was created before tarefa2
  /// 0: if tarefa1 was created in same moment to tarefa2
  /// 1: if tarefa1 was created after tarefa2
  /// UPDATED TEST - 06/09/2020
  static int compareByCreationDate(Tarefa tarefa1, Tarefa tarefa2){
    Tarefa._assertsCompareByCreationDate(tarefa1, tarefa2);
    DateTime data1 = tarefa1.dataHoraCadastro;
    DateTime data2 = tarefa2.dataHoraCadastro;
    return data1.compareTo( data2 );
  }

  /// TODO Teste de unidade
  static int compareByCreationDateAndTimeRegister(Tarefa tarefa1, Tarefa tarefa2){
    DateTime data1 = tarefa1.getRegistroMaisrecente();
    DateTime data2 = tarefa2.getRegistroMaisrecente();
    return data1.compareTo( data2 );
  }

  ///     Se a tarefa não tiver tempos registrados, retorna a data/hora de criação da tarefa. Se tiver tempos registrados,
  /// retorna a data/hora de início do último registro de tempo dela.
  /// TODO teste de unidade
  DateTime getRegistroMaisrecente(){
    TempoDedicado ultimoTempo = this.getUltimoRegistroDeTempo();
    return ultimoTempo != null ? ultimoTempo.inicio : this.dataHoraCadastro;
  }

  ///     Caso a tarefa não tenha registros de tempo retorna null. Se tiver, retorna o último registro de tempo
  /// feito para ela.
  /// TODO Teste de unidade
  TempoDedicado getUltimoRegistroDeTempo(){
    if( this.temposDedicados.length == 0 ) {
      return null;
    }else{
      this.temposDedicados.sort();
      return this.temposDedicados.last;
    }
  }

  ///     Retorna uma instância da classe Tarefa com o id passado como parâmetro, com um nome qualquer
  /// e com descrição null.
  static Tarefa gerarTarefaSomenteComId( int id ){
    return new Tarefa("nem nome", null, id: id);
  }

  ///     You consider that a task is equals to other, if the id is different from zero and the both
  /// "ids" are equals;
  @override
  bool operator ==(Object other) {
    return (other is Tarefa
        && other.id != 0
        && this.id != 0
        && other.id == this.id);
  }

  List<TempoDedicado> get temposDedicados => this._temposDedicados;

  void set temposDedicados(List<TempoDedicado> temposDedicados){
    this._temposDedicados = temposDedicados ?? new List();
  }

  /// TODO teste de unidade
  void addTempoDedicado( TempoDedicado tempo ){
    assert(tempo != null, "Tentou adicionar um tempo dedicado a uma tarefa, mas passou valor null");
    this.temposDedicados.add( tempo );
  }

}