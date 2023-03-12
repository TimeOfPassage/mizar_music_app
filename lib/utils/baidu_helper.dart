import 'index.dart';

class BaiduHelper {
  BaiduHelper._internal();
  factory BaiduHelper() => _instance;
  static final BaiduHelper _instance = BaiduHelper._internal();

  static String? _accessToken;

  static Future<String> accessToken() async {
    if (_accessToken != null) {
      return _accessToken!;
    }
    String existSql = "select * from baidu_config";
    List<Map<dynamic, dynamic>> results = await TableHelper.query(existSql);
    if (results.isNotEmpty) {
      Map<dynamic, dynamic> res = results[0];
      _accessToken = res['access_token'];
      return _accessToken!;
    }
    return "";
  }
}
