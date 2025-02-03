
import 'dart:convert';

import 'package:bellucare/service/config_service.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:dio/dio.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._privateConstructor();

  factory HttpClient() {
    return _instance;
  }

  final Dio _dio = Dio();
  HttpClient._privateConstructor() {
    _dio.options = BaseOptions(
      baseUrl: ConfigService().appConfig.api,
      responseDecoder: (responseBytes, options, responseBody) {
        return decoder.convert(responseBytes);
      },
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    );
  }

  final decoder = Utf8Decoder();
  Future<Map<String, dynamic>?> get(String path, {
    Map<String, dynamic>? params
  }) async {
    var response = await _dio.get(path, queryParameters: params);
    if (response.statusCode == 200) {
      debug("${response.data} ${response.data.runtimeType}");
      return response.data;
    } else {
      return {};
    }
  }

  Future<List<dynamic>> getList(String path, {
    Map<String, dynamic>? params
  }) async {
    var response = await _dio.get(path, queryParameters: params);
    if (response.statusCode == 200) {
      debug("response: ${response.data} ${response.data.runtimeType}");
      return response.data as List<dynamic>;
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post(path, data: data);
      if (response.statusCode == 200) {
        debug("response ok ${response.data}");
        return response.data;
      } else {
        debug("====> ?? ${response.data} <====");
        return {};
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        debug("${e.response!.data["message"]}");
      }
      return null;
    } catch (e) {
      debug("error ${e.toString()} ${e.runtimeType}");
      return null;
    }
  }

  void setToken(String token) {
    _dio.options.headers["X-AUTH-TOKEN"] = token;
  }

  void clearToken() {
    _dio.options.headers.remove("X-AUTH-TOKEN");
  }
}
