import 'package:mizar_music_app/utils/request_helper.dart';

const Map<String, String> headers = {"User-Agent": "pan.baidu.com"};

class BaiduApi {
  static Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    String url = "https://pan.baidu.com/rest/2.0/xpan/nas?access_token=$accessToken&method=uinfo";
    return await RequestHelper.request(url: url, headers: headers);
  }

  static Future<Map<String, dynamic>> getNetdiskCapicity(String accessToken) async {
    String url = "https://pan.baidu.com/api/quota?access_token=$accessToken&checkfree=1&checkexpire=1";
    return await RequestHelper.request(url: url, headers: headers);
  }

  static Future<Map<String, dynamic>> getMusicList(String accessToken, {int start = 1, int limit = 100, String syncDir = '/mizar_music'}) async {
    String url = "http://pan.baidu.com/rest/2.0/xpan/file?access_token=$accessToken&method=list&dir=$syncDir&order=size&desc=1&start=$start&limit=$limit";
    return await RequestHelper.request(url: url, headers: headers);
  }

  static Future<Map<String, dynamic>> getFileInfo(String accessToken, List<String> fids) async {
    String url = "http://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&access_token=$accessToken&fsids=$fids&thumb=1&dlink=1&extra=1";
    return await RequestHelper.request(url: url, headers: headers);
  }

  static download(String url, String savePath) async {
    await RequestHelper.download(url: url, savePath: savePath, headers: headers);
  }
}
