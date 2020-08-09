
import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:mockito/mockito.dart';
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/model/json/IPersistenciaJSON.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';
import 'package:registro_produtividade/model/json/TempoDedicadoJSON.dart';
import 'package:registro_produtividade/model/json/TempoDedicadoPersistenciaJson.dart';

import '../TestsUtilProdutividade.dart';

void main(){
  new TempoDedicadoPersistenciaJson_test().runAll();
}

class _PersistenciaJSONMock extends Mock implements IPersistenciaJSON{
  // Não precisa ter nada.
}

class TempoDedicadoPersistenciaJson_test extends TestsUtilProdutividade{

  TempoDedicadoPersistenciaJson_test(){
    this._configuration();
  }

  void _configuration(){
    initModule(
        AppModule(),
        changeBinds: [
          Bind<IPersistenciaJSON>((i) => new _PersistenciaJSONMock() ),
        ]
    );
  }

  TempoDedicado criarTempoValido({int id=0}){
    return super.criarTempoDedicadoValidoComVariosDados(super.criarTarefaValida(), id, 20);
  }

  TempoDedicadoPersistenciaJson criarPersistenciaListasVazias(){
    TempoDedicadoPersistenciaJson obj =  new TempoDedicadoPersistenciaJson();
    obj.listaJson.clear();
    obj.registrosTempoDedicado.clear();
    return obj;
  }

  Future<TempoDedicadoPersistenciaJson> criarPersistenciaComRegistrosCadastrados(int qtd) async{
    TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
    for(int i=0; i<qtd; i++){
      await obj.cadastrarTempo( this.criarTempoValido() );
    }
    return obj;
  }

  void runAll(){
    this.testesBasicos();
    this.testesCadastrarTempo();
    this.testesEditarTempo();
    this.testesDeletarTempo();
    this.testesGetAllTempoDedicado();
    this.testesGetTempoDedicado();
    this.testesGetTempoDedicadoOrderByInicio();
  }

  void testesBasicos() {
    test("Tempo dedicado persistência JSON: o construtor retorna sempre o mesmo objeto?", (){
      TempoDedicadoPersistenciaJson tempo = new TempoDedicadoPersistenciaJson();
      TempoDedicadoPersistenciaJson tempo2 = new TempoDedicadoPersistenciaJson();
      TempoDedicadoPersistenciaJson tempo3 = new TempoDedicadoPersistenciaJson();
      TempoDedicadoPersistenciaJson tempo4 = new TempoDedicadoPersistenciaJson();
      expect( tempo, tempo2 );
      expect( tempo, tempo3 );
      expect( tempo, tempo4 );
    });

    test("Tempo dedicado persistência JSON: Construtor: o arquivo NÃO foi instanciado?", () async{
      TempoDedicadoPersistenciaJson obj = new TempoDedicadoPersistenciaJson();
      bool instanciou = await Future.delayed(new Duration( seconds: 3 ), (){
          return obj.arquivoFoiInstanciado();
      });
      expect( instanciou , false );
    });

    test("Tempo dedicado persistência JSON: Se chamar o getter de arquivo, instancia?", () async {
      TempoDedicadoPersistenciaJson obj = new TempoDedicadoPersistenciaJson();
      File arquivo = await obj.arquivo;
      expect( arquivo , isNotNull );
    });

  }

  void testesCadastrarTempo() {
    test("Tempo dedicado persistência JSON: Cadastrar - Passando registro null, dá erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      expect( ()=> obj.cadastrarTempo( null ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Cadastrar - cria um registro na lista de Maps?", () async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      await obj.cadastrarTempo( this.criarTempoValido() );
      expect( obj.listaJson.length , 1 );
    });

    test("Tempo dedicado persistência JSON: Cadastrar - repassa o pedido para o Mock salvar no arquivo?", () async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      await obj.cadastrarTempo( this.criarTempoValido() );
      verify( obj.daoJson.salvarObjetoSubstituindoConteudo(any, obj.listaJson ) );
    });

    test("Tempo dedicado persistência JSON: Cadastrar - cria um Map com dados corretos?", () async {
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      TempoDedicado tempo = this.criarTempoValido();
      Map mapTempo = TempoDedicadoJSON.toMap( tempo );
      await obj.cadastrarTempo( tempo );
      expect( obj.listaJson[ 0 ][ TempoDedicadoJSON.ID_COLUNA] , 1 );
      expect( obj.listaJson[ 0 ][ TempoDedicadoJSON.ID_TAREFA_COLUNA] , mapTempo[TempoDedicadoJSON.ID_TAREFA_COLUNA]);
      expect( obj.listaJson[ 0 ][ TempoDedicadoJSON.DT_INICIO_COLUNA] , mapTempo[TempoDedicadoJSON.DT_INICIO_COLUNA]);
      expect( obj.listaJson[ 0 ][ TempoDedicadoJSON.DT_FIM_COLUNA] , mapTempo[TempoDedicadoJSON.DT_FIM_COLUNA]);
    });

    test("Tempo dedicado persistência JSON: Cadastrar - cria ids sequênciais e atribui eles no Map?", ()async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      await obj.cadastrarTempo( this.criarTempoValido() );
      await obj.cadastrarTempo( this.criarTempoValido() );
      await obj.cadastrarTempo( this.criarTempoValido() );
      expect( obj.listaJson[0][TempoDedicadoJSON.ID_COLUNA] , 1);
      expect( obj.listaJson[1][TempoDedicadoJSON.ID_COLUNA] , 2);
      expect( obj.listaJson[2][TempoDedicadoJSON.ID_COLUNA] , 3);
    });

    test("Tempo dedicado persistência JSON: Cadastrar - adiciona no Map, mas não na Lista de Tempo?", ()async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      await obj.cadastrarTempo( this.criarTempoValido() );
      await obj.cadastrarTempo( this.criarTempoValido() );
      expect( obj.listaJson.length , 2);
      expect( obj.registrosTempoDedicado.length , 0);
    });
  }

  void testesEditarTempo() {
    test("Tempo dedicado persistência JSON: Editar - passando parâmetro null, gera erro de assert?", ()async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      expect( ()=> obj.editarTempo( null ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Editar - passando tempo com id null, gera erro de assert?", ()async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      TempoDedicado tempo = this.criarTempoDedicadoValidoComVariosDados(this.criarTarefaValida(), null, 50);
      expect( ()=> obj.editarTempo( tempo ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Editar - passando tempo com id <= 0, gera erro de assert?", ()async{
      TempoDedicadoPersistenciaJson obj = this.criarPersistenciaListasVazias();
      expect( ()=> obj.editarTempo( this.criarTempoValido( id: 0 ) ), throwsAssertionError);
      expect( ()=> obj.editarTempo( this.criarTempoValido( id: -1 ) ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Editar - passando tempo com id inexistente gera Exception?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 2 );
      await expect( ()=> obj.editarTempo( this.criarTempoValido( id: 3 ) ), throwsException );
    });

    test("Tempo dedicado persistência JSON: Editar - passando tempo com id existente roda OK?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 2 );
      await obj.editarTempo( this.criarTempoValido( id: 2 ) );
    });

    test("Tempo dedicado persistência JSON: Editar - mantem a mesma quantidade no Map?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 2 );
      expect( obj.listaJson.length , 2);
      await obj.editarTempo( this.criarTempoValido( id: 2 ) );
      expect( obj.listaJson.length , 2);
    });

    test("Tempo dedicado persistência JSON: Editar - Altera o Map corretamente?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaListasVazias();
      TempoDedicado t1 = this.criarTempoValido();
      Map t1Map = TempoDedicadoJSON.toMap( t1 );
      String antigoInicio = TempoDedicadoJSON.formatter.format( t1.inicio );
      await obj.cadastrarTempo( t1 );
      expect( obj.listaJson[0][TempoDedicadoJSON.DT_INICIO_COLUNA] , antigoInicio );
      t1.inicio = t1.inicio.subtract( new Duration( hours: 2 ) );
      String novoInicio = TempoDedicadoJSON.formatter.format( t1.inicio );
      await obj.editarTempo( t1 );
      expect( obj.listaJson[0][TempoDedicadoJSON.DT_INICIO_COLUNA] , novoInicio);
    });

    test("Tempo dedicado persistência JSON: Editar - repassa a edição do arquivo para o Mock?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 3 );
      int qtdAntes = verify( obj.daoJson.salvarObjetoSubstituindoConteudo(any, any)  ).callCount;
      obj.editarTempo( this.criarTempoValido( id: 1 ) );
      obj.editarTempo( this.criarTempoValido( id: 2 ) );
      obj.editarTempo( this.criarTempoValido( id: 3 ) );
      int qtdAposAntes = verify( obj.daoJson.salvarObjetoSubstituindoConteudo(any, any)  ).callCount;
      expect( qtdAposAntes , 3 );
    });

    test("Tempo dedicado persistência JSON: Editar - edita no Map, mas não na Lista de tempo?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      await obj.getAllTempoDedicado();
      String dataFimFormatada = TempoDedicadoJSON.formatter.format( obj.registrosTempoDedicado[0].fim );
      expect( obj.listaJson[0][TempoDedicadoJSON.DT_FIM_COLUNA] , dataFimFormatada );
      TempoDedicado t1 = this.criarTempoValido( id: 1 );
      t1.fim = DataHoraUtil.criarDataHojeFimDoDia();
      await obj.editarTempo( t1 );
      dataFimFormatada = TempoDedicadoJSON.formatter.format( obj.registrosTempoDedicado[0].fim );
      expect( (obj.listaJson[0][TempoDedicadoJSON.DT_FIM_COLUNA] != dataFimFormatada), true );
    });
  }

  void testesDeletarTempo() {
    test("Tempo dedicado persistência JSON: Deletar - passando entidade null gera erro de Assert?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.deletarTempo( null ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Deletar - passando entidade com id null gera erro de Assert?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.deletarTempo( this.criarTempoValido( id: null ) ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Deletar - passando entidade com id <= 0 gera erro de Assert?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.deletarTempo( this.criarTempoValido( id: 0 ) ), throwsAssertionError);
      expect( ()=> obj.deletarTempo( this.criarTempoValido( id: -1 ) ), throwsAssertionError);
    });

    test("Tempo dedicado persistência JSON: Deletar - passando entidade com id inexistente no Map gera Exception?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 3 );
      expect( ()=> obj.deletarTempo( this.criarTempoValido( id: 4 ) ), throwsException );
    });

    test("Tempo dedicado persistência JSON: Deletar - passando id existente roda OK?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 3 );
      obj.deletarTempo( this.criarTempoValido( id: 3 ) );
    });

    test("Tempo dedicado persistência JSON: Deletar - deleta no Map, mas não na Lista de Tempo?", ()async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 3 );
      obj.getAllTempoDedicado();
      expect(obj.listaJson.length, obj.registrosTempoDedicado.length );
      obj.deletarTempo( this.criarTempoValido( id: 1 ) );
      expect( obj.listaJson.length, (obj.registrosTempoDedicado.length -1) );
    });
  }

  void testesGetAllTempoDedicado() {
    test("Tempo dedicado persistência JSON: getAllTempoDedicado() - carrega a lista de objetos TempoDedicado?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 3 );
      expect( obj.registrosTempoDedicado.length , 0);
      obj.getAllTempoDedicado();
      expect( obj.registrosTempoDedicado.length , 3);
    });

    test("Tempo dedicado persistência JSON: getAllTempoDedicado() - os dados carregados na lista de objetos TempoDedicado estão corretos?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      obj.getAllTempoDedicado();
      expect( obj.registrosTempoDedicado[0].id , obj.listaJson[0][TempoDedicadoJSON.ID_COLUNA]);
      expect( obj.registrosTempoDedicado[0].tarefa.id , obj.listaJson[0][TempoDedicadoJSON.ID_TAREFA_COLUNA]);
      DateTime inicioDateTime = TarefaJSON.formatter.parse( obj.listaJson[0][TempoDedicadoJSON.DT_INICIO_COLUNA] ) ;
      expect( obj.registrosTempoDedicado[0].inicio , inicioDateTime );
      DateTime fimDateTime = TarefaJSON.formatter.parse( obj.listaJson[0][TempoDedicadoJSON.DT_FIM_COLUNA] ) ;
      expect( obj.registrosTempoDedicado[0].fim , fimDateTime );
    });
  }

  void testesGetTempoDedicado() {
    test("Tempo dedicado persistência JSON: getTempoDedicado( Tarefa ) - passar entidade nula gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicado( null ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: getTempoDedicado( Tarefa ) - passar entidade com id null gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicado( this.criarTarefaValida( id: null ) ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: getTempoDedicado( Tarefa ) - passar entidade com id <=0 gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicado( this.criarTarefaValida( id: 0 ) ), throwsAssertionError );
      expect( ()=> obj.getTempoDedicado( this.criarTarefaValida( id: -1 ) ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: getTempoDedicado( Tarefa ) - passar entidade com id de Tarefa inexistente na lista de Maps, retorna lista vazia?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( obj.getTempoDedicado( this.criarTarefaValida( id: 2 ) ).length, 0 );
    });

    test("Tempo dedicado persistência JSON: getTempoDedicado( Tarefa ) - passar entidade com id de tarefa existente na lista de Maps, retorna os dados corretamente?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      obj.getTempoDedicado( this.criarTarefaValida( id: 1 ) );
    });

  }

  void testesGetTempoDedicadoOrderByInicio() {
    test("Tempo dedicado persistência JSON: testesGetTempoDedicadoOrderByInicio( Tarefa ) - passar entidade nula gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicadoOrderByInicio( null ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: testesGetTempoDedicadoOrderByInicio( Tarefa ) - passar entidade com id null gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicadoOrderByInicio( this.criarTarefaValida(id: null) ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: testesGetTempoDedicadoOrderByInicio( Tarefa ) - passar entidade com id <=0 gera erro de Assert?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( ()=> obj.getTempoDedicadoOrderByInicio( this.criarTarefaValida(id: 0) ), throwsAssertionError );
      expect( ()=> obj.getTempoDedicadoOrderByInicio( this.criarTarefaValida(id: -1) ), throwsAssertionError );
    });

    test("Tempo dedicado persistência JSON: testesGetTempoDedicadoOrderByInicio( Tarefa ) - passar entidade com id de Tarefa inexistente na lista de Maps, retorna lista vazia?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaComRegistrosCadastrados( 1 );
      expect( obj.getTempoDedicadoOrderByInicio( this.criarTarefaValida(id: 2) ).length, 0 );
    });

    test("Tempo dedicado persistência JSON: testesGetTempoDedicadoOrderByInicio( Tarefa ) - passar entidade com id de tarefa existente na lista de Maps, retorna os dados ORDENADOS corretamente?", () async{
      TempoDedicadoPersistenciaJson obj = await this.criarPersistenciaListasVazias();
      Tarefa ta1 = this.criarTarefaValida( id: 20 );
      // OBS: Os métodos abaixo criam o tempo de fim como sendo agora e o tempo de início baseado no
      // terceiro parâmetro.
      TempoDedicado tempo1 = this.criarTempoDedicadoValidoComVariosDados(ta1, null, 50);
      TempoDedicado tempo2 = this.criarTempoDedicadoValidoComVariosDados(ta1, null, 200);
      TempoDedicado tempo3 = this.criarTempoDedicadoValidoComVariosDados(ta1, null, 100);
      TempoDedicado tempo4 = this.criarTempoDedicadoValidoComVariosDados(ta1, null, 10);
      obj.cadastrarTempo( tempo1 );
      obj.cadastrarTempo( tempo2 );
      obj.cadastrarTempo( tempo3 );
      obj.cadastrarTempo( tempo4 );
      List<TempoDedicado> lista =obj.getTempoDedicadoOrderByInicio( ta1 );
      expect( lista[0].getDuracaoEmMinutos() , 10);
      expect( lista[1].getDuracaoEmMinutos() , 50);
      expect( lista[2].getDuracaoEmMinutos() , 100);
      expect( lista[3].getDuracaoEmMinutos() , 200);
    });

  }
}