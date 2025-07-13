import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/services/api_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String? userAvatar;
  final List<String> allergyOptions;
  final List<String> preferenceOptions;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    this.userAvatar,
    required this.allergyOptions,
    required this.preferenceOptions,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  // Timer variables
  late Duration _timerDuration;
  late Timer _timer;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize timer with 15 minutes (900 seconds)
    _timerDuration = const Duration(minutes: 5);
    _startTimer();
    // _initiateSignup();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _isTimerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerDuration.inSeconds == 0) {
        setState(() {
          _isTimerActive = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _timerDuration = Duration(seconds: _timerDuration.inSeconds - 1);
        });
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _timerDuration = const Duration(minutes: 5);
    });
    if (!_isTimerActive) {
      _startTimer();
    }
  }

  Future<void> _initiateSignup() async {
    try {
      await _apiService.initiateSignup(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        userAvatar: widget.userAvatar,
        allergyOptions: widget.allergyOptions,
        preferenceOptions: widget.preferenceOptions,
      );
    } on DioException catch (e) {
      if (mounted) {
        final errorMessage = e.response?.data['message'] ?? e.message;
        if (errorMessage.toString().contains('already been sent') ||
            errorMessage.toString().contains('already sent')) {
          // This is not actually an error for our flow, so we don't show it
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate signup: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate signup: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      setState(
          () => _errorMessage = 'Please enter a 6-digit verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final (user, token) = await _apiService.verifyEmailWithOtp(
        email: widget.email,
        otp: _otpController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(), // Or your main app page
        ),
        (Route<dynamic> route) => false,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final serverMessage = errorData is Map
          ? errorData['message']?.toString() ?? 'Verification failed'
          : 'Verification failed. Please try again.';

      // Friendly message for incorrect code
      final friendlyMessage = serverMessage.toLowerCase().contains('invalid') ||
              serverMessage.toLowerCase().contains('incorrect')
          ? 'The code you entered is incorrect. Please try again.'
          : serverMessage;

      setState(() => _errorMessage = friendlyMessage);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      await _apiService.resendVerificationCode(widget.email);
      // Reset the timer
      setState(() {
        _timerDuration = const Duration(minutes: 5);
        _isTimerActive = true;
      });
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New verification code sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFD5D69),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit verification code to:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),

            // Timer display
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Code expires in: ${_formatDuration(_timerDuration)}',
                style: TextStyle(
                  fontSize: 14,
                  color: _timerDuration.inMinutes < 1
                      ? Colors.red
                      : Color(0xFFFD5D69),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),
            // OTP Input Field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 24,
                  letterSpacing: 4,
                ),
                counterText: '',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFD5D69),
                    width: 2,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFD5D69),
                    width: 2,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFD5D69).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: const Color(0xFFFD5D69).withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: const Color(0xFFFD5D69),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5D69),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resendOtp,
                child: _isResending
                    ? const Text("Resending...")
                    : const Text("Didn't receive code? Resend"),
                style: TextButton.styleFrom(
                  foregroundColor:
                      _isResending ? Colors.grey : const Color(0xFFFD5D69),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
