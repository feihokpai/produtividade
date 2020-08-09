import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/control/TarefaEntidade.dart';
import 'package:registro_produtividade/control/TempoDedicadoEntidade.dart';

class TempoDedicadoJSON{
  static const String ID_COLUNA = "id";
  static const String ID_TAREFA_COLUNA = "id_tarefa";
  static const String DT_INICIO_COLUNA = "dt_inicio";
  static const String DT_FIM_COLUNA = "dt_fim";

  static const String DATA_VAZIA = "00/00/0000";

  static DateFormat formatter = DataHoraUtil.formatterDataHoraBrasileira;

  static Map<String, dynamic> toMap( TempoDedicado tempo ){
    Map<String, dynamic> mapa = <String, dynamic> {
      ID_COLUNA: tempo.id,
      ID_TAREFA_COLUNA: (tempo.tarefa == null) ? 0 : tempo.tarefa.id,
      DT_INICIO_COLUNA: (tempo.inicio == null) ? DATA_VAZIA : formatter.format( tempo.inicio ),
      DT_FIM_COLUNA: (tempo.fim == null) ? DATA_VAZIA : formatter.format( tempo.fim ),
    };
    return mapa;
  }

  static TempoDedicado fromMap( Map<String, dynamic> map ){
    Tarefa tarefa = Tarefa.gerarTarefaSomenteComId( map[ ID_TAREFA_COLUNA ] );
    TempoDedicado obj = new TempoDedicado(tarefa, id: map[ ID_COLUNA ]);
    obj.inicio = map[DT_INICIO_COLUNA] == DATA_VAZIA ? null : formatter.parse( map[DT_INICIO_COLUNA] );
    obj.fim = map[DT_FIM_COLUNA] == DATA_VAZIA ? null : formatter.parse( map[DT_FIM_COLUNA] );
    return obj;
  }

}