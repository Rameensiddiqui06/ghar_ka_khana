import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'terms_screen.dart';
import '../core/app_colors.dart';
import '../core/role_home.dart';
import '../models/role.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_field.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Role role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Address is only asked from customers (needed for delivery).
  bool get _isCustomer => widget.role.name == 'customer';
  late final _termsTap = TapGestureRecognizer()
    ..onTap = () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _onCreateAccount() async {
    // Admin accounts can never be created from the app.
    if (widget.role == Role.admin) {
      _showError('Please choose Customer or Seller to register.');
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }
    if (_isCustomer && address.isEmpty) {
      _showError('Please enter your delivery address.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    if (!_agreedToTerms) {
      _showError('Please agree to the Terms & Conditions to continue.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final role = await _authService.register(
        email: email,
        password: password,
        role: widget.role,
        name: name,
        phone: phone,
        address: _isCustomer ? address : null,
      );
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'termsAcceptedAt': FieldValue.serverTimestamp(),
            'termsVersion': kTermsVersion,
          }, SetOptions(merge: true));
        } catch (_) {} // don't block sign-up if this write fails
      }
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeScreenForRole(role)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('This email is already registered. Please sign in.');
      } else {
        _showError(e.message ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                'Create Account',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 24),

              AppField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'Ayesha Khan',
              ),
              const SizedBox(height: 16),

              AppField(
                label: 'Email',
                controller: _emailController,
                hint: 'ayesha@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              AppField(
                label: 'Phone',
                controller: _phoneController,
                hint: '+92 300 0000000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              if (_isCustomer) ...[
                AppField(
                  label: 'Delivery Address',
                  controller: _addressController,
                  hint: 'House no., street, area, city',
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 16),
              ],

              AppField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Min. 8 characters',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              AppField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hint: 'Repeat password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: AppColors.text2,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(color: AppColors.primary),
                              recognizer: _termsTap,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: _isSubmitting ? 'Creating account…' : 'Create Account',
                onPressed: _isSubmitting ? null : _onCreateAccount,
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.text2, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
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
}

