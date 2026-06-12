import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _cnicController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _handleRegister();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 2 ? 'Create Account' : 'Continue',
                      isLoading: _isLoading,
                      onPressed: details.onStepContinue,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        color: AppColors.border,
                        textColor: AppColors.textPrimary,
                        onPressed: details.onStepCancel,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1 — Personal Information
            Step(
              title: const Text('Personal Info'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'CNIC',
                    hint: '12345-1234567-1',
                    controller: _cnicController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'CNIC is required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Date of Birth',
                    hint: 'DD/MM/YYYY',
                    controller: _dobController,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: _selectDate,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Date of birth is required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Phone Number',
                    hint: '03XX-XXXXXXX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Phone number is required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Step 2 — Address Information
            Step(
              title: const Text('Address'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  CustomTextField(
                    label: 'City',
                    hint: 'Enter your city',
                    controller: _cityController,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Address',
                    hint: 'Enter your full address',
                    controller: _addressController,
                    prefixIcon: const Icon(Icons.home_outlined),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Address is required' : null,
                  ),
                ],
              ),
            ),

            // Step 3 — Account Setup
            Step(
              title: const Text('Account Setup'),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
              content: Column(
                children: [
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a strong password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}