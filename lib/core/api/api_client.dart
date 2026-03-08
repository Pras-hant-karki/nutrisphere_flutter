import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  static const _disableAutoRetryKey = '__disable_auto_retry';

  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        // Keep connect timeout tighter to avoid a long "spinning" login UX.
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor
    _dio.interceptors.add(_AuthInterceptor());

    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 1,
        retryDelays: const [
          Duration(seconds: 1),
        ],
        retryEvaluator: (error, attempt) {
          if (error.requestOptions.extra[_disableAutoRetryKey] == true) {
            return false;
          }

          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown;
        },
      ),
    );

    // Logger (debug only)
    if (kDebugMode) {
      debugPrint('ApiClient base URL: ${ApiEndpoints.baseUrl}');
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _postWithAndroidFailover(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> _postWithAndroidFailover(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Updating instance options here makes hot-reload sessions pick up new timeout.
    _dio.options.connectTimeout = ApiEndpoints.connectionTimeout;
    final mergedOptions = (options ?? Options()).copyWith(
      extra: {
        ...?(options?.extra),
        _disableAutoRetryKey: true,
      },
    );

    final primaryBaseUrl = _dio.options.baseUrl;
    final secondaryBaseUrl =
        ApiEndpoints.isAndroidNative ? _alternateBaseUrlFrom(primaryBaseUrl) : null;

    DioException? lastError;
    final candidateBaseUrls = [
      primaryBaseUrl,
      if (secondaryBaseUrl != null) secondaryBaseUrl,
    ];

    for (final baseUrl in candidateBaseUrls) {
      try {
        if (kDebugMode) {
          debugPrint('POST attempt: $baseUrl$path');
        }

        return await _dio.post(
          '$baseUrl$path',
          data: data,
          queryParameters: queryParameters,
          options: mergedOptions,
        );
      } on DioException catch (err) {
        lastError = err;
        if (!_isRetryableConnectionError(err)) {
          rethrow;
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      message: 'POST request failed unexpectedly',
      type: DioExceptionType.unknown,
    );
  }

  bool _isRetryableConnectionError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }

  String? _alternateBaseUrlFrom(String currentBaseUrl) {
    final uri = Uri.tryParse(currentBaseUrl);
    if (uri == null) return null;

    if (uri.host == '10.0.2.2') {
      return '${uri.scheme}://${ApiEndpoints.compIpAddress}:${uri.port}';
    }

    if (uri.host == ApiEndpoints.compIpAddress) {
      return '${uri.scheme}://10.0.2.2:${uri.port}';
    }

    return null;
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.patch(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return _dio.delete(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> uploadFile(String path,
      {required FormData formData, Options? options, String method = 'POST'}) async {
    _dio.options.connectTimeout = ApiEndpoints.connectionTimeout;
    final opts = options ?? Options();
    final mergedOptions = opts.copyWith(
      method: method,
      headers: {
        ...?opts.headers,
        // Keep explicit multipart content type while letting Dio set boundaries.
        'Content-Type': 'multipart/form-data',
      },
      extra: {
        ...?opts.extra,
        _disableAutoRetryKey: true,
      },
    );

    final primaryBaseUrl = _dio.options.baseUrl;
    final secondaryBaseUrl =
        ApiEndpoints.isAndroidNative ? _alternateBaseUrlFrom(primaryBaseUrl) : null;

    DioException? lastError;
    final candidateBaseUrls = [
      primaryBaseUrl,
      if (secondaryBaseUrl != null) secondaryBaseUrl,
    ];

    for (final baseUrl in candidateBaseUrls) {
      try {
        if (kDebugMode) {
          debugPrint('UPLOAD attempt: $baseUrl$path');
        }

        final requestPath = '$baseUrl$path';
        return await _dio.request(
          requestPath,
          data: formData,
          options: mergedOptions,
        );
      } on DioException catch (err) {
        lastError = err;
        if (!_isRetryableConnectionError(err)) {
          rethrow;
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      message: 'Upload request failed unexpectedly',
      type: DioExceptionType.unknown,
    );
  }

  // setAuthToken()
  Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    await _storage.write(key: _tokenKey, value: token);
  }

  // removeAuthToken()
  Future<void> removeAuthToken() async {
    _dio.options.headers.remove('Authorization');
    await _storage.delete(key: _tokenKey);
  }
}

// ================= AUTH INTERCEPTOR =================

class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public auth endpoints (NO TOKEN)
    final isAuthEndpoint =
        options.path == ApiEndpoints.login ||
      options.path == ApiEndpoints.register ||
      options.path == ApiEndpoints.requestPasswordReset ||
      options.path == ApiEndpoints.resetPassword;

    if (!isAuthEndpoint) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log detailed error information for debugging
    print('   DIO ERROR: ${err.type}');
    print('   Message: ${err.message}');
    print('   Status Code: ${err.response?.statusCode}');
    print('   URL: ${err.requestOptions.path}');
    print('   Response Data: ${err.response?.data}');
    print('   Error: ${err.error}');
    print('   StackTrace: ${err.stackTrace}');

    if (err.response?.statusCode == 401) {
      _storage.delete(key: _tokenKey);
    }
    handler.next(err);
  }
}

//
//
//
//
//
//
//
//
//










// import 'package:dio/dio.dart';
// import 'package:dio_smart_retry/dio_smart_retry.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// // Provider for ApiClient
// final apiClientProvider = Provider<ApiClient>((ref) {
//   return ApiClient();
// });

// class ApiClient {
//   late final Dio _dio;

//   ApiClient() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.baseUrl,
//         connectTimeout: ApiEndpoints.connectionTimeout,
//         receiveTimeout: ApiEndpoints.receiveTimeout,
//         headers: const {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     // Auth interceptor
//     _dio.interceptors.add(_AuthInterceptor());

//     // Retry interceptor
//     _dio.interceptors.add(
//       RetryInterceptor(
//         dio: _dio,
//         retries: 3,
//         retryDelays: const [
//           Duration(seconds: 1),
//           Duration(seconds: 2),
//           Duration(seconds: 3),
//         ],
//         retryEvaluator: (error, attempt) {
//           return error.type == DioExceptionType.connectionTimeout ||
//               error.type == DioExceptionType.sendTimeout ||
//               error.type == DioExceptionType.receiveTimeout ||
//               error.type == DioExceptionType.connectionError ||
//               error.type == DioExceptionType.unknown;
//         },
//       ),
//     );

//     // Logger (debug only)
//     if (kDebugMode) {
//       _dio.interceptors.add(
//         PrettyDioLogger(
//           requestHeader: true,
//           requestBody: true,
//           responseBody: true,
//           responseHeader: false,
//           error: true,
//           compact: true,
//         ),
//       );
//     }
//   }

//   Dio get dio => _dio;

//   Future<Response> get(String path,
//       {Map<String, dynamic>? queryParameters, Options? options}) {
//     return _dio.get(path,
//         queryParameters: queryParameters, options: options);
//   }

//   Future<Response> post(String path,
//       {dynamic data,
//       Map<String, dynamic>? queryParameters,
//       Options? options}) {
//     return _dio.post(path,
//         data: data, queryParameters: queryParameters, options: options);
//   }

//   Future<Response> put(String path,
//       {dynamic data,
//       Map<String, dynamic>? queryParameters,
//       Options? options}) {
//     return _dio.put(path,
//         data: data, queryParameters: queryParameters, options: options);
//   }

//   Future<Response> delete(String path,
//       {dynamic data,
//       Map<String, dynamic>? queryParameters,
//       Options? options}) {
//     return _dio.delete(path,
//         data: data, queryParameters: queryParameters, options: options);
//   }

//   Future<Response> uploadFile(String path, {required FormData formData, Options? options}) async {
//     final opts = options ?? Options();
//     // Ensure multipart content-type is set (Dio will set proper boundary)
//     opts.headers = {
//       ...?opts.headers,
//       'Content-Type': 'multipart/form-data',
//     };

//     return _dio.post(path, data: formData, options: opts);
//   }
// }

// // ================= AUTH INTERCEPTOR =================

// class _AuthInterceptor extends Interceptor {
//   final _storage = const FlutterSecureStorage();
//   static const _tokenKey = 'auth_token';

//   @override
//   Future<void> onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     // Public auth endpoints (NO TOKEN)
//     final isAuthEndpoint =
//         options.path == ApiEndpoints.login ||
//         options.path == ApiEndpoints.register;

//     if (!isAuthEndpoint) {
//       final token = await _storage.read(key: _tokenKey);
//       if (token != null) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }
//     }

//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     // Log detailed error information for debugging
//     print('   DIO ERROR: ${err.type}');
//     print('   Message: ${err.message}');
//     print('   Status Code: ${err.response?.statusCode}');
//     print('   URL: ${err.requestOptions.path}');
//     print('   Response Data: ${err.response?.data}');
//     print('   Error: ${err.error}');
//     print('   StackTrace: ${err.stackTrace}');
    
//     if (err.response?.statusCode == 401) {
//       _storage.delete(key: _tokenKey);
//     }
//     handler.next(err);
//   }
// }
