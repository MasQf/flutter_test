import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:test/models/error_message.dart';

String APPLICATION_JSON = "application/json";
const String CONTENT_TYPE = "content-type";
const String ACCEPT = "accept";
String DEFAULT_LANGUAGE = "en";
String TOKEN = "";

const String BASE_URL = "http://10.0.2.2:3000";

/// api 请求类
class Api {
  static final Api _instance = Api._internal();

  factory Api() => _instance;

  late Dio _dio;

  /// 单例初始
  Api._internal() {
    // header 头
    Map<String, String> headers = {
      CONTENT_TYPE: APPLICATION_JSON,
      ACCEPT: APPLICATION_JSON,
      DEFAULT_LANGUAGE: DEFAULT_LANGUAGE
    };

    // 初始选项
    var options = BaseOptions(
      baseUrl: BASE_URL,
      // 基地址
      headers: headers,
      //请求头
      connectTimeout: const Duration(seconds: 60),
      // 连接超时
      receiveTimeout: const Duration(seconds: 60),
      // 接受超时
      responseType: ResponseType.json, // 响应类型
    );

    // 初始 dio
    _dio = Dio(options);

    // 拦截器 - 日志打印
    if (!kReleaseMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, // 请求头
        requestBody: true, // 请求体
        responseHeader: false, // 响应头
        responseBody: true, // 响应体
      ));
    }

    // 拦截器
    _dio.interceptors.add(RequestInterceptors());
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = token;
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// get 请求
  Future<Response> get(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();
    Response response = await _dio.get(
      url,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// post 请求
  Future<Response> post(
    String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.post(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }
}

/// 拦截
class RequestInterceptors extends Interceptor {
  //

  /// 发送请求
  /// 我们这里可以添加一些公共参数，或者对参数进行加密
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 从 SharedPreferences 中读取 token
    // String? token = UserApi.getToken();

    // 在 header 中加入 Authorization
    // if (token != null && token.isNotEmpty) {
    //   options.headers['authorization'] = '$token';
    // }

    handler.next(options); // 继续请求
  }

  /// 响应
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查 HTTP 状态码是否正确
    if (response.statusCode == 200) {
      // 检查响应体中的业务状态
      handler.next(response);
    } else {
      // 如果状态码不是 200，按现有逻辑处理
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    }
  }

  // // 退出并重新登录

  /// 错误
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final exception = HttpException(err.message ?? "error message");
    switch (err.type) {
      case DioExceptionType.badResponse: // 服务端自定义错误体处理
        {
          final response = err.response;
          final errorMessage = ErrorMessageModel.fromJson(response?.data);
          switch (errorMessage.code) {
            // 401 未登录
            case "401":
              // 注销 并跳转到登录页面
              break;
            default:
              break;
          }
        }
        break;
      case DioExceptionType.unknown:
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionTimeout:
        break;
      default:
        break;
    }
    DioException errNext = err.copyWith(
      error: exception,
    );
    handler.next(errNext);
  }
}
