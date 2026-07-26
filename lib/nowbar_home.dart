import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:window_manager/window_manager.dart';

import 'player_data.dart';

class NowBarHome extends StatefulWidget {
  const NowBarHome({super.key});

  @override
  State<NowBarHome> createState() => _NowBarHomeState();
}

class _NowBarHomeState extends State<NowBarHome> with WidgetsBindingObserver, WindowListener {
  final PlayerData player = PlayerData();

  String displayedTitle = "";
  String displayedArtist = "";

  int imageVersion = 0;
  DateTime? lastModified;

  Color themeColor = const Color(0xff2196f3);
  Color oldThemeColor = const Color(0xff2196f3);

  bool alwaysOnTop = true;
  bool isWindowLocked = false;
  bool isMenuOpen = false;
  double? draggedVolume;

  static const double defaultHeight = 45.0;
  static const double expandedHeight = 185.0; // メニューを含めた全体の高さ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);

    _initWindowSettings();

    player.onUpdate = () async {
      if (player.image.isNotEmpty) {
        try {
          final file = File(player.image);
          if (await file.exists()) {
            final modified = await file.lastModified();
            if (lastModified != modified) {
              lastModified = modified;
              imageVersion++;
              await updateThemeColor();
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
            }
          }
        } catch (e) {
          debugPrint("Image handle error: $e");
        }
      }

      if (mounted) {
        setState(() {
          displayedTitle = player.title;
          displayedArtist = player.artist;
        });
      }
    };

    player.start();
  }

  Future<void> _initWindowSettings() async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setBackgroundColor(Colors.transparent);
  }

  Future<void> toggleAlwaysOnTop() async {
    alwaysOnTop = !alwaysOnTop;
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    if (mounted) setState(() {});
  }

  Future<void> toggleWindowLock() async {
    isWindowLocked = !isWindowLocked;
    await windowManager.setMovable(!isWindowLocked);
    if (mounted) setState(() {});
  }

  // 【修正】メニューを開くとき：下端の位置を維持したまま、上に高さを広げる
  Future<void> openContextMenu() async {
    if (isMenuOpen) return;
    final rect = await windowManager.getBounds();
    
    // 現在の下端 Y座標 (bottom = top + height) を計算
    final double currentBottom = rect.top + rect.height;
    // 新しいtop座標 = 下端 - 拡張後の高さ
    final double newTop = currentBottom - expandedHeight;

    await windowManager.setBounds(
      Rect.fromLTWH(rect.left, newTop, rect.width, expandedHeight),
    );
    if (mounted) setState(() => isMenuOpen = true);
  }

  // 【修正】メニューを閉じるとき：下端の位置を維持したまま、高さを元に戻す
  Future<void> closeContextMenu() async {
    if (!isMenuOpen) return;
    if (mounted) setState(() => isMenuOpen = false);

    final rect = await windowManager.getBounds();
    final double currentBottom = rect.top + rect.height;
    final double newTop = currentBottom - defaultHeight;

    await windowManager.setBounds(
      Rect.fromLTWH(rect.left, newTop, rect.width, defaultHeight),
    );
  }

  Future<void> updateThemeColor() async {
    try {
      final file = File(player.image);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();
      final Color? calculatedColor = await compute(_extractThemeColor, bytes);

      if (calculatedColor != null && mounted) {
        setState(() {
          oldThemeColor = themeColor;
          themeColor = calculatedColor;
        });
      }
    } catch (e) {
      debugPrint("Theme color error : $e");
    }
  }

  Widget backgroundImage() {
    if (player.image.isNotEmpty && File(player.image).existsSync()) {
      return Positioned.fill(
        child: Image.file(
          File(player.image),
          key: ValueKey("background_$imageVersion"),
          fit: BoxFit.cover,
        ),
      );
    }
    return const SizedBox();
  }

  Widget albumImage() {
    if (player.image.isNotEmpty && File(player.image).existsSync()) {
      final file = File(player.image);
      return Image(
        key: ValueKey("${file.path}_$imageVersion"),
        image: FileImage(file),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return Container(color: const Color(0xff333333));
        },
      );
    }
    return Container(color: const Color(0xff333333));
  }

  String timeText(double sec) {
    final int s = sec.floor();
    final int m = s ~/ 60;
    final int ss = s % 60;
    return "$m:${ss.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final double position = player.smoothPosition;
    double progress = player.duration <= 0 ? 0 : position / player.duration;
    progress = progress.clamp(0, 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: closeContextMenu,
        onPanStart: (details) async {
          if (isWindowLocked) return;
          if (isMenuOpen) {
            await closeContextMenu();
          }
          await windowManager.startDragging();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 1. メニュー部分（ウィンドウが広がった上部に表示）
              if (isMenuOpen)
                Positioned(
                  left: 4,
                  bottom: defaultHeight + 4,
                  child: Material(
                    color: Colors.transparent,
                    child: TweenAnimationBuilder<Color?>(
                      key: ValueKey(themeColor),
                      tween: ColorTween(begin: oldThemeColor, end: themeColor),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, animatedColor, child) {
                        final currentColor = animatedColor ?? themeColor;
                        return Container(
                          width: 240,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: currentColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 3, 8, 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.volume == null
                                          ? 'Spotify を再生すると音量を同期します'
                                          : 'Spotify 音量 ${(draggedVolume ?? player.volume! * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 28,
                                      child: Slider(
                                        value: draggedVolume ?? (player.volume ?? 0) * 100,
                                        min: 0,
                                        max: 100,
                                        activeColor: currentColor,
                                        onChanged: player.volume == null
                                            ? null
                                            : (value) => setState(() => draggedVolume = value),
                                        onChangeEnd: player.volume == null
                                            ? null
                                            : (value) async {
                                                await player.setVolume(value / 100);
                                                if (mounted) {
                                                  setState(() => draggedVolume = null);
                                                }
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, thickness: 0.5, color: Colors.white24),
                              InkWell(
                                onTap: () {
                                  toggleAlwaysOnTop();
                                  closeContextMenu();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        alwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                                        size: 14,
                                        color: alwaysOnTop ? currentColor : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        alwaysOnTop ? "最前面 ON" : "最前面 OFF",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 0.5, color: Colors.white24),
                              InkWell(
                                onTap: () {
                                  toggleWindowLock();
                                  closeContextMenu();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isWindowLocked ? Icons.lock : Icons.lock_open,
                                        size: 14,
                                        color: isWindowLocked ? currentColor : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isWindowLocked ? "画面固定 ON" : "画面固定 OFF",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 0.5, color: Colors.white24),
                              InkWell(
                                onTap: () async {
                                  await windowManager.close();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "アプリ終了",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // 2. プレイヤー本体のバー（常に下部に固定）
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onSecondaryTapDown: (detail) {
                    if (isMenuOpen) {
                      closeContextMenu();
                    } else {
                      openContextMenu();
                    }
                  },
                  child: SizedBox(
                    height: defaultHeight,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          backgroundImage(),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: albumImage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TweenAnimationBuilder<Color?>(
                                        key: ValueKey(themeColor),
                                        tween: ColorTween(
                                          begin: oldThemeColor,
                                          end: themeColor,
                                        ),
                                        duration: const Duration(milliseconds: 600),
                                        builder: (context, animatedColor, child) {
                                          final currentColor = animatedColor ?? themeColor;
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: Duration.zero,
                                                child: ClipRect(
                                                  child: TweenAnimationBuilder<double>(
                                                    key: ValueKey(displayedTitle),
                                                    tween: Tween(begin: 1.0, end: 0.0),
                                                    duration: const Duration(milliseconds: 450),
                                                    curve: Curves.easeOutQuart,
                                                    builder: (context, value, child) {
                                                      return Transform.translate(
                                                        offset: Offset(35 * value, 0),
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      displayedTitle.isEmpty ? "No Music" : displayedTitle,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: currentColor,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 1.5),
                                              AnimatedSwitcher(
                                                duration: Duration.zero,
                                                child: ClipRect(
                                                  child: TweenAnimationBuilder<double>(
                                                    key: ValueKey(displayedArtist),
                                                    tween: Tween(begin: 1.0, end: 0.0),
                                                    duration: const Duration(milliseconds: 450),
                                                    curve: Curves.easeOutQuart,
                                                    builder: (context, value, child) {
                                                      return Opacity(
                                                        opacity: (1 - value).clamp(0.0, 1.0),
                                                        child: Transform.translate(
                                                          offset: Offset(35 * value, 0),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: child,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      displayedArtist,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 8.5,
                                                        color: currentColor.withValues(alpha: 0.75),
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2.5),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 2,
                                                      child: LinearProgressIndicator(
                                                        value: progress,
                                                        color: currentColor,
                                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${timeText(position)}/${timeText(player.duration)}",
                                                    style: const TextStyle(
                                                      fontSize: 7,
                                                      color: Colors.white70,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.skip_previous, size: 16),
                                    onPressed: () => player.command("previous"),
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: TweenAnimationBuilder<Color?>(
                                      key: ValueKey(themeColor),
                                      tween: ColorTween(
                                        begin: oldThemeColor,
                                        end: themeColor,
                                      ),
                                      duration: const Duration(milliseconds: 600),
                                      builder: (context, animatedColor, child) {
                                        final currentColor = animatedColor ?? themeColor;
                                        return Icon(
                                          player.isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                                          size: 22,
                                          color: currentColor,
                                        );
                                      },
                                    ),
                                    onPressed: () => player.command("playpause"),
                                  ),
                                ),
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.skip_next, size: 16),
                                    onPressed: () => player.command("next"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    player.dispose();
    super.dispose();
  }
}

Color? _extractThemeColor(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final Map<String, int> colors = {};

  for (int y = 0; y < image.height; y += 10) {
    for (int x = 0; x < image.width; x += 10) {
      final pixel = image.getPixel(x, y);

      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();

      int brightness = (r + g + b) ~/ 3;

      if (brightness < 35 || brightness > 230) {
        continue;
      }

      r = (r ~/ 20) * 20;
      g = (g ~/ 20) * 20;
      b = (b ~/ 20) * 20;

      String key = "$r,$g,$b";
      colors[key] = (colors[key] ?? 0) + 1;
    }
  }

  if (colors.isEmpty) return null;

  String result = colors.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

  List<int> rgb = result.split(",").map(int.parse).toList();

  double brightness = (rgb[0] + rgb[1] + rgb[2]) / 3;

  double r = rgb[0].toDouble();
  double g = rgb[1].toDouble();
  double b = rgb[2].toDouble();

  if (brightness < 100) {
    r += 90;
    g += 90;
    b += 90;
  }

  if (brightness > 220) {
    r *= 0.75;
    g *= 0.75;
    b *= 0.75;
  }

  return Color.fromARGB(
    255,
    r.clamp(0, 255).toInt(),
    g.clamp(0, 255).toInt(),
    b.clamp(0, 255).toInt(),
  );
}
