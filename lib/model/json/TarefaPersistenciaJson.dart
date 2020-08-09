import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import "package:path_provider/path_provider.dart";
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';
import 'IPersistenciaJSON.dart';

class TarefaPersistenciaJson implements ITarefaPersistencia{
  File _arquivo;
  File arquivoBackup;
  /// Classe que auxilia no salvamento e leitura de arquivos no formato JSON.
  IPersistenciaJSON _daoJson;
  /// Armazena todas as tarefas lidas do arquivo JSON.
  List<Tarefa> tarefas = new List();
  List<dynamic> tarefasJson = new List();

  static TarefaPersistenciaJson _instancia;

  /// Construtor acessado somente dentro da classe, para evitar que entidades fora daqui criem novas instãncias.
  TarefaPersistenciaJson._construtorPrivado() {
    this._daoJson = Modular.get<IPersistenciaJSON>();
  }

  factory TarefaPersistenciaJson(){
    TarefaPersistenciaJson._instancia ??= TarefaPersistenciaJson._construtorPrivado();
    return TarefaPersistenciaJson._instancia;
  }

  IPersistenciaJSON get daoJson => this._daoJson;

  Future<File> get arquivo async{
    if( this._arquivo == null ){
      await this._configurar();
    }
    return this._arquivo;
  }

  void _configurar() async{
    await this._configurarArquivo();
    await this._carregarDadosDoArquivo();
  }

  void _configurarArquivo() async {
    if( this._arquivo != null ){
      return;
    }
    Directory pastaDeDocumentos = await getApplicationDocumentsDirectory();
    String path = "${pastaDeDocumentos.path}/${AppModule.nomeArquivoTarefas}";
    this._arquivo = new File( path );
  }

  void _carregarDadosDoArquivo() async {
    List<dynamic> resultado = await this.daoJson.lerArquivo(await this.arquivo);
    if(resultado != null){
      this.tarefasJson = resultado;
    }
    this._transfereDaListaJsonParaListaDeTarefas();
    //###########################################################
    print("Carregou dados do arquivo.");
    //###########################################################
  }

  Future<void> _salvarConteudoJsonNoArquivo() async {
    this.daoJson.salvarObjetoSubstituindoConteudo( (await this.arquivo), this.tarefasJson );
  }

  @override
  Future<void> cadastrarTarefa(Tarefa tarefa) async {
    tarefa.id = this.getProximoIdDisponivel();
    this.tarefasJson.add( TarefaJSON.toMap( tarefa ) );
    await this._salvarConteudoJsonNoArquivo();
  }

  @override
  Future<void> deletarTarefa(Tarefa tarefa) async {
    assert(tarefa != null, "Tentou deletar tarefa passando valor nulo.");
    assert(tarefa.id != null, "Tentou deletar tarefa passando valor com identificador nulo.");
    Map mapa = this._getTarefaMap( tarefa );
    if( mapa == null ){
      throw new Exception( "Tetou deletar tarefa, passando identificador inexistente" );
    }
    this.tarefasJson.remove( mapa );
    //this.tarefasJson.remove((mapAtual) => mapAtual[TarefaJSON.ID_COLUNA] == tarefa.id );
    await this._salvarConteudoJsonNoArquivo();
  }

  Map<String, dynamic> _getTarefaMap( Tarefa tarefa ){
    Map<String, dynamic> map;
    this.tarefasJson.forEach( (mapAtual) {
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
    await this._salvarConteudoJsonNoArquivo();
  }

  /// Transfere os dados da Lista Json para a lista de objetos Tarefa.
  void _transfereDaListaJsonParaListaDeTarefas(){
    this.tarefas.clear();
    this.tarefasJson.forEach( (element) {
      this.tarefas.add( TarefaJSON.fromMap( element ) );
    });
  }

  @override
  List<Tarefa> getAllTarefa() {
    this._transfereDaListaJsonParaListaDeTarefas();
    return this.tarefas;
  }

  int getProximoIdDisponivel() {
    int maior = 0;
    this.tarefasJson.forEach( (mapAtual) {
      int id = mapAtual[TarefaJSON.ID_COLUNA];
      if( id > maior ){
        maior = id;
      }
    });
    return (maior+1);
  }

  bool arquivoInstanciado(){
    return this._arquivo != null;
  }

}