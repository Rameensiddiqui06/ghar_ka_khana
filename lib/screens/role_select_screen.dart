

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/role.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  Role? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // TITLE
              // ==========================================
              const Text(
                'How will you use\nGhar Ka Khana?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Choose your role to get started.',
                style: TextStyle(
                  color: AppColors.text2,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // CUSTOMER
              // ==========================================
              _RoleCard(
                role: Role.customer,
                emoji: '🍽️',
                title: 'I want to order food',
                subtitle: 'Discover delicious homemade food from local cooks.',
                selected: _selectedRole == Role.customer,
                onTap: () {
                  setState(() {
                    _selectedRole = Role.customer;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ==========================================
              // SELLER
              // ==========================================
              _RoleCard(
                role: Role.seller,
                emoji: '👩‍🍳',
                title: 'I want to sell food',
                subtitle:
                    'Share your homemade food and earn from your kitchen.',
                selected: _selectedRole == Role.seller,
                onTap: () {
                  setState(() {
                    _selectedRole = Role.seller;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ==========================================
              // ADMIN
              // ==========================================
              _RoleCard(
                role: Role.admin,
                emoji: '🛡️',
                title: 'I am an administrator',
                subtitle: 'Manage sellers, customers, products and orders.',
                selected: _selectedRole == Role.admin,
                onTap: () {
                  setState(() {
                    _selectedRole = Role.admin;
                  });
                },
              ),

              const SizedBox(height: 32),

              // ==========================================
              // CONTINUE
              // ==========================================
              PrimaryButton(
                text: 'Continue',
                disabled: _selectedRole == null,
                onPressed: _selectedRole == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterScreen(role: _selectedRole!),
                          ),
                        );
                      },
              ),

              const SizedBox(height: 16),

              // ==========================================
              // EXISTING ACCOUNT
              // ==========================================
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.text2, fontSize: 14),
                      children: [
                        TextSpan(text: 'Already have an account? '),
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

// ======================================================
// ROLE CARD
// ======================================================

class _RoleCard extends StatelessWidget {
  final Role role;
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.cream : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.sand,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // ==========================================
            // ICON
            // ==========================================
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.sand,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),

            const SizedBox(width: 14),

            // ==========================================
            // TEXT
            // ==========================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.text2,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ==========================================
            // RADIO BUTTON
            // ==========================================
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.muted,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
