import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/outline_button.dart';
import 'role_select_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Similar to the original React 45vh hero,
    // but slightly reduced so both buttons remain visible.
    final heroHeight = (screenHeight * 0.38).clamp(230.0, 300.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // =====================================================
                  // HERO IMAGE
                  // =====================================================

                  SizedBox(
                    height: heroHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Themed placeholder shown underneath at all times,
                        // so there's never a blank/empty flash while loading.
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.lerp(AppColors.primary, Colors.black, 0.1)!,
                                AppColors.primary,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.dinner_dining_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),

                        Image.asset(
                          'assests/welcomescreen.jpg',
                          fit: BoxFit.cover,

                          // Smooth fade-in once the first frame is decoded,
                          // instead of an abrupt pop-in over the placeholder.
                          frameBuilder: (
                            BuildContext context,
                            Widget child,
                            int? frame,
                            bool wasSynchronouslyLoaded,
                          ) {
                            if (wasSynchronouslyLoaded) return child;
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },

                          // Keep placeholder visible if the image fails.
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return const SizedBox.shrink();
                          },
                        ),

                        // =================================================
                        // BOTTOM GRADIENT
                        // =================================================

                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background,
                                ],
                                stops: const [
                                  0.45,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =====================================================
                  // CONTENT
                  // =====================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      4,
                      24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =============================================
                        // HEADING
                        // =============================================

                        const Text(
                          'Homemade food,\n'
                          'made with love.',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // =============================================
                        // DESCRIPTION
                        // =============================================

                        const Text(
                          'Discover delicious food from home cooks around you. '
                          'Support local women entrepreneurs and eat fresh every day.',
                          style: TextStyle(
                            color: AppColors.text2,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =============================================
                        // GET STARTED
                        // =============================================

                        PrimaryButton(
                          text: 'Get Started',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RoleSelectScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // =============================================
                        // ALREADY HAVE ACCOUNT
                        // =============================================

                        OutlineButton(
                          text: 'I Already Have an Account',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}