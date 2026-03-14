import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  bool _isAuthenticated = false;

  AuthProvider(this._storageService);

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    // Mock login logic for offline app
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    // Mock register logic
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}
