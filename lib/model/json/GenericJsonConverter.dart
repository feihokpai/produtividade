import 'package:intl/intl.dart';
import 'package:registro_produtividade/control/dominio/EntidadeDominio.dart';

abstract class GenericJsonConverter{

  DateFormat formatter;
  /// O identificador da chave da entidade que conterá o id.
  String nomeColunaId;

  GenericJsonConverter(DateFormat formatter, String nomeColunaId){
    this.formatter = formatter;
    this.nomeColunaId = nomeColunaId;
  }

  Map<String, dynamic> toMap( EntidadeDominio entidade );
  EntidadeDominio fromMap( Map<String, dynamic> mapa );
}