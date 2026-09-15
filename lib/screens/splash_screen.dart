// import 'package:flutter/material.dart';
// import '../core/app_colors.dart';
// import 'welcome_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _entrance;
//   late final Animation<double> _logoScale;
//   late final Animation<double> _logoFade;
//   late final Animation<double> _glowFade;
//   late final Animation<double> _textFade;
//   late final Animation<Offset> _textSlide;
//   late final Animation<double> _dividerWidth;
//   late final Animation<double> _hintFade;

//   late final AnimationController _pulse;
//   late final Animation<double> _pulseValue;

//   bool _isNavigating = false;

//   @override
//   void initState() {
//     super.initState();

//     _entrance = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     );

//     _glowFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
//       ),
//     );

//     _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.05, 0.55, curve: Curves.easeOutBack),
//       ),
//     );

//     _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
//       ),
//     );

//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
//       ),
//     );

//     _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
//       ),
//     );

//     _hintFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _entrance,
//         curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _entrance.forward();

//     // Gentle looping pulse for the "tap to continue" cue.
//     _pulse = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     )..repeat(reverse: true);

//     _pulseValue = Tween<double>(begin: 0.35, end: 0.85).animate(
//       CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _entrance.dispose();
//     _pulse.dispose();
//     super.dispose();
//   }

//   void _onDone() {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 450),
//         pageBuilder: (_, animation, __) => const WelcomeScreen(),
//         transitionsBuilder: (_, animation, __, child) {
//           return FadeTransition(
//             opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _onDone,
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color.lerp(AppColors.primary, Colors.black, 0.35)!,
//                 AppColors.primary,
//                 Color.lerp(AppColors.primary, Colors.black, 0.15)!,
//               ],
//               stops: const [0.0, 0.55, 1.0],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Decorative soft glow behind the logo
//               Positioned(
//                 top: size.height * 0.22,
//                 left: 0,
//                 right: 0,
//                 child: FadeTransition(
//                   opacity: _glowFade,
//                   child: Center(
//                     child: Container(
//                       width: 260,
//                       height: 260,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: RadialGradient(
//                           colors: [
//                             Colors.white.withValues(alpha: 0.16),
//                             Colors.white.withValues(alpha: 0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Faint decorative rings, top-right and bottom-left
//               Positioned(
//                 top: -60,
//                 right: -60,
//                 child: FadeTransition(
//                   opacity: _glowFade,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.06),
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -80,
//                 left: -80,
//                 child: FadeTransition(
//                   opacity: _glowFade,
//                   child: Container(
//                     width: 260,
//                     height: 260,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.05),
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Spacer(flex: 3),

//                       // Logo
//                       FadeTransition(
//                         opacity: _logoFade,
//                         child: ScaleTransition(
//                           scale: _logoScale,
//                           child: Container(
//                             width: 108,
//                             height: 108,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(28),
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.white.withValues(alpha: 0.22),
//                                   Colors.white.withValues(alpha: 0.08),
//                                 ],
//                               ),
//                               border: Border.all(
//                                 color: Colors.white.withValues(alpha: 0.30),
//                                 width: 1,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withValues(alpha: 0.20),
//                                   blurRadius: 30,
//                                   offset: const Offset(0, 16),
//                                 ),
//                               ],
//                             ),
//                             alignment: Alignment.center,
//                             child: const Text(
//                               '🏠',
//                               style: TextStyle(fontSize: 54, height: 1),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       // Title
//                       FadeTransition(
//                         opacity: _textFade,
//                         child: SlideTransition(
//                           position: _textSlide,
//                           child: const Text(
//                             'Ghar Ka Khana',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 38,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: -0.8,
//                               height: 1.1,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       // Decorative divider
//                       FadeTransition(
//                         opacity: _textFade,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: AnimatedBuilder(
//                             animation: _dividerWidth,
//                             builder: (context, child) {
//                               return Container(
//                                 height: 2,
//                                 width: 44 * _dividerWidth.value,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(2),
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.white.withValues(alpha: 0.0),
//                                       Colors.white.withValues(alpha: 0.65),
//                                       Colors.white.withValues(alpha: 0.0),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       // Subtitle
//                       FadeTransition(
//                         opacity: _textFade,
//                         child: SlideTransition(
//                           position: _textSlide,
//                           child: Text(
//                             'From Their Kitchen to Your Table',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white.withValues(alpha: 0.78),
//                               fontSize: 15,
//                               letterSpacing: 0.6,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const Spacer(flex: 4),

//                       // Tap to continue — pulsing
//                       FadeTransition(
//                         opacity: _hintFade,
//                         child: AnimatedBuilder(
//                           animation: _pulseValue,
//                           builder: (context, child) {
//                             return Opacity(
//                               opacity: _pulseValue.value,
//                               child: child,
//                             );
//                           },
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 18,
//                                   vertical: 10,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(24),
//                                   border: Border.all(
//                                     color: Colors.white.withValues(alpha: 0.35),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'TAP TO CONTINUE',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     letterSpacing: 2.0,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _glowFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _hintFade;

  late final AnimationController _pulse;
  late final Animation<double> _pulseValue;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _glowFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    _hintFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _entrance.forward();

    // Gentle looping pulse for the "tap to continue" cue.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseValue = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _onDone() {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const AuthGate(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onDone,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(AppColors.primary, Colors.black, 0.35)!,
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.black, 0.15)!,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative soft glow behind the logo
              Positioned(
                top: size.height * 0.22,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _glowFade,
                  child: Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Faint decorative rings, top-right and bottom-left
              Positioned(
                top: -60,
                right: -60,
                child: FadeTransition(
                  opacity: _glowFade,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: FadeTransition(
                  opacity: _glowFade,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Logo
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.08),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '🏠',
                              style: TextStyle(fontSize: 54, height: 1),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: const Text(
                            'Ghar Ka Khana',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Decorative divider
                      FadeTransition(
                        opacity: _textFade,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedBuilder(
                            animation: _dividerWidth,
                            builder: (context, child) {
                              return Container(
                                height: 2,
                                width: 44 * _dividerWidth.value,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.65),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Subtitle
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Text(
                            'From Their Kitchen to Your Table',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 15,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Tap to continue — pulsing
                      FadeTransition(
                        opacity: _hintFade,
                        child: AnimatedBuilder(
                          animation: _pulseValue,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _pulseValue.value,
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'TAP TO CONTINUE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}