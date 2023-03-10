class AppTables {
  static const String createGiteeSQL = '''
  CREATE TABLE IF NOT EXISTS gitee_config (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
      accessToken TEXT(100) NOT NULL, 
      owner TEXT(50) NOT NULL,
      repo TEXT(50) NOT NULL,
      sha TEXT(100) NOT NULL);
  ''';

  static Map<String, String> fetchTableCreateSQList() {
    return {
      "gitee_config": createGiteeSQL,
    };
  }
}
