import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'IPersistenciaJSON.dart';

class GenericoPersistenciaJson{

  String nomeArquivo;
  String nomeArquivoBackup;

  File _arquivo;
  /// Classe que auxilia no salvamento e leitura de arquivos no formato JSON.
  IPersistenciaJSON _daoJson;

  List<Map<String, dynamic>> listaJson = new List();

  GenericoPersistenciaJson(){
    this._daoJson = Modular.get<IPersistenciaJSON>();
  }

  bool arquivoFoiInstanciado() => this._arquivo != null ;

  Future<File> get arquivo async{
    return this._arquivo;
  }

  IPersistenciaJSON get daoJson => this._daoJson;

  void set daoJson(IPersistenciaJSON daoJson){
    this._daoJson = daoJson;
  }

  Future<void> configurarArquivo() async{
    await this._instanciarArquivo();
    await this._criarArquivoFisico();
  }

  void salvarConteudoJsonNoArquivo(){
    this.daoJson.salvarObjetoSubstituindoConteudo(this._arquivo, this.listaJson );
  }

  Future<String> _pathDiretorioArquivos() async{
    Directory pastaDeDocumentos = await getApplicationDocumentsDirectory();
    String path = pastaDeDocumentos.path;
    return path;
  }

  Future<void> _instanciarArquivo() async {
    String pathDiretorio = await this._pathDiretorioArquivos();
    String pathCompleto = pathDiretorio+"/"+this.nomeArquivo;
    this._arquivo = new File( pathCompleto );
  }

  Future<void> _criarArquivoFisico() async {
    bool existe = await this._arquivo.exists();
    if( !existe ){
      this._arquivo = await this._arquivo.create();
    }
  }
}