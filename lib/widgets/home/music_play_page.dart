import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';
import 'package:mizar_music_app/extension/duration_extension.dart';
import 'package:mizar_music_app/utils/index.dart';
import 'package:path_provider/path_provider.dart';

class MusicPlayPage extends StatefulWidget {
  const MusicPlayPage({
    super.key,
    required this.musicInfoEntity,
  });
  final MusicInfoEntity musicInfoEntity;
  @override
  State<MusicPlayPage> createState() => _MusicPlayPageState();
}

class _MusicPlayPageState extends State<MusicPlayPage> {
  late AudioPlayer player;

  bool isPlaying = false;

  String? startDuration;
  String? endDuration;

  double? totalTime;
  double? currentPlayTime;

  @override
  void dispose() async {
    super.dispose();
    await player.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchMusicInfo();
  }

  _fetchMusicInfo() async {
    var directory = await getApplicationDocumentsDirectory();
    player = AudioPlayer();
    // 播放状态监听
    player.positionStream.listen((duration) {
      // LoggerHelper.i("$duration, ${duration.inMinutes < 10 ? "0${duration.inMinutes}" : duration.inMinutes}:${duration.inSeconds}");
      String thisDuration = duration.toMinuteSeconds();
      if (startDuration != null && startDuration == thisDuration) {
        return;
      }
      setState(() {
        startDuration = thisDuration;
        currentPlayTime = duration.inSeconds.toDouble();
      });
    });
    String musicFile = "file://${directory.path}/mizar_music/${widget.musicInfoEntity.serverFileName}";
    Duration? duration = await player.setUrl(musicFile);
    LoggerHelper.i(duration);
    player.setVolume(0.3);
    setState(() {
      isPlaying = true;
      if (duration != null) {
        totalTime = duration.inSeconds.toDouble();
        endDuration = "${duration.inMinutes < 10 ? "0${duration.inMinutes}" : duration.inMinutes}:${(duration.inSeconds / 10).floor()}";
      }
    });
    await player.play();
  }

  Widget _buildMainView() {
    return Scaffold(
      // appBar: refAppBar(context: context, title: widget.musicInfoEntity.musicName ?? "Unkonwn"),
      body: Stack(children: [
        // background image
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network("https://scpic.chinaz.net/files/default/imgs/2023-02-23/abaa5a786ed46b8c.jpg", fit: BoxFit.fill),
        ),
        // BackdropFilter filter
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.white.withAlpha(0)),
        ),
        // real content
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(children: [
              refAppBar(
                context: context,
                backgroundColor: Colors.transparent,
                backColor: Colors.white,
                title: widget.musicInfoEntity.musicName ?? "Unkonwn",
              ),
              AppSizes.boxH200,
              Text(widget.musicInfoEntity.musicName ?? "", style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
              Text(widget.musicInfoEntity.author ?? "", style: const TextStyle(fontSize: 18)),
              const Spacer(),
              _buildBottomPlayArea(),
            ]),
          ),
        ),
      ]),
      // bottomNavigationBar: _buildBottomPlayArea(),
    );
  }

  Widget _buildBottomPlayArea() {
    return SizedBox(
      width: double.infinity,
      height: kBottomNavigationBarHeight + 100,
      child: Column(
        children: [
          // progress indicator
          Container(
            width: double.infinity,
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.kPaddingSize),
            child: Row(children: [
              AppSizes.boxW10,
              SizedBox(
                width: 35,
                height: 14,
                child: Text(startDuration ?? "00:00", style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 2,
                  child: Slider(
                    value: currentPlayTime ?? 0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    min: 0,
                    max: totalTime ?? 300,
                    onChangeStart: (v) async {
                      setState(() {
                        isPlaying = false;
                      });
                      await player.pause();
                    },
                    onChanged: (v) {
                      setState(() {
                        currentPlayTime = v;
                        // debugPrint(currentPlayTime.toString());
                      });
                    },
                    onChangeEnd: (v) async {
                      setState(() {
                        isPlaying = true;
                      });
                      int minutes = (v / 60).floor();
                      if (minutes < 0) {
                        await player.seek(Duration(seconds: v.toInt()));
                      } else {
                        int seconds = (v % 60).floor();
                        await player.seek(Duration(minutes: minutes, seconds: seconds));
                      }
                      await player.play();
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                height: 14,
                child: Text(endDuration ?? "--:--", style: const TextStyle(fontSize: 12)),
              ),
              AppSizes.boxW10,
            ]),
          ),
          // play control panel
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_left_sharp, size: 48)),
              isPlaying
                  ? IconButton(
                      onPressed: () async {
                        setState(() {
                          isPlaying = false;
                        });
                        await player.pause();
                      },
                      icon: const Icon(Icons.pause_circle_filled, size: 64),
                    )
                  : IconButton(
                      onPressed: () async {
                        setState(() {
                          isPlaying = true;
                        });
                        if (currentPlayTime != null && currentPlayTime! > 0) {
                          int minutes = (currentPlayTime! / 60).floor();
                          if (minutes < 0) {
                            await player.seek(Duration(seconds: currentPlayTime!.toInt()));
                          } else {
                            int seconds = (currentPlayTime! % 60).floor();
                            await player.seek(Duration(minutes: minutes, seconds: seconds));
                          }
                        } else {
                          await player.seek(const Duration(seconds: 1));
                        }
                        await player.play();
                      },
                      icon: const Icon(Icons.play_circle_fill, size: 64),
                    ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_arrow_right_sharp, size: 48),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
