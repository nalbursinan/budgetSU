import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

/// Auth states
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// AuthProvider - Auth state management with Provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _rememberMe = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get rememberMe => _rememberMe;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state
  Future<void> _init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _loadRememberMePreference();

    _authService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Load remember me preference
  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('remember_me') ?? false;
  }

  /// Set remember me preference
  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    notifyListeners();
  }

  /// Save last email
  Future<void> _saveLastEmail(String email) async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_email', email);
    }
  }

  /// Get last email
  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_email');
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      await _saveLastEmail(email);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      await _saveLastEmail(email);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _errorMessage = null;
    
    final result = await _authService.sendPasswordResetEmail(email: email);
    
    if (!result.isSuccess) {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
    
    return true;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
