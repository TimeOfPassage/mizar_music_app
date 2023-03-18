import 'dart:async';
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
    required this.musicList,
    this.currentIdx = 0,
  });
  final List<MusicInfoEntity> musicList;
  final int currentIdx;
  @override
  State<MusicPlayPage> createState() => _MusicPlayPageState();
}

class _MusicPlayPageState extends State<MusicPlayPage> {
  final AudioPlayer _player = AudioPlayer();
  // 是否开始播放
  bool _isPlaying = false;
  // 是否拖拽
  bool _isDragging = false;
  // 是否隐藏头部
  bool _isHideAppbar = true;
  // 播放模式 0-列表循环播放 1-单曲循环
  int _playMode = 0;
  // 当前播放歌曲信息
  MusicInfoEntity? currentMusic;
  // 当前播放歌曲在列表中位置
  int? _currentIdx;
  // 播放进度
  Duration _duration = Duration.zero;
  // 播放位置
  Duration _position = Duration.zero;
  // 播放时间订阅
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _currentIndexSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        sourceList.add(AudioSource.file("${directory.path}/mizar_music/${element.serverFileName}"));
      }
      // Define the playlist
      final playlist = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Customise the shuffle algorithm
        // shuffleOrder: DefaultShuffleOrder(),
        // Specify the playlist items
        children: sourceList,
      );
      await _player.setAudioSource(playlist, initialIndex: _currentIdx, initialPosition: Duration.zero) ?? Duration.zero;
      _durationSubscription = _player.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
      _positionSubscription = _player.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      _currentIndexSubscription = _player.currentIndexStream.listen((idx) {
        setState(() {
          _currentIdx = idx ?? 0;
          currentMusic = widget.musicList[_currentIdx!];
        });
      });
      _playerStateSubscription = _player.playerStateStream.listen((e) {
        if (e.processingState == ProcessingState.completed) {
          _stop();
          _playNext();
        }
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
    await _player.seekToPrevious();
  }

  _playNext() async {
    await _player.seekToNext();
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
    // LoggerHelper.i(value);
    await _seek(Duration(seconds: value.toInt()));
    if (_isDragging) {
      await _play();
    }
  }

  Widget _buildPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0.0,
          max: _duration.inSeconds.toDouble(),
          onChanged: (double value) {
            // LoggerHelper.i("onChanged $value");
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
    switch (_playMode) {
      case 0:
        return const Icon(AppIcons.foreverLoop, size: 26);
      case 1:
        return const Icon(AppIcons.onceLoop, size: 26);
      // case 2:
      //   return const Icon(AppIcons.randomPlay, size: 26);
    }
    return const Icon(AppIcons.foreverLoop, size: 26);
  }

  Widget _buildPlayControlPanel() {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // play mode
          IconButton(
            icon: _buildPlayModeIcon(),
            onPressed: () {
              setState(() {
                if (_playMode + 1 > 2) {
                  _playMode = 0;
                } else {
                  _playMode += 1;
                }
              });
            },
          ),
          // prev music
          IconButton(icon: const Icon(Icons.skip_previous), color: _currentIdx == 0 ? Colors.grey : null, onPressed: _playPrev),
          // play or pause
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_fill_rounded, size: 48),
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
          // next music
          IconButton(icon: const Icon(Icons.skip_next), color: _currentIdx == widget.musicList.length - 1 ? Colors.grey : null, onPressed: _playNext),
          // play list
          IconButton(
            icon: const Icon(AppIcons.musicList),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Image.network(currentMusic?.imageUrl ?? kDefaultUrl, fit: BoxFit.fill),
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
                Text(currentMusic?.musicName ?? "Unkonwn", style: const TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
                Text(currentMusic?.author ?? "Unkonwn Author", style: const TextStyle(color: Colors.white, fontSize: 18.0)),
                const SizedBox(height: 24.0),
                _buildPlayer(),
              ],
            ),
          ),
          !_isHideAppbar ? refAppBar(context: context, title: "", backgroundColor: Colors.transparent) : const SizedBox.shrink(),
        ]),
      ),
    );
  }
}
