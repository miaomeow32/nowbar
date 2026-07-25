import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PlayerData {
  // AppData\Roaming\NowBar を使用
  late final String basePath =
      "${Platform.environment['APPDATA']}\\NowBar";

  late final String jsonPath =
      "$basePath\\nowplaying.json";

  late final String commandPath =
      "$basePath\\command.json";

  String title = "";
  String artist = "";
  String image = "";

  bool isPlaying = false;

  double duration = 1;
  double position = 0;

  // 表示用補間
  double syncPosition = 0;
  DateTime? lastSync;

  Timer? timer;

  Function? onUpdate;

  PlayerData() {
    // AppData\Roaming\NowBar フォルダが無ければ作成
    Directory(basePath).createSync(recursive: true);
  }

  void start() {
    timer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) {
        read();
      },
    );
  }

  Future<void> read() async {
    try {
      final file = File(jsonPath);

      if (!await file.exists()) {
        return;
      }

      final text = await file.readAsString();
      final data = jsonDecode(text);

      title = data["title"]?.toString() ?? "";
      artist = data["artist"]?.toString() ?? "";
      image = data["image"]?.toString() ?? "";

      isPlaying = data["isPlaying"] == true;

      duration =
          (data["duration"] ?? 1).toDouble();

      position =
          (data["position"] ?? 0).toDouble();

      syncPosition = position;
      lastSync = DateTime.now();

      onUpdate?.call();
    } catch (e) {
      print("PlayerData error: $e");
    }
  }

  double get smoothPosition {
    if (isPlaying && lastSync != null) {
      double value =
          syncPosition +
              DateTime.now()
                      .difference(lastSync!)
                      .inMilliseconds /
                  1000.0;

      if (value < 0) value = 0;
      if (value > duration) value = duration;

      return value;
    }

    return position;
  }

  Future<void> command(String value) async {
    try {
      await File(commandPath).writeAsString(
        jsonEncode({
          "command": value,
        }),
      );
    } catch (e) {
      print("Command error: $e");
    }
  }

  void dispose() {
    timer?.cancel();
  }
}