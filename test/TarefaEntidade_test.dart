import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';

String getStringComNumeroDeCaracteres(int qtd){
  String texto = "";
  for(int i=0; i< qtd; i++){
    texto += "a";
  }
  return texto;
}

void main(){
  test("Tarefa: (id) construtor tem id=0 por default?", (){
    final tarefa = new Tarefa("nome", "descricao");
    // Ao criar uma nova instância sem passar id, deve atribuir 0 para o id.
    expect( tarefa.id, 0 );
  } );

  test( "Tarefa: (id) setter Impede id <=0" , (){
    final tarefa = new Tarefa("nome", "descricao");
    expect( (){ tarefa.id = 0;} , throwsException );
    expect( (){ tarefa.id = -1;} , throwsException );
  });

  test( "Tarefa: (id) setter Permite id > 0" , (){
    final tarefa = new Tarefa("nome", "descricao");
    expect(  tarefa.id = 1 , 1 );
    expect( tarefa.id = 10 , 10 );
    expect( tarefa.id = 100 , 100 );
    expect( tarefa.id = 989548758 , 989548758 );
  });

  test( "Tarefa: (nome) construtor Impede nome nulo ou vazio" , (){
    expect( () => new Tarefa(null, "descricao") , throwsException );
    expect( () => new Tarefa("", "descricao") , throwsException );
  });

  test( "Tarefa: (nome) construtor Impede nome maior que permitido" , (){
    String nomeGrande = getStringComNumeroDeCaracteres( Tarefa.LIMITE_TAMANHO_NOME+1 );
    expect( () => new Tarefa(nomeGrande, "aa"), throwsException );
  });

  test( "Tarefa: (nome) construtor permite nomes válidos" , (){
    expect( ( new Tarefa("doido", "descricao").nome) , "doido" );
    expect( ( new Tarefa("fkshkfhd shks!!", "descricao").nome ) , "fkshkfhd shks!!" );
    String nomeTamanhoLimite = getStringComNumeroDeCaracteres( Tarefa.LIMITE_TAMANHO_NOME );
    expect( new Tarefa(nomeTamanhoLimite, "aaa").nome, nomeTamanhoLimite );
  });

  test( "Tarefa: (nome) setter Impede nome nulo ou vazio" , (){
    Tarefa tarefa = new Tarefa("aaa", "aaa");
    expect( () => tarefa.nome = null , throwsException );
    expect( () => tarefa.nome = ""  , throwsException );
  });

  test( "Tarefa: (nome) Setter Impede nome maior que permitido" , (){
    String nomeGrande = getStringComNumeroDeCaracteres( Tarefa.LIMITE_TAMANHO_NOME+1 );
    Tarefa tarefa = new Tarefa("aa", "aa");
    expect( () =>(tarefa.nome = nomeGrande), throwsException );
  });

  test( "Tarefa: (nome) Setter permite nome de tamanho permitido" , (){
    String nomeTamanhoAdequado = getStringComNumeroDeCaracteres( Tarefa.LIMITE_TAMANHO_NOME );
    Tarefa tarefa = new Tarefa("aa", "aa");
    expect( (tarefa.nome = nomeTamanhoAdequado), nomeTamanhoAdequado );
  });

  test( "Tarefa: (arquivada) Construtor inicia com false" , (){
    Tarefa tarefa = new Tarefa("aa", "aa");
    expect( (tarefa.arquivada ), false );
  });

  test( "Tarefa: (status) Construtor inicia com Tarefa.ABERTA" , (){
    Tarefa tarefa = new Tarefa("aa", "aa");
    expect( (tarefa.status ), Tarefa.ABERTA );
  });

  test( "Tarefa: (status) Setter permite valores válidos" , (){
    Tarefa tarefa = new Tarefa("aa", "aa");
    expect( (tarefa.status = Tarefa.ABERTA ), Tarefa.ABERTA );
    expect( (tarefa.status = Tarefa.CONCLUIDA ), Tarefa.CONCLUIDA );
  });

  test( "Tarefa: (status) Setter não permite valores inválidos" , (){
    Tarefa tarefa = new Tarefa("aa", "aa");
    List<int> valores;
    // Aqui Testa todos os valores, menos os válidos.
    for(int i=0; i< 10000; i++){
      if( !Tarefa.statusValidos.contains( i ) ){
        expect( () =>(tarefa.status = i ), throwsException );
      }
    }
  });

  test("Tarefa: (dataHoraCadastro) Construtor prenche dataHoraCadastro. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    expect( (tarefa.dataHoraCadastro != null), true );
  } );

  test("Tarefa: (dataHoraCadastro) Construtor prenche com data e hora atuais. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    DateTime agora = DateTime.now();
    int diferenca = agora.difference( tarefa.dataHoraCadastro ).inMinutes;
    expect( (diferenca), 0 );
  } );

  test("Tarefa: (dataHoraConclusao) Construtor cria nulo. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    expect( tarefa.dataHoraConclusao , null );
  } );

  test("Tarefa: (dataHoraConclusao) setter não permite data futura. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    DateTime amanha = DateTime.now().add( new Duration( days: 1 ) );
    expect( () => tarefa.dataHoraConclusao = amanha , throwsException );
    DateTime amanhaInicioDia = amanha.subtract( new Duration( hours: amanha.hour, minutes: amanha.minute, seconds: (amanha.second-10) ) );
    expect( () => tarefa.dataHoraConclusao = amanhaInicioDia , throwsException );
  } );

  test("Tarefa: (tarefaPai) Construtor gera null. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    expect( tarefa.tarefaPai , null );
  } );

  test("Tarefa: (tarefaPai) Setter não permite setar a própria tarefa. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    expect( () => tarefa.tarefaPai = tarefa , throwsException );
  } );

  test("Tarefa: (tarefaPai) Setter permite setar outra tarefa. ", (){
    final tarefa = new Tarefa("nome", "descricao");
    final outra = new Tarefa("nome", "descricao");
    expect( tarefa.tarefaPai = outra , outra );
  } );

}