import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:path_provider/path_provider.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';
import 'package:registro_produtividade/model/json/GenericJsonConverter.dart';
import 'IPersistenciaJSON.dart';

abstract class GenericoPersistenciaJson{

  String nomeArquivo;
  String nomeArquivoBackup;

  GenericJsonConverter jsonConverter;

  File _arquivo;
  /// Classe que auxilia no salvamento e leitura de arquivos no formato JSON.
  IPersistenciaJSON _daoJson;

  List<Map<String, dynamic>> listaJson = new List();

  List<EntidadeDominio> _entidades = new List();

  GenericoPersistenciaJson( GenericJsonConverter jsonConverter, String nomeArquivo ){
    this.nomeArquivo = nomeArquivo;
    this.jsonConverter = jsonConverter;
    this._daoJson = Modular.get<IPersistenciaJSON>();
  }

  List<EntidadeDominio> get entidades => this._entidades;

  void set entidades(List<EntidadeDominio> entidades){
    this._entidades = entidades;
  }

  bool arquivoFoiInstanciado() => this._arquivo != null ;

  Future<File> get arquivo async{
    if( !this.arquivoFoiInstanciado() ){
      await this.configurarArquivo();
    }
    return this._arquivo;
  }

  IPersistenciaJSON get daoJson => this._daoJson;

  void set daoJson(IPersistenciaJSON daoJson){
    this._daoJson = daoJson;
  }

  Future<void> configurarArquivo() async{
    await this._instanciarArquivo();
    await this._criarArquivoFisico();
    await this._carregarDadosDoArquivo();
  }

  Future<void> configurarArquivoSeNaoConfigurado() async{
    bool existe = await this._arquivoFisicoExiste();
    if( !existe ){
      await this.configurarArquivo();
    }
  }

  Future<void> salvarConteudoJsonNoArquivo() async {
    bool existe = await this._arquivoFisicoExiste();
    if( !existe ){
      throw new Exception( "Tentou salvar os dados da lista JSON nu arquivo, mas o arquivo não"
          " foi instanciado ou não foi criado." );
    }
    this.daoJson.salvarObjetoSubstituindoConteudo(this._arquivo, this.listaJson );
  }

  Map<String, dynamic> getEntidadeMap( EntidadeDominio entidade ){
    Map<String, dynamic> map;
    this.listaJson.forEach( (mapAtual) {
      if( mapAtual[this.jsonConverter.nomeColunaId] == entidade.id ){
        map = mapAtual;
      }
    });
    return map;
  }

  Map<String, dynamic> getEntidadeMapOrThrowException( EntidadeDominio entidade ){
    Map map = this.getEntidadeMap( entidade );
    if( map == null ){
      throw new Exception( "Tentou obter uma entidade, repassando um identificador inexistente" );
    }
    return map;
  }

  /// Transfere os dados da Lista Json para a lista de objetos EntidadeDominio.
  Future<void> transfereDaListaJsonParaListaDeEntidades() async{
    await this.configurarArquivoSeNaoConfigurado();
    this.entidades.clear();
    this.listaJson.forEach( (element) {
      this.entidades.add( this.jsonConverter.fromMap( element ) );
    });
  }

  Future<List<T>> getAllEntidade<T extends EntidadeDominio>() async {
    await this.transfereDaListaJsonParaListaDeEntidades();
    return this._converterListEntidadesParaListSubclasse<T>( this.entidades );
  }

  Future<List<T>> getEntidadesPorId<T extends EntidadeDominio>(List<int> ids) async {
    await this.transfereDaListaJsonParaListaDeEntidades();
    List<EntidadeDominio> listaFiltrada = new List();
    listaFiltrada.addAll( this.entidades.where((entidade) =>  ids.contains( entidade.id ) ) );
    return this._converterListEntidadesParaListSubclasse<T>( listaFiltrada );
  }

  Future<void> cadastrarEntidade(EntidadeDominio entidade) async {
    entidade.id = this.getProximoIdDisponivel();
    this.listaJson.add( this.jsonConverter.toMap( entidade ) );
    await this.salvarConteudoJsonNoArquivo();
  }

  Future<void> editarEntidade(EntidadeDominio entidade) async {
    Map mapaEntidadeParametro = this.jsonConverter.toMap( entidade );
    Map mapaEntidadeCadastrada = this.getEntidadeMapOrThrowException( entidade );
    this.jsonConverter.columnsList().forEach((nomeColuna) {
      mapaEntidadeCadastrada[ nomeColuna ] = mapaEntidadeParametro[ nomeColuna ];
    });
    await this.salvarConteudoJsonNoArquivo();
  }

  Future<void> deletarEntidade(EntidadeDominio entidade) async {
    Map mapa = this.getEntidadeMap( entidade );
    if( mapa == null ){
      throw new Exception( "Tetou deletar uma entidade, passando identificador inexistente" );
    }
    this.listaJson.remove( mapa );
    await this.salvarConteudoJsonNoArquivo();
  }

  /// Função que retorna o próximo id disponível para cadastrar uma entidade
  int getProximoIdDisponivel(){
    int maior = 0;
    this.listaJson.forEach( (mapAtual) {
      int id = mapAtual[ this.jsonConverter.nomeColunaId ];
      if( id > maior ){
        maior = id;
      }
    });
    return (maior+1);
  }

  Future<String> _pathDiretorioArquivos() async{
    Directory pastaDeDocumentos = await getApplicationDocumentsDirectory();
    String path = pastaDeDocumentos.path;
    return path;
  }

  Future<void> _instanciarArquivo() async {
    if( this.nomeArquivo == null ){
      throw new Exception( "Tentou instanciar o arquivo para persistência, mas não configurou o nome do"
          " mesmo." );
    }
    if( this._arquivo != null ){
      return;
    }
    String pathDiretorio = await this._pathDiretorioArquivos();
    String pathCompleto = pathDiretorio+"/"+this.nomeArquivo;
    this._arquivo = new File( pathCompleto );
  }

  Future<bool> _arquivoFisicoExiste()async{
    if( !this.arquivoFoiInstanciado() ){
      return false;
    }
    return await this._arquivo.exists();
  }

  Future<void> _criarArquivoFisico() async {
    bool existe = await this._arquivoFisicoExiste();
    if( !existe ){
      this._arquivo = await this._arquivo.create();
    }
  }

  void _carregarDadosDoArquivo() async {
    bool arquivoFisicoExiste = await this._arquivoFisicoExiste();
    if( !arquivoFisicoExiste ){
      throw new Exception( "Tentou ler os dados de um arquivo que não foi criado" );
    }
    var resultado = await this.daoJson.lerArquivo(await this.arquivo);
    if( resultado != null ){
      this.listaJson = resultado;
    }
  }

  /// Recebe uma lista de entidades e devolve a mesma convertida numa lista do tipo T, que é subclasse de EntidadeDominio
  List<T> _converterListEntidadesParaListSubclasse<T extends EntidadeDominio>( List<EntidadeDominio> listEntidades ){
    List<T> lista = new List();
    listEntidades.forEach((entidade) {
      T entidadeTipoReal = entidade as T;
      lista.add( entidadeTipoReal );
    });
    return lista;
  }
}