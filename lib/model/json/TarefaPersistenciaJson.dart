import 'package:registro_produtividade/app_module.dart';
import 'package:registro_produtividade/control/dominio/TarefaEntidade.dart';
import 'package:registro_produtividade/control/interfaces/ITarefaPersistencia.dart';
import 'package:registro_produtividade/model/json/GenericoPersistenciaJson.dart';
import 'package:registro_produtividade/model/json/TarefaJSON.dart';

class TarefaPersistenciaJson extends GenericoPersistenciaJson implements ITarefaPersistencia{
  /// Armazena todas as tarefas lidas do arquivo JSON.
//  List<Tarefa> entidades = new List();

  static TarefaPersistenciaJson _instancia;

  /// Construtor acessado somente dentro da classe, para evitar que entidades fora daqui criem novas instãncias.
  TarefaPersistenciaJson._construtorPrivado()
      :super( new TarefaJSON() , AppModule.nomeArquivoTarefas ){
  }

  factory TarefaPersistenciaJson(){
    TarefaPersistenciaJson._instancia ??= TarefaPersistenciaJson._construtorPrivado();
    return TarefaPersistenciaJson._instancia;
  }

  Future<Tarefa> getTarefa( int id ){
    return super.getEntidade<Tarefa>( id );
  }

  @override
  Future<void> cadastrarTarefa(Tarefa tarefa) async {
    assert( tarefa != null,  "tentou cadastrar uma tarefa nula" );
    super.cadastrarEntidade( tarefa );
  }

  @override
  Future<void> deletarTarefa(Tarefa tarefa) async {
    this._assertsTarefa(tarefa);
    await super.deletarEntidade( tarefa );
  }

  @override
  Future<void> editarTarefa(Tarefa tarefa) async {
    this._assertsTarefa(tarefa);
    await super.editarEntidade( tarefa );
  }

  @override
  Future<List<Tarefa>> getAllTarefa() async{
    return await super.getAllEntidade<Tarefa>();
  }

  @override
  Future<List<Tarefa>> getTarefasPorId( List<int> ids ) async {
    return await super.getEntidadesPorId<Tarefa>( ids );
  }

  void _assertsTarefa(Tarefa tarefa){
    String textoBasico = "Tentou realizar uma operação sobre uma Tarefa, ";
    assert( tarefa != null, "${textoBasico}sem repassar a Tarefa.");
    assert( tarefa.id != null, "${textoBasico}mas sem um número identificador.");
    assert( tarefa.id > 0, "${textoBasico}com um identificador inválido." );
  }

}