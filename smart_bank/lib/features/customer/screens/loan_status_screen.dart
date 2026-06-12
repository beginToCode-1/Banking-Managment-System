import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class LoanStatusScreen extends StatelessWidget {
  const LoanStatusScreen({super.key});

  // Mock data — replace with API later
  final List<Map<String, dynamic>> _loans = const [
    {
      'loanId': 'LN-2026-001',
      'type': 'Personal Loan',
      'amount': 200000.0,
      'status': 'Approved',
      'dateApplied': 'Jun 01, 2026',
      'dateProcessed': 'Jun 03, 2026',
      'purpose': 'Home Renovation',
      'monthlyIncome': 80000.0,
      'employment': 'Employed',
    },
    {
      'loanId': 'LN-2026-002',
      'type': 'Business Loan',
      'amount': 500000.0,
      'status': 'Pending',
      'dateApplied': 'Jun 09, 2026',
      'dateProcessed': '-',
      'purpose': 'Business Expansion',
      'monthlyIncome': 80000.0,
      'employment': 'Business Owner',
    },
    {
      'loanId': 'LN-2025-008',
      'type': 'Personal Loan',
      'amount': 100000.0,
      'status': 'Rejected',
      'dateApplied': 'Dec 10, 2025',
      'dateProcessed': 'Dec 12, 2025',
      'purpose': 'Car Purchase',
      'monthlyIncome': 80000.0,
      'employment': 'Employed',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.success;
      case 'Pending':
        return AppColors.pending;
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Pending':
        return Icons.hourglass_top_rounded;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final approved = _loans.where((l) => l['status'] == 'Approved').length;
    final pending = _loans.where((l) => l['status'] == 'Pending').length;
    final rejected = _loans.where((l) => l['status'] == 'Rejected').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Loans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.loanApplication),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.go(AppRoutes.loanApplication),
            tooltip: 'Apply for loan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                _summaryCard('Approved', approved.toString(), AppColors.success,
                    Icons.check_circle_outline),
                const SizedBox(width: 12),
                _summaryCard('Pending', pending.toString(), AppColors.pending,
                    Icons.hourglass_top_rounded),
                const SizedBox(width: 12),
                _summaryCard('Rejected', rejected.toString(), AppColors.error,
                    Icons.cancel_outlined),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Loan Applications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Loan Cards
            ..._loans.map((loan) => _loanCard(context, loan)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.loanApplication),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Apply for Loan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _summaryCard(
      String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanCard(BuildContext context, Map<String, dynamic> loan) {
    final status = loan['status'] as String;
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan['type'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan['loanId'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(status),
                          color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(
                  'Loan Amount',
                  'Rs. ${loan['amount'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  Icons.attach_money,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Date Applied',
                  loan['dateApplied'] as String,
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Date Processed',
                  loan['dateProcessed'] as String,
                  Icons.update_outlined,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Purpose',
                  loan['purpose'] as String,
                  Icons.description_outlined,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Employment',
                  loan['employment'] as String,
                  Icons.work_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}