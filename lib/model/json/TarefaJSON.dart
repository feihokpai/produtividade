import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/model/json/GenericJsonConverter.dart';

class TarefaJSON extends GenericJsonConverter{
  static const String ID_COLUNA = "id";
  static const String NOME_COLUNA = "nome";
  static const String DESCRICAO_COLUNA = "descricao";
  static const String STATUS_COLUNA = "status";
  static const String ARQUIVADA_COLUNA = "arquivada";
  static const String TAREFA_PAI_COLUNA = "id_tarefa_pai";
  static const String DATA_CADASTRO_COLUNA = "data_hora_cadastro";
  static const String DATA_CONCLUSAO_COLUNA = "data_hora_conclusao";

  static const String DATA_VAZIA = "00/00/0000";

  TarefaJSON() : super(DataHoraUtil.formatterDataHoraBrasileira, ID_COLUNA ){
  }

  @override
  Map<String, dynamic> toMap( EntidadeDominio entidade ){
    Tarefa tarefa = entidade as Tarefa;
    String dataCadastro = ( (tarefa.dataHoraCadastro != null) ? super.formatter.format( tarefa.dataHoraCadastro ) : DATA_VAZIA);
    String dataConclusao = ( (tarefa.dataHoraConclusao != null) ? super.formatter.format( tarefa.dataHoraConclusao ) : DATA_VAZIA);
    Map<String, dynamic> mapa = <String, dynamic> {
      TarefaJSON.ID_COLUNA: tarefa.id,
      TarefaJSON.NOME_COLUNA: tarefa.nome,
      TarefaJSON.DESCRICAO_COLUNA: tarefa.descricao,
      TarefaJSON.STATUS_COLUNA: tarefa.status,
      TarefaJSON.ARQUIVADA_COLUNA: (tarefa.arquivada? 1 : 0 ),
      TarefaJSON.TAREFA_PAI_COLUNA: ( tarefa.tarefaPai != null? tarefa.tarefaPai.id : 0 ),
      TarefaJSON.DATA_CADASTRO_COLUNA: ( dataCadastro ),
      TarefaJSON.DATA_CONCLUSAO_COLUNA: ( dataConclusao ),
    };
    return mapa;
  }

  Tarefa fromMap( Map<String, dynamic> mapa ){
    Tarefa tarefa = new Tarefa( mapa[NOME_COLUNA], mapa[DESCRICAO_COLUNA] );
    tarefa.id = mapa[ ID_COLUNA ];
    tarefa.status = mapa[ STATUS_COLUNA ];
    tarefa.arquivada = mapa[ ARQUIVADA_COLUNA ] == 1 ? true : false;
    tarefa.tarefaPai = null;
    tarefa.dataHoraCadastro = mapa[DATA_CADASTRO_COLUNA] == DATA_VAZIA ? null : super.formatter.parse( mapa[ DATA_CADASTRO_COLUNA ] );
    if(mapa[ DATA_CONCLUSAO_COLUNA ] == DATA_VAZIA || mapa[ DATA_CONCLUSAO_COLUNA ] == null){
      tarefa.dataHoraConclusao = null;
    }else{
      super.formatter.parse( mapa[ DATA_CONCLUSAO_COLUNA ] );
    }
    return tarefa;
  }

}