import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/view/comum/comuns_widgets.dart';
import 'package:registro_produtividade/view/tarefas_edicao_tela.dart';
import 'package:registro_produtividade/view/tarefas_listagem_tela.dart';

import 'WidgetTestsUtil.dart';
import 'WidgetTestsUtilProdutividade.dart';

void main(){
  new TarefasEdicaoTelaTeste("Cadastro/edição de tarefas" ).runAll();
}

class TarefasEdicaoTelaTeste extends WidgetTestsUtilProdutividade{

  TarefasEdicaoTelaTeste( String nomeTela ): super(nomeTela);

  void testarValidacao(bool passou){
    Form formulario = super.tester.widget( find.byType( Form ) ) as Form;
    GlobalKey<FormState> key = formulario.key as GlobalKey<FormState>;
    expect( key.currentState.validate(), passou );
  }

  @override
  void runAll(){
    super.criarTeste("Modo Cadastro: Tem título na página?", new TarefasEdicaoTela(), () {
      super.findOneByKeyString( ComunsWidgets.KEY_STRING_TITULO_PAGINA );
    });

    TarefasEdicaoTela tela = new TarefasEdicaoTela();
    super.criarTeste("Modo Cadastro: o objeto da Tarefa atual fica nulo?", tela, () {
      expect( tela.tarefaAtual , null );
    });

    TarefasEdicaoTela telaCamposVazios = new TarefasEdicaoTela();
    super.criarTeste("Modo Cadastro: Ao entrar na tela, os campos ficam vazios?", telaCamposVazios, () {
      String valor = super.getValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME );
      expect( valor.length, 0 );
      String descricao = super.getValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO );
      expect( descricao.length, 0 );
    });

    this.modoCadastroClicaVoltarResetaVariaveis();

    super.criarTeste("Modo Cadastro: Botão voltar. Clicando passa pra tela inicial?", new TarefasEdicaoTela(), () {
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome vazio: NÃO passa na validação?", new TarefasEdicaoTela(), () {
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome vazio: NÃO volta pra página inicial?", new TarefasEdicaoTela(), () {
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome só com espaços: NÃO passa na validação?", new TarefasEdicaoTela(), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , " ");
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome sem letras: NÃO passa na validação?", new TarefasEdicaoTela(), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "872..__%*@");
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome esquisito, mas válido: passa na validação?", new TarefasEdicaoTela(), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "a87*2..__%*@");
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( true );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome enorme: NÃO passa na validação?", new TarefasEdicaoTela(), () {
      String nomeInvalido = super.getStringNLetters( 1+Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , nomeInvalido );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar com nome enorme: NÃO volta pra página inicial?", new TarefasEdicaoTela(), () {
      String nomeInvalido = super.getStringNLetters( 1+Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , nomeInvalido );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar - nome tamanho válido: passa na validação?", new TarefasEdicaoTela(), () {
      String nomeValido = super.getStringNLetters( Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , nomeValido );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( true );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar - nome tamanho válido: volta pra página inicial?", new TarefasEdicaoTela(), () {
      String nomeInvalido = super.getStringNLetters( Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , nomeInvalido );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar - descrição vazia: volta pra página inicial?", new TarefasEdicaoTela(), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "aaaa" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });

    super.criarTeste("Modo Cadastro: Botão Salvar - descrição enorme: volta pra página inicial?", new TarefasEdicaoTela(), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "aaaa" );
      String nomeEnorme = super.getStringNLetters( 200 );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO , nomeEnorme );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });
    /// TODO Falta implementar a verificação do que ocorre após salvar.

    super.criarTeste("Modo Cadastro: Botão Deletar NÃO fica visível?", new TarefasEdicaoTela(), () {
      Finder finder = find.byKey( new ValueKey( TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR ) );
      expect( finder, findsNothing );
    });

    Tarefa tarefaTesteEdicao = new Tarefa("aaa", "bbb");
    tarefaTesteEdicao.id = 999;
    super.criarTeste("Modo Edição: Tem título na página?", new TarefasEdicaoTela.modoEdicao( tarefaTesteEdicao ), () {
      super.findOneByKeyString( ComunsWidgets.KEY_STRING_TITULO_PAGINA );
    });

    this.testeModoEdicaoPreenchimentoObjetoTarefa();
    this.testeModoEdicaoPreenchimentoNomeDescricao();

    this.modoEdicaoClicaVoltarResetaVariaveis();

    super.criarTeste("Modo Edição: Botão Voltar manda pra página inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.tapWidgetWithKeyString( TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR , () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome vazio: NÃO passa na validação?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome vazio: NÃO passa pra tela inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome enorme: NÃO passa na validação?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      String grande = super.getStringNLetters( 1+Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , grande );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome enorme: NÃO passa pra página inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      String grande = super.getStringNLetters( 1+Tarefa.LIMITE_TAMANHO_NOME );
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , grande );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome só com espaços: NÃO passa na validação?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "  " );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome só com espaços: NÃO passa pra página inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "  " );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome sem iniciar em letra: NÃO passa na validação?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "2836__##87" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( false );
      });
    });
    /// TODO Testar o que acontece se o usuário preencher algum caractere que é relevante numa string como '"' ou '%' ou '$'

    super.criarTeste("Modo Edição: Botão Salvar com nome sem iniciar em letra: NÃO passa pra página inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "2836__##87" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome estranho, mas válido: passa na validação?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "U28e36__##87" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        this.testarValidacao( true );
      });
    });

    super.criarTeste("Modo Edição: Botão Salvar com nome estranho, mas válido: passa pra página inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "u28e36__##87" );
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_SALVAR, () {
        expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
      });
    });

    this.testesBotaoDeletar();

    super.executeSeveralOverflowTests( () => new TarefasEdicaoTela() );

  }

  void testeModoEdicaoPreenchimentoObjetoTarefa() {
    Tarefa tarefaTesteEdicao = new Tarefa("aaa", "bbb");
    tarefaTesteEdicao.id = 999;
    TarefasEdicaoTela tela = new TarefasEdicaoTela( tarefa: tarefaTesteEdicao );
    super.criarTeste("Modo edição: o objeto da Tarefa atual é preenchido?", tela, () {
      expect( tela.tarefaAtual , isNotNull);
      expect( tela.tarefaAtual.id , 999 );
      expect( tela.tarefaAtual.nome , "aaa");
      expect( tela.tarefaAtual.descricao , "bbb");
    });
  }

  void testeModoEdicaoPreenchimentoNomeDescricao(){
    Tarefa tarefaTesteEdicao = new Tarefa( "aaa", "bbb" );
    tarefaTesteEdicao.id = 999;
    TarefasEdicaoTela tela = new TarefasEdicaoTela( tarefa: tarefaTesteEdicao );
    super.criarTeste("Modo edição: os campos são preenchidos?", tela, () {
      String valorCampoNome = super.getValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME );
      expect( valorCampoNome, "aaa" );
      String valorCampoDescricao = super.getValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO );
      expect( valorCampoDescricao, "bbb" );
    });
  }

  void modoCadastroClicaVoltarResetaVariaveis() {
    TarefasEdicaoTela telaVoltarClear = new TarefasEdicaoTela();
    super.criarTeste("Modo Cadastro: Botão voltar. Clicando reseta variáveis setadas?", telaVoltarClear, () {
      TextFormField campoNome = super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "aaaa");
      TextFormField campoDescricao = super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO , "bbbb");
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR, () {
        expect( campoNome.controller.text.length, 0);
        expect( campoDescricao.controller.text.length, 0);
        expect( telaVoltarClear.tarefaAtual, null);
      });
    });
  }

  void modoEdicaoClicaVoltarResetaVariaveis() {
    TarefasEdicaoTela telaVoltarClear = new TarefasEdicaoTela( tarefa: this.criarTarefaValida() );
    super.criarTeste("Modo Edição: Botão voltar. Clicando reseta variáveis setadas?", telaVoltarClear, () {
      TextFormField campoNome = super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_NOME , "aaaa");
      TextFormField campoDescricao = super.setValueTextFormFieldByKeyString( TarefasEdicaoTela.KEY_STRING_CAMPO_DESCRICAO , "bbbb");
      super.tapWidgetWithKeyString(TarefasEdicaoTela.KEY_STRING_BOTAO_VOLTAR, () {
        expect( campoNome.controller.text.length, 0);
        expect( campoDescricao.controller.text.length, 0);
        expect( telaVoltarClear.tarefaAtual, null);
      });
    });
  }

  void testesBotaoDeletar() {
    Finder finderBotaoDeletar;
    super.criarTeste("Modo Edição: Botão Deletar fica visível?", new TarefasEdicaoTela( tarefa: this.criarTarefaValida() ), () {
      finderBotaoDeletar = super.findOneByKeyString( TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR );
    });

    super.criarTeste("Modo Edição: Botão Deletar- abre Popup?", new TarefasEdicaoTela( tarefa: this.criarTarefaValida() ), () {
      super.tapWidgetWithKeyString( TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR, () {
        Finder finder = find.byType( AlertDialog );
        expect( finder , findsOneWidget );
      });
    });

    super.criarTeste("Modo Edição: Botão Deletar- Clicar não no popup mantem na tela?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.tapWidgetWithKeyString( TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR, () {
        Finder finder = find.byType( AlertDialog );
        expect( finder , findsOneWidget );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG );
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG , () {
          expect( ComunsWidgets.context.widget.runtimeType, TarefasEdicaoTela );
        });
      });
    });

    super.criarTeste("Modo Edição: Botão Deletar- Clicar sim no popup direciona pra tela inicial?", new TarefasEdicaoTela.modoEdicao( this.criarTarefaValida() ), () {
      super.tapWidgetWithKeyString( TarefasEdicaoTela.KEY_STRING_BOTAO_DELETAR, () {
        Finder finder = find.byType( AlertDialog );
        expect( finder , findsOneWidget );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG );
        super.findOneByKeyString( ComunsWidgets.KEY_STRING_BOTAO_NAO_DIALOG );
        super.tapWidgetWithKeyString( ComunsWidgets.KEY_STRING_BOTAO_SIM_DIALOG , () {
          expect( ComunsWidgets.context.widget.runtimeType, ListaDeTarefasTela );
        });
      });
    });
  }

}