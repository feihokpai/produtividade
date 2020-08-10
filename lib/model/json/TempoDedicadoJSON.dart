import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/dominio/TempoDedicadoEntidade.dart';
import 'package:registro_produtividade/model/json/GenericJsonConverter.dart';

class TempoDedicadoJSON extends GenericJsonConverter{
  static const String ID_COLUNA = "id";
  static const String ID_TAREFA_COLUNA = "id_tarefa";
  static const String DT_INICIO_COLUNA = "dt_inicio";
  static const String DT_FIM_COLUNA = "dt_fim";

  static const String DATA_VAZIA = "00/00/0000";

  TempoDedicadoJSON(  ) : super(DataHoraUtil.formatterDataHoraBrasileira, ID_COLUNA ){
  }

  @override
  Map<String, dynamic> toMap( EntidadeDominio entidade ){
    TempoDedicado tempo = entidade as TempoDedicado;
    Map<String, dynamic> mapa = <String, dynamic> {
      ID_COLUNA: tempo.id,
      ID_TAREFA_COLUNA: (tempo.tarefa == null) ? 0 : tempo.tarefa.id,
      DT_INICIO_COLUNA: (tempo.inicio == null) ? DATA_VAZIA : formatter.format( tempo.inicio ),
      DT_FIM_COLUNA: (tempo.fim == null) ? DATA_VAZIA : formatter.format( tempo.fim ),
    };
    return mapa;
  }

  @override
  TempoDedicado fromMap( Map<String, dynamic> map ){
    Tarefa tarefa = Tarefa.gerarTarefaSomenteComId( map[ ID_TAREFA_COLUNA ] );
    TempoDedicado obj = new TempoDedicado(tarefa, id: map[ ID_COLUNA ]);
    obj.inicio = map[DT_INICIO_COLUNA] == DATA_VAZIA ? null : formatter.parse( map[DT_INICIO_COLUNA] );
    obj.fim = map[DT_FIM_COLUNA] == DATA_VAZIA ? null : formatter.parse( map[DT_FIM_COLUNA] );
    return obj;
  }

}