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

  ///     Change the screen dimensions to values of parameters [width] and [height], execute the [callback]
  /// and change the screen dimensions to the initial values.
  void changeScreenSize( double width, double height, StatefulWidget widget, void Function() callback ) async{
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    Size defaultDimensions = binding.window.physicalSize;
    binding.setSurfaceSize( Size( width, height ) ).then((value) {
      tester.pumpWidget( this.makeTestable( widget ) ).then((value) {
        if( callback != null ) {
          callback();
        }
        // Finish the test Return the screen to the Initial Size.
        binding.setSurfaceSize( Size( defaultDimensions.width, defaultDimensions.height ) ).then((value) {
          this.tester.pumpAndSettle();
        });
      });
    });
  }

  ///     Executes 6 widget tests in a StateFull Widget. Executes 4 horizontal tests and 4 vertical tests
  /// to try identify Overflow erros.
  /// Vertical Dimensions tested: 400x800, 300x600, 200x400
  /// Horizontal Dimensions tested: 800x400, 600x300, 400x200
  Future<void> executeSeveralOverflowTests( StatefulWidget Function() callbackCreateInstance ){
    String msgVertical = "Tests if an Overflow occurrs in a vertical little screen of";
    String msgHorizontal = "Tests if an Overflow occurrs in a horizontal little screen of";
    this.criarTeste("${msgVertical} 400x800", callbackCreateInstance(), () async {
      await this.changeScreenSize( 400.0 , 800.0, callbackCreateInstance(), null);
    });

    this.criarTeste("${msgVertical} 300x600", callbackCreateInstance(), () async {
      await this.changeScreenSize( 300.0 , 600.0, callbackCreateInstance(), null);
    });

    this.criarTeste("${msgVertical}  200x400", callbackCreateInstance(), () async {
      await this.changeScreenSize( 200.0 , 400.0, callbackCreateInstance(), null);
    });

    this.criarTeste("${msgHorizontal} 800x400", callbackCreateInstance(), () async {
      await this.changeScreenSize( 800.0 , 400.0, callbackCreateInstance(), null);
    });

    this.criarTeste("${msgHorizontal} 600x300", callbackCreateInstance(), () async {
      await this.changeScreenSize( 600.0 , 300.0, callbackCreateInstance(), null);
    });

    this.criarTeste("${msgHorizontal} 400x200", callbackCreateInstance(), () async {
      await this.changeScreenSize( 400.0 , 200.0, callbackCreateInstance(), null);
    });

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

  Future<Finder> tapWidget( Object criterio, FinderTypes typeFinder, void Function() operation ) async{
    Finder finder = this._getFinderByType(typeFinder, criterio);
    await this.tester.tap( finder ).then( (value) async {
      await this.tester.pump().then((value) {
        operation.call();
        return finder;
      });
    });
  }

  /// Tap a widget and calls pump with duration of [durationInSeconds] seconds
  Future<Finder> tapWidgetAndWait( Object criterio, FinderTypes typeFinder, int durationInSeconds, void Function() operation ) async{
    Finder finder = this._getFinderByType(typeFinder, criterio);
//    await this.tester.tap( finder ).then( (value) async {
      await this.tester.tap( finder );
      await this.tester.pump( new Duration( seconds: durationInSeconds ) );
      if( operation != null ) {
        operation.call();
      }

//      await this.tester.pump( new Duration( seconds: durationInSeconds ) ).then((value) {
//        if( operation != null ) {
//          operation.call();
//        }
//      });

//    });
    return await finder;
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

  void createAsynchronousTest(String testName, StatefulWidget widget, int pumpDurationInSeconds, void Function() executeAfter ){
    testWidgets( "${this.screenName} - $testName" , (WidgetTester tester) async {
      this.tester = tester;
      this.pumpWidgetAndPumpAgain( widget, pumpDurationInSeconds, executeAfter );
    });
  }

  ///     Execute tester.pumpWidget, creating a Material App folding [widget]. After execute tester.pump()
  /// with duration of [pumpDurationInSeconds] seconds
  Future<void> pumpWidgetAndPumpAgain( StatefulWidget widget, int pumpDurationInSeconds, void Function() executeAfter ) async{
    await this.tester.pumpWidget( this.makeTestable( widget ) ).then((value) async {
      await this.tester.pump( new Duration(seconds: pumpDurationInSeconds) ).then((value) {
        executeAfter.call();
      });
    });
  }

  /// This method is only to wait some seconds before finish. Internally don't do nothing more.
  /// Is very useful in tests where you really have to wait this amount of time in real Time and
  /// the test Framework can't use Future.delay() ou other similar methods
  void wait(int durationInSeconds){
    DateTime begin = DateTime.now();
    while( DateTime.now().difference( begin ).inSeconds < durationInSeconds){
    }
  }

  void runAll();
}