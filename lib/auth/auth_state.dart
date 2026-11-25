import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// An in-memory session. Passwords are never retained by this notifier.
class AuthState extends ChangeNotifier {
  AuthState(this._api);

  final ApiClient _api;
  String? _token;
  String? _username;
  bool _busy = false;
  bool _loggingIn = false;
  bool _disposed = false;
  int _generation = 0;
  ApiException? _failure;

  bool get isLoggedIn => _token != null;
  bool get isBusy => _busy;
  String? get token => _token;
  String? get username => _username;
  ApiException? get failure => _failure;

  Future<bool> login(String username, String password) async {
    if (_disposed || _busy) return false;
    final generation = ++_generation;
    _busy = true;
    _loggingIn = true;
    _failure = null;
    notifyListeners();
    try {
      final token = await _api.obtainToken(username.trim(), password);
      if (_disposed || generation != _generation) return false;
      _token = token;
      _username = username.trim();
      return true;
    } on ApiException catch (error) {
      if (!_disposed && generation == _generation) _failure = error;
      return false;
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _failure = const ApiException(
          ApiFailureKind.invalidResponse,
          operation: ApiOperation.login,
        );
      }
      return false;
    } finally {
      if (!_disposed && generation == _generation) {
        _busy = false;
        _loggingIn = false;
        notifyListeners();
      }
    }
  }

  /// Ignore an in-flight login if its route was cancelled.
  void cancelLogin() {
    if (_disposed || !_loggingIn) return;
    _generation++;
    _busy = false;
    _loggingIn = false;
    _failure = null;
    notifyListeners();
  }

  /// Drop only the session used by the rejected request, without calling logout.
  void invalidateSession(String rejectedToken) {
    if (_disposed || _token != rejectedToken) return;
    _token = null;
    _username = null;
    _failure = null;
    notifyListeners();
  }

  Future<void> logout() async {
    if (_disposed) return;
    final token = _token;
    final generation = ++_generation;
    _token = null;
    _loggingIn = false;
    _username = null;
    _failure = null;
    _busy = token != null;
    notifyListeners();
    if (token == null) return;
    try {
      await _api.logout(token);
    } on ApiException catch (error) {
      if (!_disposed && generation == _generation) _failure = error;
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _failure = const ApiException(
          ApiFailureKind.http,
          operation: ApiOperation.logout,
        );
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _token = null;
    _username = null;
    super.dispose();
  }
}
