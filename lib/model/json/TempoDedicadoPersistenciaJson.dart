import 'dart:io';

import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITempoDedicadoPersistencia.dart';
import 'package:registro_produtividade/model/json/GenericoPersistenciaJson.dart';
import 'package:registro_produtividade/model/json/TempoDedicadoJSON.dart';

class TempoDedicadoPersistenciaJson extends GenericoPersistenciaJson implements ITempoDedicadoPersistencia{

  static TempoDedicadoPersistenciaJson _instance;

  TempoDedicadoPersistenciaJson._privado()
      : super( new TempoDedicadoJSON(), AppModule.nomeArquivoTempoDedicado ){
  }

  factory TempoDedicadoPersistenciaJson(){
    _instance ??= TempoDedicadoPersistenciaJson._privado();
    return _instance;
  }

  @override
  void set entidades( List<EntidadeDominio> entidades ){
    if( entidades == null ){
      this.entidades.clear();
    }else {
      this.entidades = entidades;
    }
  }

  @override
  Future<void> cadastrarTempo(TempoDedicado tempo) async {
    assert(tempo != null, "Tentou cadastrar um registro de tempo com instância nula.");
    await super.cadastrarEntidade( tempo );
  }

  @override
  Future<void> deletarTempo(TempoDedicado tempo) async {
    this._assertsTempoDedicado( tempo );
    await super.deletarEntidade( tempo );
  }

  @override
  Future<void> editarTempo(TempoDedicado tempo) async {
    this._assertsTempoDedicado( tempo );
    await super.editarEntidade( tempo );
  }

  @override
  Future<List<TempoDedicado>> getAllTempoDedicado() async{
    return super.getAllEntidade<TempoDedicado>();
  }

  @override
  Future<List<TempoDedicado>> getTempoDedicado(Tarefa tarefa) async {
    this._assertsTarefa( tarefa );
    await super.transfereDaListaJsonParaListaDeEntidades();
    List<TempoDedicado> lista = new List();
    this.entidades.forEach((element) {
      TempoDedicado tempo = element as TempoDedicado;
      if( tempo.tarefa.id == tarefa.id ){
        lista.add( tempo );
      }
    });
    return lista;
  }

  @override
  Future<List<TempoDedicado>> getTempoDedicadoOrderByInicio(Tarefa tarefa) async {
    List<TempoDedicado> lista = await this.getTempoDedicado( tarefa );
    lista.sort();
    return lista.reversed.toList();
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