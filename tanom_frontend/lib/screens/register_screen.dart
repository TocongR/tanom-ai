import 'package:flutter/material.dart';
import 'package:tanom_frontend/screens/login_screen.dart';
import 'package:tanom_frontend/screens/verify_otp_screen.dart';
import 'package:tanom_frontend/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey =  GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword  = true;
  bool _obscureConfirmPassword  = true;
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    if(!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      if(result['success']) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(
              username: usernameController.text.trim()
            )
          )
        );
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('Connection error. Please try again.');
    } finally {
      if(mounted) {
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

  String? _validateUsername(String? value) {
    if(value == null || value.trim().isEmpty) {
      return "Username is required";
    }
    if(value.trim().length < 3) {
      return "Username must be 3 characters minimum";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if(value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // This regex checks if a string is a valid email format:
    // ^              → Start of the string
    // [\w\-\.]+      → One or more word characters (a-z, A-Z, 0-9, _), hyphens (-), or dots (.)
    // @              → The '@' symbol separating local and domain parts
    // ([\w\-]+\.)+   → One or more groups of domain name parts ending in a dot (e.g., "example." or "co.")
    // [\w\-]{2,4}    → The top-level domain (e.g., com, net), 2 to 4 characters long
    // $              → End of the string
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(!emailRegex.hasMatch(value.trim())) {
      return 'Enter valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if(value == null || value.isEmpty) {
      return 'Password is required';
    }
    if(value.length < 6) {
      return 'Password must be 6 characters minimum';
    }
    return null;
  }

   String? _validateConfirmPassword(String? value) {
    if(value == null || value.isEmpty) {
      return 'Confirm password';
    }
    if(value != passwordController.text) {
      return 'Password don\'t match';
    }
    return null;
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
                    'Create Account',
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
                          validator: _validateUsername,
                        ),

                        SizedBox(height: 32),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
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
                          validator: _validateEmail,
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
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF757575),
                                size: 20,
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
                          validator: _validatePassword,
                        ),

                        SizedBox(height: 32),
                        
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Color(0xFF757575)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              }, 
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF757575),
                                size: 20,
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
                          validator: _validateConfirmPassword,
                        ),

                        SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : handleRegister,
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
                            :Text(
                              'Create Account',
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
                              MaterialPageRoute(builder: (_) => LoginScreen())
                            );
                          },
                          child: Text(
                            'Sign In',
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