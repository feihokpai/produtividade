import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';

import 'ProdutividadeTestsUtil.dart';

void main(){
  new TempoDedicadoEntidadeTest().runAll();
}

class TempoDedicadoEntidadeTest extends ProdutividadeTestsUtil{

  Tarefa criarTarefaValida(){
    Tarefa tarefa = new Tarefa("aaa", "bbb");
    tarefa.id = 999;
    return tarefa;
  }

  Tarefa criarTarefaValidaSemId(){
    Tarefa tarefa = new Tarefa("aaa", "bbb");
    return tarefa;
  }

  void runAll(){
    test("Tempo dedicado: (id) construtor não permite id<0?", (){
      expect( () => new TempoDedicado( this.criarTarefaValida(), id: -1 ), throwsException );
    });

    test("Tempo dedicado: (id) construtor permite id=0?", (){
      expect( new TempoDedicado( this.criarTarefaValida(), id: 0 ).id, 0 );
    });

    test("Tempo dedicado: (id) construtor permite id>0?", (){
      expect( new TempoDedicado( this.criarTarefaValida(), id: 1 ).id, 1 );
    });

    test("Tempo dedicado: (id) setter não permite id<0?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.id = -1, throwsException );
    });

    test("Tempo dedicado: (id) setter permite id=0?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( td.id = 0, 0 );
    });

    test("Tempo dedicado: (id) setter permite id>0?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( td.id = 1, 1 );
    });

    test("Tempo dedicado: (tarefa) construtor não permite valor nulo?", (){
      expect( () => new TempoDedicado( null ), throwsException );
    });

    test("Tempo dedicado: (tarefa) construtor não permite tarefa com id=0?", (){
      expect( () => new TempoDedicado( this.criarTarefaValidaSemId() ), throwsException );
    });

    test("Tempo dedicado: (tarefa) setter não permite valor nulo?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.tarefa = null, throwsException );
    });

    test("Tempo dedicado: (tarefa) setter não permite tarefa com id=0?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.tarefa = this.criarTarefaValidaSemId(), throwsException );
    });

    test("Tempo dedicado: (inicio) construtor por default seta a data/hora atual?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      DateTime agora = new DateTime.now();
      expect( agora.difference( td.inicio ).inMinutes , 0 );
    });

    test("Tempo dedicado: (inicio) construtor se setar inicio nulo, muda pra data atual?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida(), inicio: null );
      DateTime agora = new DateTime.now();
      expect( agora.difference( td.inicio ).inMinutes , 0 );
    });

    test("Tempo dedicado: (inicio) construtor não permite inicio para dia seguinte?", (){
      DateTime amanha = DataHoraUtil.criarDataAmanhaInicioDoDia();
      expect( () => new TempoDedicado( this.criarTarefaValida(), inicio: amanha ), throwsException );
    });

    test("Tempo dedicado: (inicio) setter não permite inicio nulo?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.inicio = null, throwsException );
    });

    test("Tempo dedicado: (inicio) setter não permite inicio para dia seguinte?", (){
      DateTime amanha = DataHoraUtil.criarDataAmanhaInicioDoDia();
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.inicio = amanha, throwsException );
    });

    test("Tempo dedicado: (fim) construtor por default seta data nula?", (){
      expect( new TempoDedicado( this.criarTarefaValida() ).fim , null );
    });

    test("Tempo dedicado: (fim) setter não permite data anterior a início?", (){
      DateTime agora = new DateTime.now();
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida(), inicio: agora );
      DateTime umSegundoAntes = agora.subtract( new Duration(seconds: 1) );
      expect( () => td.fim = umSegundoAntes, throwsException );
    });

    test("Tempo dedicado: (duracaoEmMinutos) Calcula corretamente?", (){
      DateTime agora = new DateTime.now();
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida(), inicio: agora );
      td.fim = agora.add( new Duration(minutes: 20) );
      expect( td.getDuracaoEmMinutos(), 20 );
      td.fim = agora.add( new Duration(minutes: 20,seconds: 59) );
      expect( td.getDuracaoEmMinutos(), 20 );
      td.fim = agora.add( new Duration(minutes: 19,seconds: 59) );
      expect( td.getDuracaoEmMinutos(), 19 );
      td.fim = agora.add( new Duration(hours: 1,minutes: 25, seconds: 59) );
      expect( td.getDuracaoEmMinutos(), 85 );
    });
  }
}