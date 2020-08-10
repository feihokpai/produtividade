import 'dart:convert';
import 'dart:io';

import 'package:registro_produtividade/model/json/IPersistenciaJSON.dart';

class PersistenciaJson implements IPersistenciaJSON{
  PersistenciaJson(  ){
  }

  /// Lê o conteúdo completo do arquivo configurado e retorna uma String com o conteúdo.
  /// Lança exceção se o arquivo não tiver sido configurado corretamente ou se ocorrer erro de leitura.
  Future< List<Map<String, dynamic>> > lerArquivo(File arquivo) async{
    assert(arquivo != null, "Não é possível ler os dados do arquivo JSON, porque ele não foi repassado.");
    try{
        String conteudo = await arquivo.readAsString();
        //###################################################################
        print("conteúdo do arquivo: ${conteudo}");
        //###################################################################
        List<dynamic> resultado = json.decode( conteudo );
        return this._converterEmMap( resultado );
    }catch( ex ){
      throw new Exception( "Erro na leitura do arquivo: ${ex}" );
    }
  }

  List<Map<String, dynamic>> _converterEmMap(List<dynamic> lista){
    List<Map<String, dynamic>> listMap = new List();
    lista.forEach((element) {
      Map mapa = element as Map<String, dynamic>;
      listMap.add( mapa );
    });
    return listMap;
  }

  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarSubstituindoConteudo( File arquivo, String conteudo ){
    arquivo.writeAsString( conteudo, mode: FileMode.write );
  }

  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarObjetoSubstituindoConteudo( File arquivo, dynamic objeto ){
    String conteudoString = json.encode( objeto );
    this.salvarSubstituindoConteudo( arquivo, conteudoString );
  }

  /**     Salva no arquivo Json o conteúdo passado como parâmetro ao final do arquivo. Ou seja,
   *  não substitui o conteúdo. Apenas adiciona. */
  void salvarAdicionandoConteudo( File arquivo, String conteudo ){
    arquivo.writeAsString( conteudo, mode: FileMode.append );
  }

}