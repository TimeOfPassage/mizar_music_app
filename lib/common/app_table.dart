class AppTables {
  static const String createGiteeSQL = '''
    CREATE TABLE IF NOT EXISTS gitee_config (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
      accessToken TEXT(100) NOT NULL, 
      owner TEXT(50) NOT NULL,
      repo TEXT(50) NOT NULL,
      sha TEXT(100) NOT NULL
    );
  ''';

  static const String createBaiduConfigSQL = '''
    CREATE TABLE IF NOT EXISTS baidu_config (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
      access_token TEXT(200) NOT NULL, 
      expires_in INTEGER NOT NULL,
      store_time INTEGER NOT NULL,
      session_secret TEXT(100), 
      session_key TEXT(100), 
      scope TEXT(100)
    );
  ''';


  static const String createMusicListSQL = '''
    CREATE TABLE IF NOT EXISTS t_music_list (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
      fs_id INTEGER NOT NULL, 
      size INTEGER NOT NULL,
      create_time INTEGER NOT NULL,
      path TEXT(200) NOT NULL, 
      server_filename TEXT(100) NOT NULL,
      music_name TEXT(100) NOT NULL,
      author TEXT(100) NOT NULL,
      image_url TEXT(1000) NOT NULL,
      is_sync INTEGER NOT NULL
    );
  ''';

  static Map<String, String> fetchTableCreateSQList() {
    return {
      "gitee_config": createGiteeSQL,
      "baidu_config": createBaiduConfigSQL,
      "t_music_list": createMusicListSQL,
    };
  }
}
