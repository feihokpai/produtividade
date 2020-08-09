import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';

void main(){
  new TempoDedicadoEntidadeTest().runAll();
}

class TempoDedicadoEntidadeTest{

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
    test("Tempo dedicado: (id) construtor permite id<0?", (){
      expect( new TempoDedicado( this.criarTarefaValida(), id: -1 ).id, -1 );
    });

    test("Tempo dedicado: (id) construtor permite id=0?", (){
      expect( new TempoDedicado( this.criarTarefaValida(), id: 0 ).id, 0 );
    });

    test("Tempo dedicado: (id) construtor permite id>0?", (){
      expect( new TempoDedicado( this.criarTarefaValida(), id: 1 ).id, 1 );
    });

    test("Tempo dedicado: (id) setter permite id<0?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( td.id = -1, -1 );
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

    test("Tempo dedicado: (tarefa) construtor permite tarefa com id=0?", (){
      expect( new TempoDedicado( this.criarTarefaValidaSemId() ).id, 0 );
    });

    test("Tempo dedicado: (tarefa) setter não permite valor nulo?", (){
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida() );
      expect( () => td.tarefa = null, throwsException );
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

    test("Tempo dedicado: (fim) setter permite data nula?", (){
      TempoDedicado t = new TempoDedicado( this.criarTarefaValida() );
      expect( t.fim = null , null );
    });

    test("Tempo dedicado: (fim) setter não permite data anterior a início?", (){
      DateTime agora = new DateTime.now();
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida(), inicio: agora );
      DateTime umSegundoAntes = agora.subtract( new Duration(seconds: 1) );
      expect( () => td.fim = umSegundoAntes, throwsException );
    });

    test("Tempo dedicado: (duracaoEmMinutos) com fim preenchido calcula corretamente?", (){
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

    test("Tempo dedicado: (duracaoEmMinutos) com fim null calcula corretamente?", (){
      DateTime agora = new DateTime.now();
      TempoDedicado td = new TempoDedicado( this.criarTarefaValida(), inicio: agora );
      td.fim = null;
      expect( td.getDuracaoEmMinutos(), 0 );
    });

    test("Tempo dedicado: (compare) Retorna -1 com tempo de início menor", (){
      DateTime agora = DateTime.now();
      DateTime agoraMais1 = DateTime.now().add( new Duration( seconds: 1 ) );
      TempoDedicado t1 = new TempoDedicado(this.criarTarefaValida(), inicio: agora);
      TempoDedicado t2 = new TempoDedicado(this.criarTarefaValida(), inicio: agoraMais1);
      expect( t1.compareTo(t2) , -1 );
    });

    test("Tempo dedicado: (compare) Retorna 1 com tempo de início maior", (){
      DateTime agora = DateTime.now();
      DateTime agoraMais1 = DateTime.now().add( new Duration( seconds: 1 ) );
      TempoDedicado t1 = new TempoDedicado(this.criarTarefaValida(), inicio: agora);
      TempoDedicado t2 = new TempoDedicado(this.criarTarefaValida(), inicio: agoraMais1);
      expect( t2.compareTo(t1) , 1 );
    });

    test("Tempo dedicado: (compare) Retorna 0 se objeto tiver mesma hora, minuto e segundo", (){
      DateTime agora = DateTime.now();
      DateTime agoraMais1 = DateTime.now().add( new Duration( seconds: 0 ) );
      TempoDedicado t1 = new TempoDedicado(this.criarTarefaValida(), inicio: agora);
      TempoDedicado t2 = new TempoDedicado(this.criarTarefaValida(), inicio: agoraMais1);
      expect( t1.compareTo(t2) , 0 );
    });

    test("Tempo dedicado: (compare) Retorna 0 se for mesmo objeto", (){
      TempoDedicado t1 = new TempoDedicado(this.criarTarefaValida(), inicio: DateTime.now());
      expect( t1.compareTo(t1) , 0 );
    });
  }
}