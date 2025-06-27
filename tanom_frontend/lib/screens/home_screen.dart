import 'package:flutter/material.dart';
import 'package:tanom_frontend/screens/login_screen.dart';
import 'package:tanom_frontend/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final apiService = ApiService();
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: SizedBox(
        child: ElevatedButton(
          onPressed: () async {
            final result = await apiService.logout();

            if(result['success']) {
              Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => LoginScreen())
            );
            }           
          }, 
          child: Text('Logout')
          )
        ),
      )
    );
  }
}