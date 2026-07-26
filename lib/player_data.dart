import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PlayerData {
  late final String basePath =
      "${Platform.environment['APPDATA']}\\NowBar";

  late final String jsonPath =
      "$basePath\\nowplaying.json";

  late final String commandPath =
      "$basePath\\command.json";

  // =========================
  // 曲情報
  // =========================
  String title = "";
  String artist = "";
  String image = "";

  bool isPlaying = false;

  double duration = 0;
  double position = 0;
  double? volume;

  // =========================
  // 再生バー補間
  // =========================
  double syncPosition = 0;
  DateTime? lastSync;

  Timer? timer;
  Function? onUpdate;

  // =========================
  // 前回値
  // =========================
  String oldTitle = "";
  String oldArtist = "";
  String oldImage = "";
  double oldDuration = 0;
  bool oldPlaying = false;

  bool reading = false;

  PlayerData() {
    Directory(basePath)
        .createSync(
          recursive: true,
        );
  }

  // =========================
  // 監視開始
  // =========================
  void start() {
    timer = Timer.periodic(
      const Duration(
        milliseconds: 200,
      ),
      (_) {
        read();
      },
    );
  }

  // =========================
  // JSON読み込み
  // =========================
  Future<void> read() async {
    if (reading) {
      return;
    }
    reading = true;

    try {
      final file =
          File(jsonPath);

      if (!await file.exists()) {
        return;
      }

      final text =
          await file.readAsString();

      if (text.isEmpty) {
        return;
      }

      final data =
          jsonDecode(text);

      final newTitle =
          data["title"]?.toString() ?? "";

      final newArtist =
          data["artist"]?.toString() ?? "";

      final newImage =
          data["image"]?.toString() ?? "";

      final newPlaying =
          data["isPlaying"] == true;

      final newDuration =
          double.tryParse(
            "${data["duration"] ?? 0}",
          ) ?? 0;

      final newPosition =
          double.tryParse(
            "${data["position"] ?? 0}",
          ) ?? 0;

      final newVolume = data["volume"] == null
          ? null
          : double.tryParse("${data["volume"]}");

      // =========================
      // 変更検知
      // =========================
      final songChanged =
          oldTitle != newTitle ||
          oldArtist != newArtist ||
          oldImage != newImage ||
          oldDuration != newDuration;

      final stateChanged =
          oldPlaying != newPlaying;

      // =========================
      // データ更新
      // =========================
      title =
          newTitle;

      artist =
          newArtist;

      image =
          newImage;

      isPlaying =
          newPlaying;

      if (newDuration > 0) {
        duration =
            newDuration;
      }

      position =
          newPosition;

      volume = newVolume;

      // =========================
      // 再生バー同期
      // =========================
      if (songChanged) {
        // 曲変更時
        // 必ず新曲位置へ移動
        syncPosition =
            newPosition;

        lastSync =
            DateTime.now();
      } else if (stateChanged) {
        // 再生状態変更
        syncPosition =
            newPosition;

        lastSync =
            DateTime.now();
      } else {
        // 通常再生中
        // JSONとの差を確認
        final diff =
            (newPosition - syncPosition)
                .abs();

        // 2秒以上ズレたら補正
        if (diff > 2) {
          syncPosition =
              newPosition;

          lastSync =
              DateTime.now();
        }
      }

      // =========================
      // 前回保存
      // =========================
      oldTitle =
          newTitle;

      oldArtist =
          newArtist;

      oldImage =
          newImage;

      oldDuration =
          newDuration;

      oldPlaying =
          newPlaying;

      onUpdate?.call();
    } catch (e) {
      print(
        "PlayerData error : $e",
      );
    } finally {
      reading = false;
    }
  }

  // =========================
  // 表示用再生位置
  // =========================
  double get smoothPosition {
    if (
      isPlaying &&
      lastSync != null
    ) {
      double value =
          syncPosition +
          DateTime.now()
              .difference(
                lastSync!,
              )
              .inMilliseconds
              /
              1000.0;

      if (value < 0) {
        value = 0;
      }

      if (
        duration > 0 &&
        value > duration
      ) {
        value = duration;
      }

      return value;
    }

    return position;
  }

  // =========================
  // コマンド送信
  // =========================
  Future<void> command(String value, {double? volume}) async {
    try {
      await File(commandPath)
          .writeAsString(
            jsonEncode({
              "command": value,
              if (volume != null) "volume": volume,
              "time":
              DateTime.now()
                  .millisecondsSinceEpoch,
            }),
          );
    } catch (e) {
      print(
        "Command error : $e",
      );
    }
  }

  Future<void> setVolume(double value) =>
      command("setVolume", volume: value.clamp(0, 1));

  // =========================
  // 終了
  // =========================
  void dispose() {
    timer?.cancel();
  }
}
