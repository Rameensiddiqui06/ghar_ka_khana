

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../core/app_colors.dart';
// import '../core/role_home.dart';
// import '../models/role.dart';
// import '../services/auth_service.dart';
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
//   final AuthService _authService = AuthService();

//   Role _role = Role.customer;
//   bool _isSubmitting = false;
//   bool _isResettingPassword = false;

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _showError(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.redAccent,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   Future<void> _onSignIn() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       _showError('Please enter your email and password.');
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final fetchedRole = await _authService.login(
//         email: email,
//         password: password,
//       );

//       if (!mounted) return;

//       if (fetchedRole != _role) {
//         await _authService.signOut();

//         if (!mounted) return;

//         _showError(
//           'This account is registered as '
//           '${_roleLabel(fetchedRole)}. Please select the correct tab.',
//         );
//         return;
//       }

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => homeScreenForRole(fetchedRole)),
//         (route) => false,
//       );
//     } on FirebaseAuthException catch (e) {
//       debugPrint('Firebase login error: ${e.code}');
//       debugPrint('Firebase login message: ${e.message}');

//       switch (e.code) {
//         case 'invalid-credential':
//         case 'wrong-password':
//         case 'user-not-found':
//           _showError(
//             'Invalid email or password. Check your email and '
//             'new password, then try again.',
//           );
//           break;

//         case 'invalid-email':
//           _showError('Please enter a valid email address.');
//           break;

//         case 'user-disabled':
//           _showError('This account has been disabled.');
//           break;

//         case 'too-many-requests':
//           _showError('Too many attempts. Please wait and try again later.');
//           break;

//         case 'network-request-failed':
//           _showError('Check your internet connection and try again.');
//           break;

//         default:
//           _showError('Login failed (${e.code}). Please try again.');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('========== LOGIN ERROR ==========');
//       debugPrint('Error type: ${e.runtimeType}');
//       debugPrint('Error details: $e');
//       debugPrintStack(stackTrace: stackTrace);
//       debugPrint('=================================');

//       if (!mounted) return;

//       _showError('Login error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   Future<void> _onForgotPassword() async {
//     final email = _emailController.text.trim();

//     if (email.isEmpty) {
//       _showError('Enter your email address first.');
//       return;
//     }

//     setState(() => _isResettingPassword = true);

//     try {
//       await _authService.resetPassword(email: email);

//       if (!mounted) return;

//       _showSuccess(
//         'If an account exists for this email, a reset email '
//         'will arrive shortly. Check your inbox and spam folder.',
//       );
//     } on FirebaseAuthException catch (e) {
//       debugPrint('Password reset error: ${e.code}');
//       debugPrint('Password reset message: ${e.message}');

//       if (!mounted) return;

//       _showError('Could not send reset email (${e.code}). Please try again.');
//     } catch (e, stackTrace) {
//       debugPrint('Password reset error: $e');
//       debugPrintStack(stackTrace: stackTrace);

//       _showError('Something went wrong. Please try again.');
//     } finally {
//       if (mounted) {
//         setState(() => _isResettingPassword = false);
//       }
//     }
//   }

//   void _goToRegister() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
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
//                 style: TextStyle(color: AppColors.text2, fontSize: 14),
//               ),

//               const SizedBox(height: 24),

//               // Role selection tabs.
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
//                 label: 'Email',
//                 controller: _emailController,
//                 hint: 'you@example.com',
//                 keyboardType: TextInputType.emailAddress,
//               ),

//               const SizedBox(height: 16),

//               AppField(
//                 label: 'Password',
//                 controller: _passwordController,
//                 hint: 'Your new password',
//                 obscureText: true,
//               ),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: (_isSubmitting || _isResettingPassword)
//                       ? null
//                       : _onForgotPassword,
//                   child: Text(
//                     _isResettingPassword
//                         ? 'Sending reset email...'
//                         : 'Forgot password?',
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
//                 onPressed: (_isSubmitting || _isResettingPassword)
//                     ? null
//                     : _onSignIn,
//               ),

//               const SizedBox(height: 16),

//               Center(
//                 child: GestureDetector(
//                   onTap: _goToRegister,
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
  final AuthService _authService = AuthService();

  /// Roles shown on the login screen (admin is intentionally excluded).
  static final List<Role> _loginRoles =
      Role.values.where((r) => r != Role.admin).toList();

  Role _role = Role.customer;
  bool _isSubmitting = false;
  bool _isResettingPassword = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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

      // Admin accounts cannot sign in through the app.
      if (fetchedRole == Role.admin) {
        await _authService.signOut();

        if (!mounted) return;

        _showError('Invalid email or password.');
        return;
      }

      if (fetchedRole != _role) {
        await _authService.signOut();

        if (!mounted) return;

        _showError(
          'This account is registered as '
          '${_roleLabel(fetchedRole)}. Please select the correct tab.',
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeScreenForRole(fetchedRole)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.code}');
      debugPrint('Firebase login message: ${e.message}');

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          _showError(
            'Invalid email or password. Check your email and '
            'new password, then try again.',
          );
          break;

        case 'invalid-email':
          _showError('Please enter a valid email address.');
          break;

        case 'user-disabled':
          _showError('This account has been disabled.');
          break;

        case 'too-many-requests':
          _showError('Too many attempts. Please wait and try again later.');
          break;

        case 'network-request-failed':
          _showError('Check your internet connection and try again.');
          break;

        default:
          _showError('Login failed (${e.code}). Please try again.');
      }
    } catch (e, stackTrace) {
      debugPrint('========== LOGIN ERROR ==========');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error details: $e');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('=================================');

      if (!mounted) return;

      _showError('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Enter your email address first.');
      return;
    }

    setState(() => _isResettingPassword = true);

    try {
      await _authService.resetPassword(email: email);

      if (!mounted) return;

      _showSuccess(
        'If an account exists for this email, a reset email '
        'will arrive shortly. Check your inbox and spam folder.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code}');
      debugPrint('Password reset message: ${e.message}');

      if (!mounted) return;

      _showError('Could not send reset email (${e.code}). Please try again.');
    } catch (e, stackTrace) {
      debugPrint('Password reset error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
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
                style: TextStyle(color: AppColors.text2, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Role selection tabs (Customer / Seller).
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _loginRoles.map((r) {
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
                label: 'Email',
                controller: _emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              AppField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Your new password',
                obscureText: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (_isSubmitting || _isResettingPassword)
                      ? null
                      : _onForgotPassword,
                  child: Text(
                    _isResettingPassword
                        ? 'Sending reset email...'
                        : 'Forgot password?',
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
                onPressed: (_isSubmitting || _isResettingPassword)
                    ? null
                    : _onSignIn,
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: _goToRegister,
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