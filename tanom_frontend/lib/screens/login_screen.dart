import 'package:flutter/material.dart';
import 'package:tanom_frontend/screens/home_screen.dart';
import 'package:tanom_frontend/screens/register_screen.dart';
import 'package:tanom_frontend/screens/verify_otp_screen.dart';
import 'package:tanom_frontend/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey =  GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState()  {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0, end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController, 
      curve: Curves.easeOut
    ));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.login(
        usernameController.text.trim(), 
        passwordController.text,
      );

      if(result['success'] == true) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, seconaryAnimation) => HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ), 
        );
      } else if (result['requiresOtp'] == true) {
        _showErrorMessage(result['error']);
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => VerifyOtpScreen(username: usernameController.text.trim())),
        );
      } else if(result['invalidCred'] == true){
        _showErrorMessage(result['error']);
      }
    } catch(e) {
       _showErrorMessage('Connection error. Please try again.');
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),

                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 0.5
                    ),
                  ),

                  SizedBox(height: 48),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Color(0xFF757575)),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4CAF50)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4CAF50)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E2E2E)
                          ),
                        ),

                        SizedBox(height: 32),

                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Color(0xFF757575)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility
                              )
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4CAF50)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4CAF50)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E2E2E)
                          ),
                        ),

                        SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ), 
                            child: _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5
                              ),
                            )
                          ),
                        ),

                        SizedBox(height: 32),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => RegisterScreen())
                            );
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 16,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        )
        )
    );
  }

}