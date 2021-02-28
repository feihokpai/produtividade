import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProdutividadeLocalizations {
  ProdutividadeLocalizations(this.locale);

  final Locale locale;

  static ProdutividadeLocalizations of(BuildContext context) {
    return Localizations.of<ProdutividadeLocalizations>(context, ProdutividadeLocalizations);
  }

  static Map<String, String> _localizedValues;

  Future load() async{
    String fileContent = await rootBundle.loadString( "lib/lang/${locale.languageCode}.json" );
    Map<String, dynamic> values = json.decode( fileContent );
    _localizedValues = values.map( (key, value) => MapEntry( key, value.toString() ) );
  }

  String getTranslatedValue( String key ) {
    return _localizedValues[ key ];
  }

  static const LocalizationsDelegate<ProdutividadeLocalizations> delegate = _LocalizationsDelegate();
}


class _LocalizationsDelegate extends LocalizationsDelegate<ProdutividadeLocalizations> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pt', 'es'].contains(locale.languageCode);

  @override
  Future<ProdutividadeLocalizations> load(Locale locale) async{
    ProdutividadeLocalizations localization = new ProdutividadeLocalizations( locale );
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
