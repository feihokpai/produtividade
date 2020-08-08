import 'dart:convert';
import 'dart:io';

class PersistenciaJson{
  File _arquivoSalvamento;

  PersistenciaJson( String pathArquivo ){
    this._arquivoSalvamento = new File( pathArquivo );
  }

  File get arquivoSalvamento{
    return this._arquivoSalvamento;
  }

  /// Lê o conteúdo completo do arquivo configurado e retorna uma String com o conteúdo.
  /// Lança exceção se o arquivo não tiver sido configurado corretamente ou se ocorrer erro de leitura.
  Future<List<dynamic>> lerArquivo() async{
    if( this.arquivoSalvamento == null) {
      throw new Exception("Não é possível ler os dados do arquivo JSON, porque ele não foi configurado.");
    }
    try{
        String conteudo = await this.arquivoSalvamento.readAsString();
        //###################################################################
        print("conteúdo do arquivo: ${conteudo}");
        //###################################################################
        return json.decode( conteudo );
    }catch( ex ){
      throw new Exception( "Erro na leitura do arquivo: ${ex}" );
    }
  }

  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarSubstituindoConteudo( String conteudo ){
    this.arquivoSalvamento.writeAsString( conteudo, mode: FileMode.write );
  }

  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarObjetoSubstituindoConteudo( dynamic objeto ){
    String conteudoString = json.encode( objeto );
    this.salvarSubstituindoConteudo( conteudoString );
  }

  /**     Salva no arquivo Json o conteúdo passado como parâmetro ao final do arquivo. Ou seja,
   *  não substitui o conteúdo. Apenas adiciona. */
  void salvarAdicionandoConteudo( String conteudo ){
    this.arquivoSalvamento.writeAsString( conteudo, mode: FileMode.append );
  }

}