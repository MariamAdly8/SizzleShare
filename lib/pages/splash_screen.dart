import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sizzle_share/main.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;
  late AudioPlayer _audioPlayer;
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _setupAnimations();

    // Start animation and navigate after it's complete
    _controller.forward().whenComplete(() => _checkAuthAndNavigate());
  }

  void _setupAnimations() {
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _expandAnimation = Tween<double>(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );

    // Add listener to play sound at specific animation points
    _controller.addListener(() {
      if (_controller.value >= 0.1 && !_soundPlayed) {
        _playSound();
        _soundPlayed = true;
      }
    });
  }

  Future<void> _playSound() async {
    try {
      // For web or local assets, you might need to use different sources
      // Example for local asset:
      // await _audioPlayer.play(AssetSource('sounds/splash_sound.mp3'));

      // Example for network sound:
      // await _audioPlayer.play(UrlSource('https://example.com/sound.mp3'));

      // Example for short sound effect (best for splash screens)
      await _audioPlayer.play(AssetSource('sounds/splash_sound.mp3'));

      // Adjust volume if needed
      await _audioPlayer.setVolume(0.7);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    await _audioPlayer.stop(); // Stop any playing sound before navigation
    final token = await _storage.read(key: 'jwt_token');

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return token != null ? const HomePage() : const LoginPage();
          // return token != null ? MainWrapper() : const LoginPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Fading background
              Positioned.fill(
                child: Container(
                  color:
                      const Color(0xFFFD5D69).withOpacity(_fadeAnimation.value),
                ),
              ),

              // Animated logo
              Center(
                child: Transform.scale(
                  scale: _controller.value <= 0.5
                      ? _pulseAnimation.value
                      : _expandAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Animated text
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 250),
                  child: Opacity(
                    opacity: _controller.value <= 0.5
                        ? 1.0
                        : _textFadeAnimation.value,
                    child: const Text(
                      'SizzleShare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
