import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'nowbar_home.dart';

Future<void> startBridge() async {
  try {
    // Bridgeが既に起動しているか確認
    final result = await Process.run(
      "tasklist",
      ["/FI", "IMAGENAME eq NowBarBridge2.exe"],
    );

    if (result.stdout.toString().contains("NowBarBridge2.exe")) {
      return;
    }

    // nowbar.exe と同じフォルダ
    final exeFolder =
        File(Platform.resolvedExecutable).parent.path;

    final bridge =
        File("$exeFolder\\NowBarBridge2.exe");

    if (bridge.existsSync()) {
      await Process.start(
        bridge.path,
        [],
        mode: ProcessStartMode.detached,
      );
    }
  } catch (e) {
    debugPrint("Bridge start error : $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bridge自動起動
  await startBridge();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    // 横450 縦55
    size: Size(450, 55),

    minimumSize: Size(450, 55),

    maximumSize: Size(450, 55),

    backgroundColor: Colors.transparent,

    skipTaskbar: false,

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

  doWhenWindowReady(() {
    final win = appWindow;

    // 横450 縦55
    win.minSize = const Size(450, 55);

    win.size = const Size(450, 55);

    win.show();
  });

  runApp(
    const NowBarApp(),
  );
}


class NowBarApp extends StatelessWidget {
  const NowBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: Colors.transparent,
      ),

      home: const NowBarHome(),
    );
  }
}