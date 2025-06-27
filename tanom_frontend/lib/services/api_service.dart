import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = 'http://127.0.0.1:8000/api';

class ApiService {
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseurl/register/'),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({
          'username':username,
          'email':email,
          'password':password,
        })
      );

      if(response.statusCode == 201) {
        return { 'success':true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false, 
          'error': data['error']
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'error': 'Connection error'
      };
    }
   
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
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
        return {'success': true};
      } else {
        final error = json.decode(response.body);
        if (error['requires_otp'] != null && error['requires_otp'].contains('True')) {       
          return {
            'success': false, 
            'error': 'Account not verified. Please enter your OTP', 
            'requiresOtp': true
          };
        }
        return {
          'success': false, 
          'error': 'Invalid credentials', 
          'invalidCred': true
        };      
      }
    } catch (e) {
       return {
        'success': false, 
        'error': 'Connection error'
      };
    }   
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString('refresh_token');   

      final response = await http.post(
        Uri.parse('$baseurl/logout/'),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({'refresh': refresh})
      );

      if(response.statusCode == 200) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        return {'success': true};
      }
      return {
        'success': false,
        'error': 'Failed to logout. Please try again.'
      };   
    } catch (e) {
       return {
        'success': false, 
        'error': 'Connection error'
      };
    }
   
  }

  Future<Map<String, dynamic>> verifyOtp(String username, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseurl/verify_otp/'),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({
          'username': username,
          'otp': otp
        })
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': data['message']
        };
      }
      return {
        'success': false, 
        'error':  data['error']
      };

    } catch (e) {
      return {
        'success': false, 
        'error': 'Connection error'
      };
    }
   
  }

  Future<Map<String, dynamic>> resendOtp(String username) async {   
    try {
      final response = await http.post(
        Uri.parse('$baseurl/resend_otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username})
      );

      final data = json.decode(response.body);

      if(response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message']
        };
      }
      return {
        'success': false,
        'error': data['error']
      };

    } catch (e) {
      return {
        'success': false, 
        'error': 'Connection error'
      };
    }    
  }
}