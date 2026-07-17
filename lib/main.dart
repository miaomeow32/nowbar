import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'nowbar_home.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await windowManager.ensureInitialized();



  const windowOptions = WindowOptions(

    size: Size(520,55),

    minimumSize: Size(520,55),

    maximumSize: Size(520,55),

    backgroundColor: Colors.transparent,

    skipTaskbar:false,

    titleBarStyle: TitleBarStyle.hidden,

  );



  await windowManager.waitUntilReadyToShow(

    windowOptions,

    () async {

      await windowManager.show();

      await windowManager.focus();

      await windowManager.setAlwaysOnTop(true);

    },

  );




  doWhenWindowReady((){

    final win = appWindow;


    win.minSize =
    const Size(520,55);


    win.size =
    const Size(520,55);


    win.show();

  });




  runApp(
    const NowBarApp()
  );

}





class NowBarApp extends StatelessWidget {


  const NowBarApp({super.key});



  @override
  Widget build(BuildContext context){


    return MaterialApp(

      debugShowCheckedModeBanner:false,


      theme:ThemeData(

        brightness:Brightness.dark,

        scaffoldBackgroundColor:
        Colors.transparent,

      ),


      home:
      const NowBarHome(),

    );


  }


}