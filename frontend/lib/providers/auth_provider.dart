import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userRole;
  String? _workerProfileId;
  String? _userId;

  bool get isAuthenticated => _token != null;
  String? get userName => _userName;
  String? get userRole => _userRole;
  String? get workerProfileId => _workerProfileId;
  String? get userId => _userId;

  AuthProvider() { _loadToken(); }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userName = prefs.getString('userName');
    _userRole = prefs.getString('userRole');
    _workerProfileId = prefs.getString('workerProfileId');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('http://localhost:3000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['token'];
      _userName = data['user']['name'];
      _userRole = data['user']['role'];
      _workerProfileId = data['user']['workerProfileId'];
      _userId = data['user']['id']; // Might be null if backend didn't send it

      final prefs = await SharedPreferences.getInstance();
      
      // Only save if not null
      if (_token != null) await prefs.setString('token', _token!);
      if (_userName != null) await prefs.setString('userName', _userName!);
      if (_userRole != null) await prefs.setString('userRole', _userRole!);
      if (_workerProfileId != null) await prefs.setString('workerProfileId', _workerProfileId!);
      if (_userId != null) await prefs.setString('userId', _userId!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password, String role) async {
    final res = await http.post(
      Uri.parse('http://localhost:3000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return res.statusCode == 201;
  }

  Future<void> loginWithGoogle() async {
    _token = "fake_google_token_123";
    _userName = "Google User";
    _userRole = "client"; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userName', _userName!);
    await prefs.setString('userRole', _userRole!);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userName = null;
    _userRole = null;
    _workerProfileId = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}