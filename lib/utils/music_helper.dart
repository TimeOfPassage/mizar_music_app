import 'package:mizar_music_app/entity/music_info.dart';

import 'index.dart';

class MusicHelper {
  MusicHelper._internal();
  factory MusicHelper() => _instance;
  static final MusicHelper _instance = MusicHelper._internal();

  static Future<List<MusicInfoEntity>> randomFetchThreeMusicList() async {
    List<Map> musicList = await TableHelper.query("select * from t_music_list");
    return musicList.map((e) => MusicInfoEntity.fromMap(e as Map<String, dynamic>)).toList();
  }
}
