import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _purposeController = TextEditingController();
  String _employmentStatus = 'Employed';
  bool _isLoading = false;

  final List<String> _employmentOptions = [
    'Employed',
    'Self-Employed',
    'Business Owner',
    'Freelancer',
    'Unemployed',
  ];

  final List<Map<String, dynamic>> _loanPackages = [
    {
      'title': 'Personal Loan',
      'amount': 'Up to Rs. 5,00,000',
      'rate': '12% per annum',
      'duration': 'Up to 3 years',
      'icon': Icons.person_outline,
      'color': AppColors.primary,
    },
    {
      'title': 'Business Loan',
      'amount': 'Up to Rs. 50,00,000',
      'rate': '10% per annum',
      'duration': 'Up to 7 years',
      'icon': Icons.business_outlined,
      'color': AppColors.accent,
    },
    {
      'title': 'Home Loan',
      'amount': 'Up to Rs. 2,00,00,000',
      'rate': '8% per annum',
      'duration': 'Up to 20 years',
      'icon': Icons.home_outlined,
      'color': AppColors.success,
    },
  ];

  @override
  void dispose() {
    _loanAmountController.dispose();
    _monthlyIncomeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.pending.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.pending, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Application Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your loan application is under review. You will be notified once it is processed.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'View Loan Status',
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.loanStatus);
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Back to Dashboard',
              color: AppColors.border,
              textColor: AppColors.textPrimary,
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.customerDashboard);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.customerDashboard),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.loanStatus),
            child: const Text(
              'My Loans',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Packages
            const Text(
              'Loan Packages',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _loanPackages.length,
                itemBuilder: (context, index) {
                  final pkg = _loanPackages[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (pkg['color'] as Color).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: (pkg['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(pkg['icon'] as IconData,
                            color: pkg['color'] as Color, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          pkg['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: pkg['color'] as Color,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pkg['amount'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          pkg['rate'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          pkg['duration'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Application Form
            const Text(
              'Application Form',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Loan Amount
                  CustomTextField(
                    label: 'Loan Amount (Rs.)',
                    hint: 'Enter desired loan amount',
                    controller: _loanAmountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Loan amount is required';
                      final amount = double.tryParse(v) ?? 0;
                      if (amount <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Monthly Income
                  CustomTextField(
                    label: 'Monthly Income (Rs.)',
                    hint: 'Enter your monthly income',
                    controller: _monthlyIncomeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Monthly income is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Employment Status
                  DropdownButtonFormField<String>(
                    initialValue: _employmentStatus,
                    decoration: InputDecoration(
                      labelText: 'Employment Status',
                      prefixIcon: const Icon(Icons.work_outline,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: _employmentOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _employmentStatus = v!),
                  ),
                  const SizedBox(height: 16),

                  // Purpose
                  CustomTextField(
                    label: 'Loan Purpose',
                    hint: 'Describe the purpose of the loan',
                    controller: _purposeController,
                    prefixIcon: const Icon(Icons.description_outlined),
                    maxLines: 3,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Loan purpose is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Submit Application',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
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