import 'dart:convert';

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

  static Future<String> fetchHoverUrl(String kw) async {
    var response = await RequestHelper.request(
      url: 'https://image.baidu.com/search/acjson?tn=resultjson_com&ipn=rj&ie=utf-8&oe=utf-8&logid=10616783841481369264&word=$kw&queryWord=$kw&z=0&pn=1&rn=1',
      headers: {
        'Cookie': 'BAIDUID=8BA5753D8A7B800035B658A6C62FA360:FG=1; BDRCVFR[-pGxjrCMryR]=mk3SLVN4HKm; BIDUPSID=8BA5753D8A7B800035B658A6C62FA360',
        'User-Agent': 'pan.baidu.com',
      },
    );
    // LoggerHelper.d(jsonDecode(jsonEncode(response)));
    var jsonRes = jsonDecode(jsonEncode(response));
    var dataList = (jsonRes['data'] ?? []) as List;
    if (dataList.isEmpty) {
      return Future.value("");
    }
    var replaceUrls = dataList[0]['replaceUrl'] as List;
    if (replaceUrls.isEmpty) {
      return Future.value(dataList[0]['hoverUrl']);
    }
    var objMap = replaceUrls[0] as Map;
    return Future.value(objMap['ObjUrl']);
  }
}

// void main(List<String> args) {
//   BaiduHelper.fetchHoverUrl("听-张杰");
// }
