import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

enum FinderTypes{
  KEY_STRING,
  TEXT,
  TOOLTIP,
  TYPE,
  ICON,
}

abstract class WidgetTestsUtil{
  MaterialApp materialApp;
  String screenName;
  WidgetTester tester;
  bool portugues;

  WidgetTestsUtil( this.screenName, {bool portugues=true} ){
    this.portugues = portugues;
  }

  Widget makeTestable(Widget widget) {
    if( !portugues) {
      materialApp = new MaterialApp(home: widget);
    }else{
      materialApp = new MaterialApp(home: widget,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('pt', 'BR')],);
    }
    return materialApp;
  }

  /// Return a string with amount letters
  /// Ex: getStringNLetters(5) returns "aaaaa"
  String getStringNLetters(int amount){
    String text = "";
    for( int i=0; i< amount; i++ ){
      text += "a";
    }
    return text;
  }

  Future<void> initNewScreen( Widget tela, WidgetTester tester ){
    this.tester = tester;
    return tester.pumpWidget( this.makeTestable( tela ) );
  }

  /// Verifica se existe apenas 1 widget.
  Finder findOneByKeyString( String stringKey ){
    Finder finder = find.byKey( new ValueKey( stringKey ) );
    expect( finder, findsOneWidget );
    return finder;
  }

  /// 1- Search one widget with key=stringKey 2- If it exists tap him.
  /// 3- Calls tester.pump() to refresh the screen. 4- Execute the function.
  /// 5- return finder.
  /// Deprecated. Usar WidgetTestsUtil.tapWidget() no lugar dele.
  @deprecated
  Future<Finder> tapWidgetWithKeyString( String stringKey, void Function() operation ){
    Finder finder = this.findOneByKeyString( stringKey );
    this.tester.tap( finder ).then( (value) {
      this.tester.pump().then((value) {
        operation.call();
        return finder;
      });
    });
  }

  Finder _getFinderByType( FinderTypes typeFinder, Object criterio ){
    if( typeFinder == FinderTypes.KEY_STRING ) {
      return this.findOneByKeyString( criterio );
    }else if( typeFinder == FinderTypes.TEXT){
      return find.text( criterio );
    }else if( typeFinder == FinderTypes.TOOLTIP){
      return find.byTooltip( criterio );
    }else if( typeFinder == FinderTypes.ICON ){
      return find.byIcon( criterio as IconData );
    }
    return null;
  }

  Future<Finder> tapWidget( Object criterio, FinderTypes typeFinder, void Function() operation ){
    Finder finder = this._getFinderByType(typeFinder, criterio);
    this.tester.tap( finder ).then( (value) {
      this.tester.pump().then((value) {
        operation.call();
        return finder;
      });
    });
  }

  TextFormField setValueTextFormFieldByKeyString( String stringKey, String newValue ){
    TextFormField textField = this.getTextFormFieldByKeyString( stringKey );
    textField.controller.text = newValue;
    return textField;
  }

  String getValueTextFormFieldByKeyString( String stringKey ){
    TextFormField textField = this.getTextFormFieldByKeyString( stringKey );
    return textField.controller.text;
  }

  TextFormField getTextFormFieldByKeyString( String stringKey ){
    Finder finder = this.findOneByKeyString( stringKey );
    TextFormField textField = this.tester.widget( finder ) as TextFormField;
    return textField;
  }

  void criarTeste(String testName, StatefulWidget widget, void Function() executeAfter ){
    testWidgets( "${this.screenName} - $testName" , (WidgetTester tester) async {
      this.initNewScreen( widget, tester).then( (value) {
        executeAfter.call();
      } );
    });
  }

  void runAll();
}