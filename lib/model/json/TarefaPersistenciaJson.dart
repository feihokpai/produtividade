import 'dart:convert';
import 'dart:io';
import "package:path_provider/path_provider.dart";
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/model/json/PersistenciaJSON.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';

class TarefaPersistenciaJson extends ITarefaPersistencia{
  /// Nome do arquivo onde os dados serão salvos
  String nomeArquivo = "tarefa.json";
  /// Nome do arquivo onde o backup será salvo
  String nomeArquivoBackup = "tarefa_backup.json";
  /// Classe que auxilia no salvamento e leitura de arquivos no formato JSON.
  PersistenciaJson _daoJson;
  /// Armazena todas as tarefas lidas do arquivo JSON.
  List<Tarefa> tarefas = new List();
  List<dynamic> tarefasJson = new List();

  static TarefaPersistenciaJson _instancia;

  /// Construtor acessado somente dentro da classe, para evitar que entidades fora daqui criem novas instãncias.
  TarefaPersistenciaJson._construtorPrivado() {
    this._configurar();
  }

  void _configurar() async{
    Directory pastaDeDocumentos = await getApplicationDocumentsDirectory();
    String path = "${pastaDeDocumentos.path}/${nomeArquivo}";
    this._daoJson = new PersistenciaJson( path );
    this._carregarDadosDoArquivo();
  }

  factory TarefaPersistenciaJson(){
    TarefaPersistenciaJson._instancia ??= TarefaPersistenciaJson._construtorPrivado();
    return TarefaPersistenciaJson._instancia;
  }

  PersistenciaJson get daoJson => this._daoJson;

  void _carregarDadosDoArquivo() async{
    this.tarefasJson = await this.daoJson.lerArquivo();
    this._preencherListaDeTarefas();
    //###########################################################
    print("Carregou dados do banco");
    //###########################################################
  }

  @override
  void cadastrarTarefa(Tarefa tarefa) {
    tarefa.id = this.getProximoIdDisponivel();
    this.tarefasJson.add( TarefaJSON.toMap( tarefa ) );
    this.daoJson.salvarObjetoSubstituindoConteudo( this.tarefasJson );
  }

  @override
  void deletarTarefa(Tarefa tarefa) {
    this.tarefasJson.removeWhere((mapAtual) => mapAtual[TarefaJSON.ID_COLUNA] == tarefa.id );
  }

  @override
  void editarTarefa(Tarefa tarefa) {
    this.tarefasJson.forEach((mapAtual) {
      if( mapAtual[TarefaJSON.ID_COLUNA] == tarefa.id ){
        mapAtual[TarefaJSON.NOME_COLUNA] = tarefa.nome;
        mapAtual[TarefaJSON.DESCRICAO_COLUNA] = tarefa.descricao;
      }
    });
    this.daoJson.salvarObjetoSubstituindoConteudo( this.tarefasJson );
  }

  void _preencherListaDeTarefas(){
    this.tarefas.clear();
    this.tarefasJson.forEach( (element) {
      this.tarefas.add( TarefaJSON.fromMap( element ) );
    });
  }

  @override
  List<Tarefa> getAllTarefa() {
    this._preencherListaDeTarefas();
    return this.tarefas;
  }

  int getProximoIdDisponivel() {
    this._preencherListaDeTarefas();
    int maior = 0;
    this.tarefas.forEach( (tarefa) {
      if( tarefa.id > maior ){
        maior = tarefa.id;
      }
    });
    return (maior+1);
  }

}