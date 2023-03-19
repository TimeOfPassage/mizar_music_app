import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';
import 'package:mizar_music_app/extension/duration_extension.dart';
import 'package:mizar_music_app/utils/index.dart';
import 'package:path_provider/path_provider.dart';

class MusicPlayPage extends StatefulWidget {
  const MusicPlayPage({
    super.key,
    required this.musicList,
    this.currentIdx = 0,
  });
  final List<MusicInfoEntity> musicList;
  final int currentIdx;
  @override
  State<MusicPlayPage> createState() => _MusicPlayPageState();
}

class _MusicPlayPageState extends State<MusicPlayPage> {
  late AudioPlayer _player;
  // 是否开始播放
  bool _isPlaying = false;
  // 是否拖拽
  bool _isDragging = false;
  // 是否隐藏头部
  bool _isHideAppbar = true;
  // 播放模式 0-列表循环播放 1-单曲循环 2-随机播放
  int _currentPlayMode = 2;
  // 当前播放歌曲信息
  MusicInfoEntity? currentMusic;
  // 当前播放歌曲在列表中位置
  int? _currentIdx;
  // 播放进度
  Duration _duration = Duration.zero;
  // 播放位置
  Duration _position = Duration.zero;
  // 刚开始音量
  double _startVolume = 0.3;
  // 播放时间订阅
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _currentIndexSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
    try {
      setState(() {
        _currentIdx = widget.currentIdx;
        currentMusic = widget.musicList[_currentIdx!];
      });
      var directory = await getApplicationDocumentsDirectory();
      List<AudioSource> sourceList = [];
      for (var element in widget.musicList) {
        sourceList.add(AudioSource.uri(
          Uri.file("${directory.path}/mizar_music/${element.serverFileName}"),
          tag: MediaItem(
            id: element.id.toString(),
            title: element.musicName ?? "Unknown Music",
            album: element.author ?? "Unknown Author",
            artUri: Uri.parse(element.imageUrl!.isEmpty ? kDefaultUrl : element.imageUrl!),
          ),
        ));
      }
      final playlist = ConcatenatingAudioSource(useLazyPreparation: true, children: sourceList);
      await _player.setAudioSource(playlist, initialIndex: _currentIdx, initialPosition: Duration.zero);
      await _player.setVolume(_startVolume);
      //  0-列表循环播放 1-单曲循环 2-随机播放
      _setPlayMode(prevPlayMode: 1);
      _durationSubscription = _player.durationStream.listen((duration) {
        setState(() {
          _position = duration ?? Duration.zero;
          _duration = duration ?? Duration.zero;
          _position = Duration.zero;
        });
      });
      _positionSubscription = _player.positionStream.listen((position) {
        setState(() {
          _position = position;
          _duration = Duration(seconds: max(_duration.inSeconds, _position.inSeconds));
        });
      });
      _currentIndexSubscription = _player.currentIndexStream.listen((idx) {
        setState(() {
          _currentIdx = idx ?? 0;
          currentMusic = widget.musicList[_currentIdx!];
        });
      });
    } catch (e) {
      LoggerHelper.e('Error: $e');
    }
  }

  _play() async {
    setState(() {
      _isPlaying = true;
    });
    await _player.play();
  }

  _playPrev() async {
    bool oldPlaying = _isPlaying;
    await _stop();
    await _player.seekToPrevious();
    if (oldPlaying) {
      await _play();
    }
  }

  _playNext() async {
    bool oldPlaying = _isPlaying;
    await _stop();
    await _player.seekToNext();
    if (oldPlaying) {
      await _play();
    }
  }

  _pause() async {
    setState(() {
      _isPlaying = false;
    });
    await _player.pause();
  }

  _stop() async {
    setState(() {
      _isPlaying = false;
    });
    await _player.stop();
  }

  _seek(Duration duration) async {
    await _player.seek(duration, index: _currentIdx);
  }

  _onDragStart(double v) async {
    _isDragging = _isPlaying;
    await _pause();
  }

  _onDragEnd(double value) async {
    await _seek(Duration(seconds: value.toInt()));
    if (_isDragging) {
      await _play();
    }
  }

  _setPlayMode({int prevPlayMode = 0}) {
    if (prevPlayMode == 0) {
      _player.setLoopMode(LoopMode.one).then((value) {
        setState(() {
          _currentPlayMode = 1;
        });
      });
    }
    if (prevPlayMode == 1) {
      _player.setLoopMode(LoopMode.all).then((value) {
        setState(() {
          _currentPlayMode = 2;
        });
      });
    }
    if (prevPlayMode == 2) {
      _player.setLoopMode(LoopMode.off).then((value) {
        setState(() {
          _currentPlayMode = 0;
        });
      });
    }
  }

  Widget _buildPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0.0,
          max: max(_duration.inSeconds.toDouble(), _position.inSeconds.toDouble()),
          onChanged: (double value) {
            _seek(Duration(seconds: value.toInt()));
          },
          onChangeStart: _onDragStart,
          onChangeEnd: _onDragEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2 * AppSizes.kPaddingSize),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_position.toHMS(), style: const TextStyle(fontSize: 12.0)),
            Text(_duration.toHMS(), style: const TextStyle(fontSize: 12.0)),
          ]),
        ),
        AppSizes.boxH10,
        _buildPlayControlPanel(),
      ],
    );
  }

  Widget _buildPlayModeIcon() {
    // 播放模式 0-列表循环播放 1-单曲循环 2-随机播放
    switch (_currentPlayMode) {
      case 0:
        return const Icon(Icons.list, size: 26, color: Colors.white);
      case 1:
        return const Icon(AppIcons.onceLoop, size: 26, color: Colors.white);
      case 2:
        return const Icon(AppIcons.randomPlay, size: 26, color: Colors.white);
    }
    return const Icon(Icons.list, size: 26, color: Colors.white);
  }

  Widget _buildPlayControlPanel() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // play mode
          IconButton(icon: _buildPlayModeIcon(), onPressed: () => _setPlayMode(prevPlayMode: _currentPlayMode)),
          // prev music
          IconButton(icon: const Icon(Icons.skip_previous), color: Colors.white, onPressed: _playPrev),
          // play or pause
          SizedBox(
            width: 100,
            height: double.infinity,
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_fill_rounded, color: Colors.white, size: 60),
              onPressed: () {
                setState(() {
                  if (_isPlaying) {
                    _pause();
                  } else {
                    _play();
                  }
                });
              },
            ),
          ),
          // next music
          IconButton(icon: const Icon(Icons.skip_next), color: Colors.white, onPressed: _playNext),
          // play list
          IconButton(
            icon: const Icon(AppIcons.musicList, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isHideAppbar = !_isHideAppbar;
          });
        },
        child: Stack(children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(currentMusic!.imageUrl!.isEmpty ? kDefaultUrl : currentMusic!.imageUrl!, fit: BoxFit.fill),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: kToolbarHeight),
                Text(currentMusic?.musicName ?? "Unkonwn", style: const TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
                Text(currentMusic?.author ?? "Unkonwn Author", style: const TextStyle(color: Colors.white, fontSize: 18.0)),
                const Spacer(),
                Container(
                  width: w / 2,
                  height: w / 2,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(w / 2), boxShadow: const [
                    BoxShadow(color: Colors.white, blurRadius: 30),
                  ]),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(currentMusic!.imageUrl!.isEmpty ? kDefaultUrl : currentMusic!.imageUrl!, fit: BoxFit.fill),
                ),
                const Spacer(),
                const SizedBox(height: 24.0),
                _buildPlayer(),
                const SizedBox(height: kToolbarHeight),
              ],
            ),
          ),
          !_isHideAppbar ? refAppBar(context: context, title: "", backColor: Colors.white, backgroundColor: Colors.transparent) : const SizedBox.shrink(),
          !_isHideAppbar
              ? Container(
                  width: double.infinity,
                  height: 48,
                  margin: const EdgeInsets.only(top: kToolbarHeight * 3, left: 2 * AppSizes.kPaddingSize, right: 2 * AppSizes.kPaddingSize),
                  child: Row(children: [
                    const Icon(Icons.volume_up, color: Colors.white),
                    Expanded(
                      child: SliderTheme(
                        data: const SliderThemeData(activeTrackColor: Colors.white, inactiveTrackColor: Colors.white30, thumbColor: Colors.white),
                        child: Slider(
                          value: _startVolume,
                          onChanged: (v) {
                            setState(() {
                              _startVolume = v;
                            });
                            _player.setVolume(_startVolume);
                          },
                          onChangeEnd: (v) {
                            setState(() {
                              _startVolume = v;
                            });
                            _player.setVolume(_startVolume);
                          },
                        ),
                      ),
                    ),
                  ]),
                )
              : const SizedBox.shrink(),
        ]),
      ),
    );
  }
}
