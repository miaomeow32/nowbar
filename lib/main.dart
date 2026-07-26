import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'nowbar_home.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();


  WindowOptions windowOptions = const WindowOptions(

    size: Size(360, 45),

    // バー表示と同じ高さを最小値にする。

    minimumSize: Size(200, 45),

    center: true,

    backgroundColor: Colors.transparent,

    skipTaskbar: false,

    titleBarStyle: TitleBarStyle.hidden,

  );


  windowManager.waitUntilReadyToShow(windowOptions, () async {

    await windowManager.setAsFrameless();

    await windowManager.setHasShadow(false);

    await windowManager.setResizable(false);

    // 表示するバーとウィンドウの高さを一致させる。
    await windowManager.setSize(const Size(360, 45));
    await windowManager.show();

    await windowManager.focus();

  });


  runApp(const MyApp());

}


class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark(),

      home: const NowBarHome(),

    );

  }

} 
