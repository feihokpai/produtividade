import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:registro_produtividade/control/DataHoraUtil.dart';
import 'package:registro_produtividade/view/comum/ChronometerField.dart';
import 'package:registro_produtividade/view/comum/FakeScreenTestChronometerField.dart';

import 'WidgetTestsUtil.dart';
import 'WidgetTestsUtilProdutividade.dart';

void main(){
  new ChronometerFieldTest("Chronometer Field").runAll();
}

class ChronometerFieldTest extends WidgetTestsUtilProdutividade {
  ChronometerFieldTest(String screenName) : super(screenName);

  String keyButtonStartStop = FakeScreenTestChronometerField.KEY_STRING_BUTTON_START_STOP;

  @override
  void runAll() {
    super.criarTeste("In contructor, label NULL converts in empty String?",
        new FakeScreenTestChronometerField(), () {
          expect(new ChronometerField(null, functionUpdateUI: () {}).labelCampo,
              "");
        });

    super.criarTeste("In contructor, is allowed beginTime NULL?", new FakeScreenTestChronometerField(), () {
          expect(new ChronometerField(
              "aaa", beginTime: null, functionUpdateUI: () {}).beginTime, null);
    });

    super.criarTeste("In contructor, if not define beginTime, it defines NULL?",
        new FakeScreenTestChronometerField(), () {
          expect(new ChronometerField("aaa", functionUpdateUI: () {}).beginTime, null);
    });

    super.criarTeste("In contructor, if define beginTime, the timer starts?", new FakeScreenTestChronometerField(), () {
      int minutesPast = 40;
      int secondsWait = 1;
      DateTime dateTime = DateTime.now().subtract(new Duration(minutes: minutesPast));
      ChronometerField field = new ChronometerField("aaa", functionUpdateUI: () {}, beginTime: dateTime );
      super.wait( secondsWait );
      expect( field.getLastDuration().inSeconds, secondsWait+(60*minutesPast) );
      field.pause();
    });

    super.criarTeste(
        "In contructor, if not define Formatter, set the Default Formatter?",
        new FakeScreenTestChronometerField(), () {
      expect(new ChronometerField("aaa", functionUpdateUI: () {}).formatter,
          ChronometerField.defaultFormatter);
    });

    super.criarTeste(
        "In contructor, if define Formatter, set the inserted Formatter?",
        new FakeScreenTestChronometerField(), () {
      expect(new ChronometerField(
          "aaa", formatter: DataHoraUtil.formatterSqllite,
          functionUpdateUI: () {}).formatter, DataHoraUtil.formatterSqllite);
    });

    super.criarTeste("In setter, is allowed beginTime NULL?", new FakeScreenTestChronometerField(), () {
      ChronometerField field = new ChronometerField( "aaa", functionUpdateUI: () {} );
      expect( field.beginTime = null, null);
    });

    super.criarTeste("In setter, if defines beginTime, the timer starts?", new FakeScreenTestChronometerField(), () {
      int minutesPast = 40;
      int secondsWait = 1;
      DateTime dateTime = DateTime.now().subtract(new Duration(minutes: minutesPast));
      ChronometerField field = new ChronometerField("aaa", functionUpdateUI: () {} );
      expect( field.getLastDuration().inSeconds, 0 );
      field.beginTime = dateTime;
      wait( secondsWait );
      expect( field.getLastDuration().inSeconds , secondsWait+(60*minutesPast) );
      field.pause();
    });

    super.criarTeste("The initial value in Field is 00:00:00?",
        new FakeScreenTestChronometerField(), () {
          expect(new ChronometerField("aaa", functionUpdateUI: () {}).getText(),
              DataHoraUtil.CRONOMETRO_ZERADO);
    });

    test("If starts isolated field, the beginTime is updated along the time?", () async{
      ChronometerField field = new ChronometerField( "aaaa", functionUpdateUI: (){} );
      await field.start();
      int diferenca = await  Future.delayed( new Duration(seconds: 3), (){
        field.pause();
//        return DateTime.now().difference( field.beginTime ).inSeconds;
        return field.getLastDuration().inSeconds;
      } );
      expect( diferenca, 3 );
    });

    FakeScreenTestChronometerField fakeScreen3 = new FakeScreenTestChronometerField();
    super.createAsynchronousTest("Start/Stop Button - Before any click, beginTime is null?", fakeScreen3, 2, () {
      expect(fakeScreen3.chronometerFieldReference.beginTime, null);
    });

    FakeScreenTestChronometerField fakeScreen4 = new FakeScreenTestChronometerField();
    super.createAsynchronousTest("Start/Stop Button - On click, the field is being updated?", fakeScreen4, 2, () async {
      int durationWait1 = 1;
      int durationWait2 = 1;
      String expectedValueAfterWait1 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: durationWait1 ) );
      String expectedValueAfterWait2 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: (durationWait1+durationWait2) ) );
      await super.tapWidgetAndWait( this.keyButtonStartStop, FinderTypes.KEY_STRING, 1, (){} );
      await this._waitPumpAndCheckValueInField( fakeScreen4.chronometerFieldReference, durationWait1, expectedValueAfterWait1 );
      await this._waitPumpAndCheckValueInField( fakeScreen4.chronometerFieldReference, durationWait2, expectedValueAfterWait2 );
    });

    FakeScreenTestChronometerField fakeScreen1 = new FakeScreenTestChronometerField();
    super.createAsynchronousTest("Start/Stop Button - If clicks, the Chronometer start and Stop alternatively?", fakeScreen1, 2, () {
      ChronometerField field = fakeScreen1.chronometerFieldReference;
      expect(field.isActive(), false);
      super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () async {
        expect(field.isActive(), true);
        super.tapWidgetAndWait( this.keyButtonStartStop, FinderTypes.KEY_STRING, 1, () {
          expect(field.isActive(), false);
        });
      });
    });

    this.testsIfStopsUpdateFieldsAfterStopButtonClicked();

    this.testsIfStopsAndStartsAgainChronometerIsReseted();
  }

  void testsIfStopsUpdateFieldsAfterStopButtonClicked(){
    FakeScreenTestChronometerField fakeScreen5 = new FakeScreenTestChronometerField();
    super.createAsynchronousTest("Start/Stop Button - If clicks to Stop, the field stop the updates?", fakeScreen5, 1, () async {
      ChronometerField field = fakeScreen5.chronometerFieldReference;
      int durationWait1 = 1;
      int durationWait2 = 1;
      int durationWait3 = 1;
      String expectedValueAfterWait1 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: durationWait1 ) );
      String expectedValueAfterWait2 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: (durationWait1+durationWait2) ) );
      String expectedValueAfterWait3 = expectedValueAfterWait2;
      await super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () {});
      await this._waitPumpAndCheckValueInField(field, durationWait1, expectedValueAfterWait1 );
      await this._waitPumpAndCheckValueInField(field, durationWait2, expectedValueAfterWait2 );
      await super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () {});
      await this._waitPumpAndCheckValueInField(field, durationWait3, expectedValueAfterWait3 );
    });
  }

  void testsIfStopsAndStartsAgainChronometerIsReseted(){
    FakeScreenTestChronometerField fakeScreen5 = new FakeScreenTestChronometerField();
    super.createAsynchronousTest("Start/Stop Button - If clicks to Stop, and after to Start, resets the field?", fakeScreen5, 1, () async {
      ChronometerField field = fakeScreen5.chronometerFieldReference;
      int durationWait1 = 2;
      int durationWait2 = 1;
      String expectedValueAfterWait1 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: durationWait1 ) );
      String expectedValueAfterWait3 = DataHoraUtil.converterDuracaoFormatoCronometro( new Duration( seconds: durationWait2 ) );
      await super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () {});
      await this._waitPumpAndCheckValueInField(field, durationWait1, expectedValueAfterWait1);
      await super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () {});
      await super.tapWidget( this.keyButtonStartStop, FinderTypes.KEY_STRING, () {});
      await this._waitPumpAndCheckValueInField(field, durationWait2, expectedValueAfterWait3);
    });
  }

  Future<void> _waitPumpAndCheckValueInField(ChronometerField field, int durationWaitInSeconds,
      String expectedValue) async {
    super.wait( durationWaitInSeconds );
    await super.tester.pump( Duration(seconds: 1) );
    expect( field.getText(), expectedValue );
  }
}