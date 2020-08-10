import 'dart:io';
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/model/json/GenericoPersistenciaJson.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';

class TarefaPersistenciaJson extends GenericoPersistenciaJson implements ITarefaPersistencia{
  /// Armazena todas as tarefas lidas do arquivo JSON.
  List<Tarefa> tarefas = new List();

  static TarefaPersistenciaJson _instancia;

  /// Construtor acessado somente dentro da classe, para evitar que entidades fora daqui criem novas instãncias.
  TarefaPersistenciaJson._construtorPrivado()
      :super( new TarefaJSON() , AppModule.nomeArquivoTarefas ){
  }

  factory TarefaPersistenciaJson(){
    TarefaPersistenciaJson._instancia ??= TarefaPersistenciaJson._construtorPrivado();
    return TarefaPersistenciaJson._instancia;
  }

  Future<File> get arquivo async{
    if( !super.arquivoFoiInstanciado() ){
      await super.configurarArquivo();
    }
    return super.arquivo;
  }

  void _carregarDadosDoArquivo() async {
    List<dynamic> resultado = await this.daoJson.lerArquivo(await this.arquivo);
    if(resultado != null){
      this.listaJson = resultado;
    }
    this._transfereDaListaJsonParaListaDeTarefas();
    //###########################################################
    print("Carregou dados do arquivo.");
    //###########################################################
  }

  @override
  Future<void> cadastrarTarefa(Tarefa tarefa) async {
    tarefa.id = this.getProximoIdDisponivel();
    this.listaJson.add( super.jsonConverter.toMap( tarefa ) );
    await super.salvarConteudoJsonNoArquivo();
  }

  @override
  Future<void> deletarTarefa(Tarefa tarefa) async {
    assert(tarefa != null, "Tentou deletar tarefa passando valor nulo.");
    assert(tarefa.id != null, "Tentou deletar tarefa passando valor com identificador nulo.");
    Map mapa = this._getTarefaMap( tarefa );
    if( mapa == null ){
      throw new Exception( "Tetou deletar tarefa, passando identificador inexistente" );
    }
    this.listaJson.remove( mapa );
    //this.tarefasJson.remove((mapAtual) => mapAtual[TarefaJSON.ID_COLUNA] == tarefa.id );
    await super.salvarConteudoJsonNoArquivo();
  }

  Map<String, dynamic> _getTarefaMap( Tarefa tarefa ){
    Map<String, dynamic> map;
    this.listaJson.forEach( (mapAtual) {
      if( mapAtual[TarefaJSON.ID_COLUNA] == tarefa.id ){
        map = mapAtual;
      }
    });
    return map;
  }

  @override
  Future<void> editarTarefa(Tarefa tarefa) async {
    assert( tarefa != null, "Foi chamada a operação de edição de Tarefa, sem repassar a Tarefa.");
    assert( tarefa.id != null, "Foi chamada a operação de edição de Tarefa, mas sem um número identificador.");
    assert( tarefa.id > 0, "Foi chamada a operação de edição de Tarefa, com um identificador inválido." );

    Map mapa = this._getTarefaMap( tarefa );
    if( mapa == null ){
      throw new Exception( "Foi chamada a operação de edição de Tarefa, com um identificar inexistente" );
    }
    mapa[TarefaJSON.NOME_COLUNA] = tarefa.nome;
    mapa[TarefaJSON.DESCRICAO_COLUNA] = tarefa.descricao;
    await super.salvarConteudoJsonNoArquivo();
  }

  /// Transfere os dados da Lista Json para a lista de objetos Tarefa.
  void _transfereDaListaJsonParaListaDeTarefas(){
    this.tarefas.clear();
    this.listaJson.forEach( (element) {
      this.tarefas.add( super.jsonConverter.fromMap( element ) );
    });
  }

  @override
  List<Tarefa> getAllTarefa() {
    this._transfereDaListaJsonParaListaDeTarefas();
    return this.tarefas;
  }

  int getProximoIdDisponivel() {
    int maior = 0;
    this.listaJson.forEach( (mapAtual) {
      int id = mapAtual[TarefaJSON.ID_COLUNA];
      if( id > maior ){
        maior = id;
      }
    });
    return (maior+1);
  }

}