import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = 'http://127.0.0.1:8000/api';

class ApiService {
  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseurl/register/'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'username':username,
        'email':email,
        'password':password,
      })
    );

    return response.statusCode == 201;
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseurl/login/'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'username':username,
        'password':password
      })
    ); 

    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      return true;
    }
    return false;
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');   

    final response = await http.post(
      Uri.parse('$baseurl/logout/'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'refresh':refresh})
    );

    if(response.statusCode == 200) {
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      return true;
    }
    return false;   
  }
}