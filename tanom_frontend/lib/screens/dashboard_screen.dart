import 'package:flutter/material.dart';
import 'package:tanom_frontend/screens/login_screen.dart';
import 'package:tanom_frontend/services/api_service.dart';

class DashboardScreen extends StatelessWidget {
  final apiService = ApiService();
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
        child: ElevatedButton(
          onPressed: () async {
            final success = await apiService.logout();

            if(success) {
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