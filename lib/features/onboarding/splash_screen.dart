import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../data/settings_store.dart';
import '../../theme/app_colors.dart';

/// Splash screen, design 5 "Two-tone wave":
/// teal gradient with the logo + name on top, a light wave panel at the
/// bottom with the bilingual brand line and 4 OMR bubbles as the loader.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Shortest time the splash stays up (one full bubble cycle).
  /// Settings and auth are already loaded in main(), so nothing else waits.
  static const _minDuration = Duration(milliseconds: 1300);

  static const _bubbleCount = 4;
  static const _bubbleStep = Duration(milliseconds: 180);

  static const _gradientTop = Color(0xFF1FC093);
  static const _gradientBottom = Color(0xFF0A6E52);
  static const _brandDeep = Color(0xFF0B5E47);
  static const _brandMuted = Color(0xFF3E5A51);
  static const _bubbleEmpty = Color(0xFFA9D3C3);

  /// Logo/name pop-in (0–300ms) and wave slide-up (150–450ms).
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// One cycle = an empty beat + 4 bubbles filling, then repeat.
  late final AnimationController _bubbles = AnimationController(
    vsync: this,
    duration: _bubbleStep * (_bubbleCount + 1),
  );

  bool _reduceMotion = false;
  bool _animationsStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FlutterNativeSplash.remove());
    _navigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationsStarted) return;
    _animationsStarted = true;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _intro.value = 1;
    } else {
      _intro.forward();
      _bubbles.repeat();
    }
  }

  Future<void> _navigate() async {
    await Future.delayed(_minDuration);
    if (!mounted) return;
    final settings = context.read<SettingsStore>();
    context.go(settings.onboardingDone ? AppRoutes.home : AppRoutes.language);
  }

  @override
  void dispose() {
    _intro.dispose();
    _bubbles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final panelHeight = constraints.maxHeight * 0.38;
            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_gradientTop, _gradientBottom],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: panelHeight,
                    child: SafeArea(
                      bottom: false,
                      child: Center(child: _buildBrand()),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: panelHeight,
                    child: _buildPanel(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    final fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.67, curve: Curves.easeOut),
    );
    final scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.67, curve: Curves.easeOutBack),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/splash_logo.png',
              width: 120,
              height: 120,
              semanticLabel: 'MasterJi logo',
            ),
            const SizedBox(height: 12),
            Text(
              'MasterJi',
              style: GoogleFonts.balooBhaina2(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    final curve = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.33, 1, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 40 * (1 - curve.value)),
          child: child,
        ),
      ),
      child: ClipPath(
        clipper: _WaveClipper(),
        child: ColoredBox(
          color: AppColors.background,
          child: SafeArea(
            top: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Brand line: always shown in both languages, by design.
                    Text(
                      'ଶିକ୍ଷକଙ୍କ ସାଥୀ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.balooBhaina2(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _brandDeep,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your OMR checking partner',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _brandMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBubbles(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbles() {
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _bubbles,
        builder: (context, _) {
          // pos runs 0 → 5: [0,1) empty beat, then one more bubble per step.
          final pos = _reduceMotion ? 2.0 : _bubbles.value * (_bubbleCount + 1);
          final filled = pos.floor().clamp(0, _bubbleCount);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _bubbleCount; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Bubble(
                    filled: i < filled,
                    scale: _popScale(i, pos, filled),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Small "pop" (0.8 → 1.0) on the bubble that was just filled.
  double _popScale(int index, double pos, int filled) {
    if (_reduceMotion || index != filled - 1) return 1;
    final t = (pos - filled).clamp(0.0, 1.0);
    return 0.8 + 0.2 * Curves.easeOutBack.transform(t);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.filled, required this.scale});

  final bool filled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: filled
                ? AppColors.accent
                : _SplashScreenState._bubbleEmpty,
            width: 3,
          ),
        ),
      ),
    );
  }
}

/// Convex wave: highest in the middle, 22% of the panel lower at the sides.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final dip = size.height * 0.22;
    return Path()
      ..moveTo(0, dip)
      ..quadraticBezierTo(size.width / 2, -dip, size.width, dip)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
