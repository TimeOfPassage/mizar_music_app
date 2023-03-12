import 'package:dio/dio.dart';
import 'package:mizar_music_app/utils/index.dart';

class RequestHelper {
  RequestHelper._internal();
  factory RequestHelper() => _instance;
  static final RequestHelper _instance = RequestHelper._internal();

  static final _dio = Dio();

  static dynamic request({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    LoggerHelper.d("请求URL: $url");
    Response response = await _dio.request(
      url,
      queryParameters: params,
      options: Options(headers: headers),
    );
    if (response.statusCode != 200) {
      LoggerHelper.e(response);
    } else {
      LoggerHelper.d(response);
    }
    return response.data;
  }

  static dynamic download({
    required String url,
    required String savePath,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    Object? data,
    void Function(int, int)? onReceiveProgress,
  }) async {
    LoggerHelper.d("请求URL: $url");
    Response<dynamic> response = await _dio.download(
      url,
      savePath,
      queryParameters: params,
      data: data,
      options: Options(headers: headers),
      onReceiveProgress: onReceiveProgress,
    );
    if (response.statusCode != 200) {
      LoggerHelper.e(response);
    } else {
      LoggerHelper.d(response);
    }
    return response;
  }
}
