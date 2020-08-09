import 'dart:io';

abstract class IPersistenciaJSON{
  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarObjetoSubstituindoConteudo( File arquivo, dynamic objeto );

  /**     Apaga o conteúdo do arquivo Json e salva no lugar a string passada como parâmetro. */
  void salvarSubstituindoConteudo( File arquivo, String conteudo );

  /**     Salva no arquivo Json o conteúdo passado como parâmetro ao final do arquivo. Ou seja,
   *  não substitui o conteúdo. Apenas adiciona. */
  void salvarAdicionandoConteudo( File arquivo, String conteudo );

  /// Lê o conteúdo completo do arquivo configurado e retorna uma String com o conteúdo.
  /// Lança exceção se o arquivo não tiver sido configurado corretamente ou se ocorrer erro de leitura.
  Future<List<dynamic>> lerArquivo( File arquivo );

}