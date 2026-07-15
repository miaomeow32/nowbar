import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WindowManagerの準備
  await windowManager.ensureInitialized();

  // ウィンドウ設定
  WindowOptions windowOptions = const WindowOptions(
    size: Size(700, 120),
    minimumSize: Size(700, 120),
    maximumSize: Size(700, 120),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // 常に前面表示
    await windowManager.setAlwaysOnTop(true);
  });

  runApp(const NowBarApp());
}


class NowBarApp extends StatelessWidget {
  const NowBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NowBar',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const NowBarHome(),
    );
  }
}


class NowBarHome extends StatelessWidget {
  const NowBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Center(
        child: Container(
          width: 700,
          height: 120,

          decoration: BoxDecoration(
            color: const Color(0xff181818),

            borderRadius: BorderRadius.circular(20),

            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black54,
              )
            ],
          ),

          child: const Center(
            child: Text(
              '🎵 NowBar',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}