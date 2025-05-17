import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qio/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:qio/main.dart';
//import 'package:web_socket_channel/io.dart';
import 'dart:async';
//import 'package:web_socket_channel/status.dart' as status;
//import 'dart:io';

//const String domain = "http://10.0.2.2:8000/";
const String domain =
    kDebugMode
        ? "http://10.0.2.2:8000/"
        : "https://alijohn5.pythonanywhere.com/";

const String wsdomain =
    kDebugMode
        ? "ws://10.0.2.2:8000/ws/notifications/"
        : "wss://alijohn5.pythonanywhere.com/ws/notifications/";

class TokenManager {
  static final _storage = FlutterSecureStorage();
  
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  static Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<void> deleteEmail() async {
    await _storage.delete(key: 'email');
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: domain));

  static Dio get instance => _dio;

  static Future<void> initialize() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await TokenManager.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // If token expired
          if (error.response?.statusCode == 401) {
            // Try to refresh
            final success = await _refreshToken();
            if (success) {
              // Retry the failed request
              final accessToken = await TokenManager.getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $accessToken';
              final clonedRequest = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(clonedRequest);
            } else {
              // If refresh fails, logout user or redirect to login

              await TokenManager.clearTokens();

              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => Login()),
                (route) => false,
              );

              return handler.reject(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

  }

  static Future<bool> _refreshToken() async {
    // print("ddd");
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      //print(refreshToken);
      if (refreshToken == null) return false;

      final tempDio = Dio(); // separate Dio instance without interceptors
      final response = await tempDio.post(
        '${_dio.options.baseUrl}api/users/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data['access'] != null) {
        await TokenManager.saveTokens(response.data['access'], refreshToken);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        await TokenManager.deleteTokens();
        print("Refresh token failed: $e");
      }
    }
    return false;
  }
}

class AuthService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: domain,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) {
        return true; // Accept all status codes
      },
    ),
  );

  // Register
  static Future<Response> register({
    required String email,
    required String password,
    required String userType,
  }) async {
    await TokenManager.saveEmail(email);
    return await _dio.post(
      'api/users/register/',
      data: {'email': email, 'password': password, 'user_type': userType},
    );
  }

  // Verify Code
  static Future<Response> verifyCode({
    required String email,
    required String code,
  }) async {
    return await _dio.post(
      'api/users/verify/',
      data: {'email': email, 'code': code},
    );
  }

  // Login
  static Future<Response> login({
    required String email,
    required String password,
  }) async {
    await TokenManager.saveEmail(email);
    final response = await _dio.post(
      'api/users/login/',
      data: {'email': email, 'password': password},
    );

    // Save tokens
    final access = response.data['access_token'];
    final refresh = response.data['refresh_token'];
    if (access != null && refresh != null) {
      await TokenManager.saveTokens(access, refresh);
    }

    return response;
  }

  // Reset Password (Request reset)
  static Future<Response> resetPasswordRequest({required String email}) async {
    return await _dio.post('api/users/reset-password/', data: {'email': email});
  }

  // Reset Password (Confirm reset with code)
  static Future<Response> resetPasswordConfirm({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return await _dio.post(
      'api/users/reset-password/confirm/',
      data: {'email': email, 'code': code, 'new_password': newPassword},
    );
  }
}

Future<bool> isLoggedIn() async {
  final accessToken = await TokenManager.getAccessToken();
  if (accessToken == null) return false;
  return true;
}





/*
class WebSocketManager {
  final String url = wsdomain;
  IOWebSocketChannel? _channel;
  int isRefresh = 0;

  final StreamController<dynamic> _streamController =
      StreamController.broadcast();
  Timer? _reconnectTimer;

  WebSocketManager() {
    _connect();
  }

  void _connect() async {
    final token = await TokenManager.getAccessToken();
    if (token == null) {
      await TokenManager.clearTokens();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Login()),
        (route) => false,
      );
      return;
    }

    final headers = {'authorization': 'Token $token'};

    try {
      final socket = await WebSocket.connect(
        url,
        headers: headers.map((key, value) => MapEntry(key, value.toString())),
      );
      _channel = IOWebSocketChannel(socket);

      _channel!.stream.listen(
        (data) => _streamController.add(data),

        onError: (error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
          _scheduleReconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print('WebSocket closed');
          }
          _scheduleReconnect();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Connection failed: $e');
      }
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() async {
    isRefresh++;

    if (isRefresh % 3 == 0) {
      await DioClient._refreshToken();
      isRefresh = 0;
    }

    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer(Duration(seconds: 5), () {
        if (kDebugMode) {
          print('Reconnecting...');
        }
        _connect();
      });
    }
  }

  Stream<dynamic> get stream => _streamController.stream;

  void send(String message) {
    _channel?.sink.add(message);
  }

  void dispose() {
    _channel?.sink.close(status.goingAway);
    _streamController.close();
    _reconnectTimer?.cancel();
  }
}
*/