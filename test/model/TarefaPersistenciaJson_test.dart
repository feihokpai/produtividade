import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/model/json/IPersistenciaJSON.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';
import 'package:registro_produtividade/model/json/TarefaPersistenciaJson.dart';
import 'dart:async';

void main() async{
  TarefaPersistenciaJsonTest teste = new TarefaPersistenciaJsonTest();
  await teste.runAll();
}

class _PersistenciaJSONMock extends Mock implements IPersistenciaJSON{
// Não precisa ter nada.
}

class TarefaPersistenciaJsonTest {

  TarefaPersistenciaJsonTest(){

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

  Tarefa criarTarefaValida( {int id=0}){
    Tarefa tarefa = new Tarefa("aaaaa", "bbbbb");
    tarefa.id = id;
    tarefa.dataHoraCadastro = DateTime.now().subtract( Duration(days: 14)  );
    tarefa.dataHoraConclusao = DateTime.now();
    return tarefa;
  }

  void runAll() async{
    test("Tarefa persistência JSON: o contrutor retorna sempre o mesmo objeto?", (){
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      TarefaPersistenciaJson obj2 = new TarefaPersistenciaJson();
      TarefaPersistenciaJson obj3 = new TarefaPersistenciaJson();
      TarefaPersistenciaJson obj4 = new TarefaPersistenciaJson();
      expect( obj1, obj2 );
      expect( obj1, obj3 );
      expect( obj1, obj4 );
    });

    test("Tarefa persistência JSON: Construtor: o arquivo NÃO foi instanciado?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      bool instanciado = await  Future.delayed( new Duration(seconds: 3), (){
        return obj1.arquivoFoiInstanciado();
      } );
      expect( instanciado, false );
    });

    test("Tarefa persistência JSON: Se chamar o getter de arquivo, instancia?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      expect(obj1.arquivoFoiInstanciado(), false);
      File arquivo = await obj1.arquivo;
      expect(arquivo, isNotNull);
    });

    this.cadastrarTarefaTestes();
    this.editarTarefaTestes();
    this.deletarTarefaTestes();
    this.getAllTarefaTeste();
  }

  void cadastrarTarefaTestes(){
    test("Tarefa persistência JSON: Cadastrar Tarefa cria um registro na lista de maps?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      int qtdAntes = obj1.listaJson.length;
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      expect( obj1.listaJson.length, (qtdAntes+1) );
    });

    test("Tarefa persistência JSON: Cadastrar Tarefa repassa o pedido para o Mock salvar no arquivo?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      verify( obj1.daoJson.salvarObjetoSubstituindoConteudo(any, obj1.listaJson ) );
    });

    test("Tarefa persistência JSON: Cadastrar Tarefa cria um Map com dados corretos?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      Tarefa tarefa = this.criarTarefaValida();
      Map tarefaMap = obj1.jsonConverter.toMap( tarefa );
      await obj1.cadastrarTarefa( tarefa );
      Map mapaSalvo = obj1.listaJson[0];
      // Só tem 1 item no mapa. Sendo assim, pela regra, o próximo id da tarefa tem de ser 1.
      expect( mapaSalvo[TarefaJSON.ID_COLUNA], 1 );
      expect( mapaSalvo[TarefaJSON.NOME_COLUNA], tarefaMap[TarefaJSON.NOME_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DESCRICAO_COLUNA], tarefaMap[TarefaJSON.DESCRICAO_COLUNA] );
      expect( mapaSalvo[TarefaJSON.STATUS_COLUNA], tarefaMap[TarefaJSON.STATUS_COLUNA] );
      expect( mapaSalvo[TarefaJSON.TAREFA_PAI_COLUNA], tarefaMap[TarefaJSON.TAREFA_PAI_COLUNA] );
      expect( mapaSalvo[TarefaJSON.ARQUIVADA_COLUNA], tarefaMap[TarefaJSON.ARQUIVADA_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DATA_CADASTRO_COLUNA], tarefaMap[TarefaJSON.DATA_CADASTRO_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DATA_CONCLUSAO_COLUNA], tarefaMap[TarefaJSON.DATA_CONCLUSAO_COLUNA] );
    });

    test("Tarefa persistência JSON: Cadastrar Tarefa cria ids sequênciais e atribui eles no Map e no Objeto Tarefa?", () async{
      TarefaPersistenciaJson obj = new TarefaPersistenciaJson();
      obj.listaJson.clear();
      Tarefa tarefa1 = this.criarTarefaValida();
      Tarefa tarefa2 = this.criarTarefaValida();
      Tarefa tarefa3 = this.criarTarefaValida();
      Tarefa tarefa4 = this.criarTarefaValida();
      await obj.cadastrarTarefa( tarefa3 );
      await obj.cadastrarTarefa( tarefa1 );
      await obj.cadastrarTarefa( tarefa2 );
      await obj.cadastrarTarefa( tarefa4 );
      expect( tarefa3.id, 1 );
      expect( obj.listaJson[0][TarefaJSON.ID_COLUNA], 1 );
      expect( tarefa1.id, 2 );
      expect( obj.listaJson[1][TarefaJSON.ID_COLUNA], 2 );
      expect( tarefa2.id, 3 );
      expect( obj.listaJson[2][TarefaJSON.ID_COLUNA], 3 );
      expect( tarefa4.id, 4 );
      expect( obj.listaJson[3][TarefaJSON.ID_COLUNA], 4 );
    });

    test("Tarefa persistência JSON: Cadastrar Tarefa adiciona no Map, mas não na Lista de tarefas?", () async{
      TarefaPersistenciaJson obj = new TarefaPersistenciaJson();
      int qtdJson = obj.listaJson.length;
      int qtdTarefas = obj.tarefas.length;
      await obj.cadastrarTarefa( this.criarTarefaValida() );
      expect( obj.listaJson.length, (qtdJson+1) );
      expect( obj.tarefas.length, qtdTarefas );
    });
  }

  void editarTarefaTestes() {
    test("Tarefa persistência JSON: Editar Tarefa passando tarefa nula gera Erro de Assert?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      expect( ()=> obj1.editarTarefa( null ), throwsAssertionError );
    });

    test("Tarefa persistência JSON: Editar Tarefa passando tarefa com id null gera erro de Assert?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      Tarefa tarefa = this.criarTarefaValida( id: null );
      expect( ()=> obj1.editarTarefa( tarefa ), throwsAssertionError );
    });

    test("Tarefa persistência JSON: Editar Tarefa passando tarefa com id <= 0 gera erro de Assert?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      Tarefa tarefa = this.criarTarefaValida( id: 0 );
      expect( ()=> obj1.editarTarefa( tarefa ), throwsAssertionError );
      tarefa.id = -1;
      expect( ()=> obj1.editarTarefa( tarefa ), throwsAssertionError );
    });

    test("Tarefa persistência JSON: Editar Tarefa passando tarefa com id inexistente na Lista cadastrada gera erro exception?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida( ) );
      Tarefa t2 = this.criarTarefaValida( id: 2 );
      expect( ()=> obj1.editarTarefa( t2 ), throwsException );
      t2.id = 1;
      await obj1.editarTarefa( t2 );
    });

    test("Tarefa persistência JSON: Editar Tarefa - mantem a mesma quantidade no Map?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida( ) );
      int qtd = obj1.listaJson.length;
      Tarefa t2 = this.criarTarefaValida( id: 1 );
      obj1.editarTarefa( t2 );
      int qtdDepois = obj1.listaJson.length;
      expect( qtd , qtdDepois);
    });

    test("Tarefa persistência JSON: Editar Tarefa - faz a alteração corretamente no Map?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      Tarefa t1= this.criarTarefaValida( );
      await obj1.cadastrarTarefa( t1 );
      t1.nome = "xxxx";
      t1.descricao = "yyyyy";
      Map tarefaMap = obj1.jsonConverter.toMap( t1 );
      obj1.editarTarefa( t1 );
      Map mapaSalvo = obj1.listaJson[0];
      // Só tem 1 item no mapa. Sendo assim, pela regra, o próximo id da tarefa tem de ser 1.
      expect( mapaSalvo[TarefaJSON.ID_COLUNA], 1 );
      expect( mapaSalvo[TarefaJSON.NOME_COLUNA], tarefaMap[TarefaJSON.NOME_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DESCRICAO_COLUNA], tarefaMap[TarefaJSON.DESCRICAO_COLUNA] );
      expect( mapaSalvo[TarefaJSON.STATUS_COLUNA], tarefaMap[TarefaJSON.STATUS_COLUNA] );
      expect( mapaSalvo[TarefaJSON.TAREFA_PAI_COLUNA], tarefaMap[TarefaJSON.TAREFA_PAI_COLUNA] );
      expect( mapaSalvo[TarefaJSON.ARQUIVADA_COLUNA], tarefaMap[TarefaJSON.ARQUIVADA_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DATA_CADASTRO_COLUNA], tarefaMap[TarefaJSON.DATA_CADASTRO_COLUNA] );
      expect( mapaSalvo[TarefaJSON.DATA_CONCLUSAO_COLUNA], tarefaMap[TarefaJSON.DATA_CONCLUSAO_COLUNA] );
    });

    test("Tarefa persistência JSON: Editar Tarefa - repassa a edição do arquivo para o Mock?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      await obj1.editarTarefa( this.criarTarefaValida( id: 1 ) );
      verify( obj1.daoJson.salvarObjetoSubstituindoConteudo( any, obj1.listaJson) );
    });

    test("Tarefa persistência JSON: Editar Tarefa edita no Map, mas não na Lista de tarefas?", () async{
      TarefaPersistenciaJson obj = new TarefaPersistenciaJson();
      obj.listaJson.clear();
      Tarefa t = this.criarTarefaValida();
      String nomeInicial = t.nome;
      await obj.cadastrarTarefa( t );
      // Chamando getAllTarefa() se espera que a lista de tarefas seja carregada.
      await obj.getAllTarefa();
      t.nome = "outro nome qualquer";
      await obj.editarTarefa( t );
      expect( obj.listaJson[0][TarefaJSON.NOME_COLUNA], t.nome );
      expect( obj.tarefas[0].nome, nomeInicial );
    });

  }

  void deletarTarefaTestes() {
    test("Tarefa persistência JSON: Deletar Tarefa passando tarefa null gera erro de Assert?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      expect( () => obj1.deletarTarefa( null ), throwsAssertionError );
    });

    test("Tarefa persistência JSON: Deletar Tarefa passando id null gera erro de Assert?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      expect( () => obj1.deletarTarefa( this.criarTarefaValida(id: null) ), throwsAssertionError );
    });

    test("Tarefa persistência JSON: Deletar Tarefa passando id inexistente gera Exception?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      expect( () => obj1.deletarTarefa( this.criarTarefaValida(id: 2) ), throwsException );
    });

    test("Tarefa persistência JSON: Deletar Tarefa passando id existente roda OK?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      obj1.deletarTarefa( this.criarTarefaValida(id: 1) );
    });

    test("Tarefa persistência JSON: Deletar Tarefa reduz a quantidade no map?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      int qtd = obj1.listaJson.length;
      await obj1.deletarTarefa( this.criarTarefaValida( id: 1 ) );
      int qtdDepois = obj1.listaJson.length;
      expect( qtdDepois , (qtd - 1) );
    });

    test("Tarefa persistência JSON: Deletar Tarefa repassa alteração pro Mock?", () async{
      TarefaPersistenciaJson obj1 = new TarefaPersistenciaJson();
      obj1.listaJson.clear();
      await obj1.cadastrarTarefa( this.criarTarefaValida() );
      await obj1.deletarTarefa( this.criarTarefaValida( id: 1 ) );
      verify( obj1.daoJson.salvarObjetoSubstituindoConteudo(any, obj1.listaJson ) );
    });

    test("Tarefa persistência JSON: Deletar Tarefa deleta no Map, mas não na Lista de tarefas?", () async{
      TarefaPersistenciaJson obj = new TarefaPersistenciaJson();
      obj.listaJson.clear();
      await obj.cadastrarTarefa( this.criarTarefaValida() );
      await obj.cadastrarTarefa( this.criarTarefaValida() );
      // carrega os dados para a lista de objetos Tarefa.
      await obj.getAllTarefa();
      int qtdJson = obj.listaJson.length;
      int qtdTarefas = obj.tarefas.length;
      await obj.deletarTarefa( this.criarTarefaValida(id: 1) );
      expect( obj.listaJson.length, (qtdJson-1) );
      expect( obj.tarefas.length, qtdTarefas );
    });

  }

  void getAllTarefaTeste() {
    test("Tarefa persistência JSON: getAllTarefa() carrega a lista de objetos Tarefa?", () async{
      TarefaPersistenciaJson obj = new TarefaPersistenciaJson();
      obj.listaJson.clear();
      obj.tarefas.clear();
      await obj.cadastrarTarefa( this.criarTarefaValida() );
      await obj.cadastrarTarefa( this.criarTarefaValida() );
      expect( obj.tarefas.length , 0 );
      await obj.getAllTarefa();
      expect( obj.tarefas.length , 2 );
    });
  }
}