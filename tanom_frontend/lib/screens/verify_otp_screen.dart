import 'package:flutter/material.dart';
import 'package:tanom_frontend/services/api_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String username;

  VerifyOtpScreen({required this.username});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> with TickerProviderStateMixin {
  final otpController = TextEditingController();
  final apiService = ApiService();
  bool _isLoading = false;
  bool _isResending = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController, 
      curve: Curves.easeOut
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      _showErrorMessage('Please enter the OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.verifyOtp(
        widget.username,
        otpController.text.trim()
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D32),
            margin: EdgeInsets.all(16),
          )
        );
        Navigator.pop(context);
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('Connection error. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await apiService.resendOtp(widget.username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] 
              ? result['message']
              : result['error'],
            ),
          backgroundColor: result['success'] ? const Color(0xFF2E7D32) : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        )
      );
    } catch (e) {
      _showErrorMessage('Connection error. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF2E7D32),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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

                  // Header section
                  Icon(
                    Icons.verified_user,
                    size: 64,
                    color: const Color(0xFF2E7D32),
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Verify Your Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 0.5
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'We\'ve sent a verification code to your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Username: ${widget.username}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 48),

                  // OTP Input
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E2E2E),
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: TextStyle(
                        color: const Color(0xFF757575),
                        letterSpacing: 8,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF4CAF50)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF4CAF50)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF2E7D32), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    maxLength: 6,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  ),

                  SizedBox(height: 48),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
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
                            'Verify Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5
                            ),
                          ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: TextStyle(
                          color: const Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isResending ? null : _resendOtp,
                        child: _isResending
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: const Color(0xFF2E7D32),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}