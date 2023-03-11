class BaiduConfigEntity {
  // id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  //     access_token TEXT(200) NOT NULL,
  //     expires_in INTEGER NOT NULL,
  //     session_secret TEXT(100),
  //     session_key TEXT(100),
  //     scope TEXT(100)
  int? id;
  String? accessToken;
  int? expiresIn;
  int? storeTime;
  String? sessionSecret;
  String? sessionKey;
  String? scope;

  BaiduConfigEntity({
    this.id,
    this.accessToken,
    this.expiresIn,
    this.storeTime,
    this.sessionKey,
    this.sessionSecret,
    this.scope,
  });
}
