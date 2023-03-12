class MusicInfoEntity {
  /// id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  // fs_id INTEGER NOT NULL,
  // size INTEGER NOT NULL,
  // create_time INTEGER NOT NULL,
  // path TEXT(200) NOT NULL,
  // server_filename TEXT(100) NOT NULL,
  // music_name TEXT(100) NOT NULL,
  // author TEXT(100) NOT NULL,
  ///
  int? id;

  /// 百度文件ID
  int? fsId;

  /// 文件大小,byte
  int? size;
  int? createTime;

  ///
  String? path;
  String? serverFileName;
  String? musicName;
  String? author;

  MusicInfoEntity(this.id, this.fsId, this.size, this.createTime, this.path, this.serverFileName, this.musicName, this.author);

  MusicInfoEntity.fromMap(Map<String, dynamic> json) {
    fsId = json['fs_id'];
    size = json['size'] ?? 0;
    createTime = DateTime.now().millisecondsSinceEpoch;
    path = json['path'];
    serverFileName = json['server_filename'];
    if (serverFileName != null) {
      List<String> infos = serverFileName!.split("-");
      musicName = infos[0];
      author = infos[1].substring(0, infos[1].lastIndexOf("."));
    }
  }
  // ("fs_id", "size", "create_time", "path", "server_filename", "music_name", "author" )
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['fs_id'] = fsId;
    map['size'] = size;
    map['create_time'] = createTime;
    map['path'] = path;
    map['server_filename'] = serverFileName;
    map['music_name'] = musicName;
    map['author'] = author;
    return map;
  }
}
