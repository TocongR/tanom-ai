import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanom_frontend/screens/dashboard_screen.dart';
import 'package:tanom_frontend/screens/login_screen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if(token != null) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => DashboardScreen())
      );
    } else {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => LoginScreen())
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}