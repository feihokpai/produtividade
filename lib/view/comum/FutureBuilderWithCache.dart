import 'package:flutter/material.dart';
import 'package:registro_produtividade/view/comum/estilos.dart';

class FutureBuilderWithCache<T extends Widget>{

  T lastValueReturned = null;
  FutureBuilder<T> futureBuilder;
  bool chacheActive = true;
  bool changedOrientation = false;

  FutureBuilderWithCache( { bool chacheOn=true, bool changedOrientation = false} ){
    this.chacheActive = chacheOn;
  }

  FutureBuilder<T> generateFutureBuilder( Future<T> widget ){
    return FutureBuilder<T>(
      future: widget,
      builder: (context, snapshot) {
        if( this.changedOrientation ){
          this.lastValueReturned = null;
        }
        if( !snapshot.hasData ){
          return Container();
        }else if( snapshot.connectionState == ConnectionState.done ){
          if( this.chacheActive ) {
            this.lastValueReturned = snapshot.data;
          }
          return snapshot.data;
        }else if ( snapshot.connectionState == ConnectionState.waiting) {
          return this.lastValueReturned ?? new CircularProgressIndicator();
        }else if( snapshot.hasError ){
          String msgErro = "Error ocurred: ${snapshot.error}";
          print(msgErro);
          return new Container( child: Text( msgErro, style: Estilos.textStyleListaPaginaInicial, ), );
        }else{
          return Container();
        }
      },
    );
  }


}