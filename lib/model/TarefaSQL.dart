import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';

class TarefaSQL{
  static const String ID_COLUNA = "id";
  static const String NOME_COLUNA = "nome";
  static const String DESCRICAO_COLUNA = "descricao";
  static const String STATUS_COLUNA = "status";
  static const String ARQUIVADA_COLUNA = "arquivada";
  static const String TAREFA_PAI_COLUNA = "id_tarefa_pai";
  static const String DATA_CADASTRO_COLUNA = "data_hora_cadastro";
  static const String DATA_CONCLUSAO_COLUNA = "data_hora_conclusao";

  static Map<String, dynamic> toMap( Tarefa tarefa ){
    String dataCadastro = ( (tarefa.dataHoraCadastro != null) ? DataHoraUtil.converterDateTimeParaDateStringSqllite( tarefa.dataHoraCadastro ) : null);
    String dataConclusao = ( (tarefa.dataHoraConclusao != null) ? DataHoraUtil.converterDateTimeParaDateStringSqllite( tarefa.dataHoraConclusao ) : null);
    Map<String, dynamic> mapa = <String, dynamic> {
      TarefaSQL.ID_COLUNA: tarefa.id,
      TarefaSQL.NOME_COLUNA: tarefa.nome,
      TarefaSQL.DESCRICAO_COLUNA: tarefa.descricao,
      TarefaSQL.STATUS_COLUNA: tarefa.status,
      TarefaSQL.ARQUIVADA_COLUNA: (tarefa.arquivada? 1 : 0 ),
      TarefaSQL.TAREFA_PAI_COLUNA: ( tarefa.tarefaPai != null? tarefa.tarefaPai.id : null ),
      TarefaSQL.DATA_CADASTRO_COLUNA: ( dataCadastro ),
      TarefaSQL.DATA_CONCLUSAO_COLUNA: ( dataConclusao ),
    };
    return mapa;
  }

  static List<Tarefa> fromMap( Map<String, dynamic> mapa ){
    Tarefa tarefa = new Tarefa( mapa[TarefaSQL.NOME_COLUNA], mapa[DESCRICAO_COLUNA] );
    tarefa.id = mapa[ ID_COLUNA ];
    tarefa.status = mapa[ STATUS_COLUNA ];
    tarefa.arquivada = mapa[ ARQUIVADA_COLUNA ];
    // TODO Falta preencher de algum modo o campo tarefaPai.
    //tarefa.tarefaPai = ;
    tarefa.dataHoraCadastro = DataHoraUtil.converterDateTimeStringSqllitearaDateTime( mapa[ DATA_CADASTRO_COLUNA ] );
    tarefa.dataHoraConclusao = DataHoraUtil.converterDateTimeStringSqllitearaDateTime( mapa[ DATA_CONCLUSAO_COLUNA ] );
  }

}