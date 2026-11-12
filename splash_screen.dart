import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0));
            return Transform.scale(
              scale: 0.6 + t * 0.4,
              child: Opacity(opacity: _c.value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.yellow, AppColors.coral],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppShadows.tinted(AppColors.coral),
                ),
                child: const Text('🌷', style: TextStyle(fontSize: 46)),
              ),
              const SizedBox(height: 22),
              const Text(
                'FanHub',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ARCHIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coral,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
