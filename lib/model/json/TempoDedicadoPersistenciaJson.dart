import 'dart:io';

import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/json/GenericoPersistenciaJson.dart';
import 'package:registro_produtividade/model/json/TempoDedicadoJSON.dart';

class TempoDedicadoPersistenciaJson extends GenericoPersistenciaJson implements ITempoDedicadoPersistencia{

  List<TempoDedicado> _registrosTempoDedicado = new List();

  static TempoDedicadoPersistenciaJson _instance;

  TempoDedicadoPersistenciaJson._privado(): super(){
    super.nomeArquivo = AppModule.nomeArquivoTempoDedicado;
  }

  factory TempoDedicadoPersistenciaJson(){
    _instance ??= TempoDedicadoPersistenciaJson._privado();
    return _instance;
  }

  @override
  Future<File> get arquivo async{
   if( !super.arquivoFoiInstanciado() ){
     await this.configurarArquivo();
   }
   return super.arquivo;
  }

  List<TempoDedicado> get registrosTempoDedicado => this._registrosTempoDedicado;

  /// Se repassar null, apenas apaga todos os registros da lista. Não atribui null a ela.
  void set registrosTempoDedicado(List<TempoDedicado> registrosTempoDedicado){
    if( registrosTempoDedicado == null ){
      this._registrosTempoDedicado.clear();
    }else {
      this._registrosTempoDedicado = registrosTempoDedicado;
    }
  }

  @override
  void cadastrarTempo(TempoDedicado tempo) {
    assert(tempo != null, "Tentou cadastrar um registro de tempo com instância nula.");
    tempo.id = this._getProximoIdDisponivel( );
    this.listaJson.add( TempoDedicadoJSON.toMap( tempo ) );
    super.salvarConteudoJsonNoArquivo();
  }

  Map<String, dynamic> _getTempoDedicadoMapOuException( TempoDedicado tempo ){
    Map<String, dynamic> map;
    this.listaJson.forEach( (mapAtual) {
      if( mapAtual[TempoDedicadoJSON.ID_COLUNA] == tempo.id ){
        map = mapAtual;
      }
    });
    if( map == null ){
      throw new Exception( "Tentou executar uma operação sobre uma instância de tempo dedicado de identificador inexistente" );
    }
    return map;
  }

  @override
  void deletarTempo(TempoDedicado tempo) {
    this._assertsTempoDedicado( tempo );
    Map map = this._getTempoDedicadoMapOuException( tempo );
    this.listaJson.remove( map );
    super.salvarConteudoJsonNoArquivo();
  }

  @override
  void editarTempo(TempoDedicado tempo) {
    this._assertsTempoDedicado( tempo );
    Map map = this._getTempoDedicadoMapOuException( tempo );
    // Não checa se tempo.inicio é null, pois o setter e o contrutor da entidade impedem isso.
    map[ TempoDedicadoJSON.DT_INICIO_COLUNA ] = TempoDedicadoJSON.formatter.format( tempo.inicio );
    String dataFormatada = tempo.fim == null ?
      TempoDedicadoJSON.DATA_VAZIA : TempoDedicadoJSON.formatter.format( tempo.fim );
    map[ TempoDedicadoJSON.DT_FIM_COLUNA ] = dataFormatada;
    super.salvarConteudoJsonNoArquivo();
  }

  @override
  List<TempoDedicado> getAllTempoDedicado() {
    this._transfereDaListaJsonParaListaDeRegistros();
    return this.registrosTempoDedicado;
  }

  @override
  List<TempoDedicado> getTempoDedicado(Tarefa tarefa) {
    this._assertsTarefa( tarefa );
    this._transfereDaListaJsonParaListaDeRegistros();
    List<TempoDedicado> lista = new List();
    this.registrosTempoDedicado.forEach((element) {
      if( element.tarefa.id == tarefa.id ){
        lista.add( element );
      }
    });
    return lista;
  }

  @override
  List<TempoDedicado> getTempoDedicadoOrderByInicio(Tarefa tarefa) {
    List<TempoDedicado> lista = this.getTempoDedicado( tarefa );
    lista.sort();
    return lista.reversed.toList();
  }

  /// Transfere os dados da Lista Json para a lista de objetos Tarefa.
  void _transfereDaListaJsonParaListaDeRegistros(){
    this.registrosTempoDedicado.clear();
    this.listaJson.forEach( (element) {
      this.registrosTempoDedicado.add( TempoDedicadoJSON.fromMap( element ) );
    });
  }
  
  int _getProximoIdDisponivel(){
    int maior = 0;
    this.listaJson.forEach((mapAtual) {
      int id = mapAtual[TempoDedicadoJSON.ID_COLUNA];
      if( id > maior){
        maior = id;
      }
    });
    return maior+1;
  }

  void _assertsTempoDedicado(TempoDedicado tempo){
    assert( tempo != null, "Tentou realizar uma operação sobre um registro de tempo dedicado nulo" );
    assert( tempo.id != null, "Tentou realizar uma operação sobre um registro de tempo dedicado com identificador nulo" );
    assert( tempo.id > 0, "Tentou realizar uma operação sobre um registro de tempo dedicado com identificador inválido" );
  }

  void _assertsTarefa( Tarefa tarefa ){
    assert( tarefa != null, "Tentou retornar dados de registros de tempo, mas repassando tarefa nula" );
    assert( tarefa.id != null, "Tentou retornar dados de registros de tempo, mas repassando tarefa com identificador nulo" );
    assert( tarefa.id > 0, "Tentou retornar dados de registros de tempo, mas repassando tarefa com identificador inválido" );
  }

}