import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';
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
    String musicFile = "file://${directory.path}/mizar_music/${widget.musicInfoEntity.serverFileName}";
    var duration = await player.setUrl(musicFile);
    LoggerHelper.i(duration);
    player.setVolume(0.3);
    await player.play();
    setState(() {
      isPlaying = true;
    });
  }

  Widget _buildMainView() {
    return Scaffold(
      appBar: refAppBar(context: context, title: widget.musicInfoEntity.musicName ?? "Unkonwn"),
      // body: Center(
      //   child: VlcPlayer(
      //     controller: _videoPlayerController,
      //     aspectRatio: 16 / 9,
      //     placeholder: const Center(child: CircularProgressIndicator()),
      //   ),
      // ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight + 54,
        color: Colors.amber.withAlpha(100),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios_sharp, size: 48)),
          !isPlaying
              ? IconButton(
                  onPressed: () async {
                    await player.pause();
                    setState(() {
                      isPlaying = false;
                    });
                  },
                  icon: const Icon(Icons.pause_circle_filled, size: 48),
                )
              : IconButton(
                  onPressed: () async {
                    await player.play();
                    setState(() {
                      isPlaying = true;
                    });
                  },
                  icon: const Icon(Icons.play_circle_fill, size: 48),
                ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_right_sharp, size: 48)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
