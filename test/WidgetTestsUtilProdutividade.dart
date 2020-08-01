import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/view/registros_cadastro_tela.dart';

import 'WidgetTestsUtil.dart';

enum TiposTelaTestesProdutividade{
  CADASTRO_TEMPO_DEDICADO,
  EDICAO_TEMPO_DEDICADO
}

// Classe para auxiliar nos testes do Projeto Produtividade.
/// A classe WidgetTestsUtil é mantida para ser independente do projeto.
abstract class WidgetTestsUtilProdutividade extends WidgetTestsUtil{
  WidgetTestsUtilProdutividade(String screenName) : super(screenName);

  Tarefa criarTarefaValida(){
    Tarefa tarefa = new Tarefa("aaa", "bbb");
    tarefa.id = 999;
    return tarefa;
  }

  /// Gera um objeto Tempo dedicado com início prenchido e fim null.
  TempoDedicado criarTempoDedicadoValido( {Tarefa tarefa} ){
    tarefa ??= this.criarTarefaValida();
    TempoDedicado tempo = new TempoDedicado( tarefa );
    tempo.inicio = new DateTime.now().subtract( new Duration(minutes: 30) );
  }

  /// [keysLista] tem como valores as keys em forma de string dos componentes que serão buscados.
  /// [nomeConjuntoTestes] será o nome que estará no começo da descrição do teste.
  /// [tipoTela] é o tipo de StatefulWidget que deve ser gerada para cada teste.
  /// [resultadoEsperado] é o que se espera em relação a esses componentes. Caso true, testará
  ///     o findsOneWidget. caso false, testa o findsNothing.
  void checarSeComponentesEstaoPresentes( List<String> keysLista, String nomeConjuntoTestes,
      {TiposTelaTestesProdutividade tipoTela, StatefulWidget telaPronta,bool criarTestesIndividuais=true} ){
    this._checarComponentes(keysLista, nomeConjuntoTestes, true, tipoTela: tipoTela,
        telaPronta: telaPronta, criarTestesIndividuais: criarTestesIndividuais);
  }

  /// [keysLista] tem como valores as keys em forma de string dos componentes que serão buscados.
  /// [nomeConjuntoTestes] será o nome que estará no começo da descrição do teste.
  /// [tipoTela] é o tipo de StatefulWidget que deve ser gerada para cada teste.
  /// [resultadoEsperado] é o que se espera em relação a esses componentes. Caso true, testará
  ///     o findsOneWidget. caso false, testa o findsNothing.
  void checarSeComponentesEstaoOcultos( List<String> keysLista, String nomeConjuntoTestes,
      {TiposTelaTestesProdutividade tipoTela, StatefulWidget telaPronta,bool criarTestesIndividuais=true}  ){
    this._checarComponentes(keysLista, nomeConjuntoTestes, false, tipoTela: tipoTela,
        telaPronta: telaPronta, criarTestesIndividuais: criarTestesIndividuais);
  }

  void _checarComponentes( List<String> keysLista, String nomeConjuntoTestes
      , bool resultadoEsperado, {TiposTelaTestesProdutividade tipoTela, StatefulWidget telaPronta,
        bool criarTestesIndividuais=true}){
    String descricaoEsperada = (resultadoEsperado ? "presente" : "oculto" );
    StatefulWidget tela = telaPronta ?? this.criarTelaPorTipo( tipoTela );
    keysLista.forEach( ( keyString ) {
      if(criarTestesIndividuais) {
        super.criarTeste( "${nomeConjuntoTestes}: Testa se item ${keyString} está ${descricaoEsperada}", tela, () {
          this.testarDescoberta(resultadoEsperado, keyString);
        });
      }else{
        this.testarDescoberta(resultadoEsperado, keyString);
      }
    });
  }

  void testarDescoberta(bool resultadoEsperado, String keyString){
    if( resultadoEsperado == false ) {
      expect(find.byKey(new ValueKey(keyString)), findsNothing);
    }else if( resultadoEsperado == true ){
      expect(find.byKey(new ValueKey(keyString)), findsOneWidget);
    }
  }

  StatefulWidget criarTelaPorTipo(TiposTelaTestesProdutividade tipoTela) {
    if( tipoTela == TiposTelaTestesProdutividade.CADASTRO_TEMPO_DEDICADO ){
      return new CadastroTempoDedicadoTela( this.criarTarefaValida() );
    }else if( tipoTela == TiposTelaTestesProdutividade.EDICAO_TEMPO_DEDICADO ){
      return new CadastroTempoDedicadoTela.modoEdicao( this.criarTarefaValida(),
          new TempoDedicado(this.criarTarefaValida() ) );
    }
  }

}