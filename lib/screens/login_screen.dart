// import 'package:flutter/material.dart';

// import '../core/app_colors.dart';
// import '../widgets/app_logo.dart';
// import '../widgets/app_field.dart';
// import '../widgets/primary_button.dart';
// import 'role_select_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   Role _role = Role.customer;
//   bool _isSubmitting = false;

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _onSignIn() {
//     // TODO (Step 7): replace with AuthService.login(
//     //   email: _emailController.text,
//     //   password: _passwordController.text,
//     // ), then fetch the user's stored role from Firestore and verify it
//     // matches `_role` before navigating to the right home screen.
//     setState(() => _isSubmitting = true);
//     debugPrint('Sign in tapped for role tab: $_role');
//   }

//   void _goToRegister(BuildContext context) {
//     // Registration needs a role, so send them to pick one first.
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const RoleSelectScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AppLogo(),

//               const SizedBox(height: 24),

//               Text(
//                 'Welcome back 👋',
//                 style: TextStyle(
//                   color: AppColors.text,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: -0.4,
//                 ),
//               ),

//               const SizedBox(height: 4),

//               Text(
//                 'Sign in to your account.',
//                 style: TextStyle(
//                   color: AppColors.text2,
//                   fontSize: 14,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Role picker tabs
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: AppColors.sand,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: Role.values.map((r) {
//                     final isSelected = r == _role;
//                     return Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _role = r),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? AppColors.primary
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             _roleLabel(r),
//                             style: TextStyle(
//                               color: isSelected
//                                   ? Colors.white
//                                   : AppColors.text2,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               AppField(
//                 label: 'Email or Phone',
//                 controller: _emailController,
//                 hint: 'ayesha@email.com',
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),

//               AppField(
//                 label: 'Password',
//                 controller: _passwordController,
//                 hint: 'Your password',
//                 obscureText: true,
//               ),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     // TODO: forgot-password flow
//                   },
//                   child: Text(
//                     'Forgot password?',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               PrimaryButton(
//                 text: _isSubmitting ? 'Signing in…' : 'Sign In',
//                 onPressed: _isSubmitting ? null : _onSignIn,
//               ),

//               const SizedBox(height: 16),

//               Center(
//                 child: GestureDetector(
//                   onTap: () => _goToRegister(context),
//                   child: RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: AppColors.text2, fontSize: 14),
//                       children: [
//                         const TextSpan(text: "Don't have an account? "),
//                         TextSpan(
//                           text: 'Create one',
//                           style: TextStyle(
//                             color: AppColors.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _roleLabel(Role r) {
//     switch (r) {
//       case Role.customer:
//         return 'Customer';
//       case Role.seller:
//         return 'Seller';
//       case Role.admin:
//         return 'Admin';
//     }
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/role_home.dart';
import '../models/role.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_field.dart';
import '../widgets/primary_button.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  Role _role = Role.customer;
  bool _isSubmitting = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final fetchedRole = await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (fetchedRole != _role) {
        // Correct credentials, wrong tab selected.
        await _authService.signOut();
        _showError(
          'This account is registered as ${_roleLabel(fetchedRole)}. '
          'Please select the correct tab.',
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeScreenForRole(fetchedRole)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign in failed. Please try again.');
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToRegister(BuildContext context) {
    // Registration needs a role, so send them to pick one first.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLogo(),

              const SizedBox(height: 24),

              Text(
                'Welcome back 👋',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Sign in to your account.',
                style: TextStyle(
                  color: AppColors.text2,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // Role picker tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: Role.values.map((r) {
                    final isSelected = r == _role;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _roleLabel(r),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.text2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              AppField(
                label: 'Email or Phone',
                controller: _emailController,
                hint: 'ayesha@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              AppField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Your password',
                obscureText: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: forgot-password flow
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              PrimaryButton(
                text: _isSubmitting ? 'Signing in…' : 'Sign In',
                onPressed: _isSubmitting ? null : _onSignIn,
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () => _goToRegister(context),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.text2, fontSize: 14),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Create one',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(Role r) {
    switch (r) {
      case Role.customer:
        return 'Customer';
      case Role.seller:
        return 'Seller';
      case Role.admin:
        return 'Admin';
    }
  }
}