import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data — replace with API later
  final List<Map<String, dynamic>> _customers = [
    {
      'name': 'Ahmed Khan',
      'email': 'ahmed@email.com',
      'account': '1234-5678-9012',
      'status': 'Active',
      'balance': 125000.0,
    },
    {
      'name': 'Sara Ali',
      'email': 'sara@email.com',
      'account': '9876-5432-1098',
      'status': 'Active',
      'balance': 75000.0,
    },
    {
      'name': 'Bilal Hassan',
      'email': 'bilal@email.com',
      'account': '1122-3344-5566',
      'status': 'Frozen',
      'balance': 30000.0,
    },
  ];

  final List<Map<String, dynamic>> _pendingLoans = [
    {
      'loanId': 'LN-2026-002',
      'customerName': 'Sara Ali',
      'amount': 500000.0,
      'type': 'Business Loan',
      'dateApplied': 'Jun 09, 2026',
      'income': 120000.0,
      'employment': 'Business Owner',
      'purpose': 'Business Expansion',
    },
    {
      'loanId': 'LN-2026-003',
      'customerName': 'Bilal Hassan',
      'amount': 150000.0,
      'type': 'Personal Loan',
      'dateApplied': 'Jun 10, 2026',
      'income': 60000.0,
      'employment': 'Employed',
      'purpose': 'Medical Expenses',
    },
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'from': 'Ahmed Khan',
      'to': 'Sara Ali',
      'amount': 5000.0,
      'type': 'Transfer',
      'date': 'Jun 10, 2026',
      'flag': false,
    },
    {
      'from': 'System',
      'to': 'Ahmed Khan',
      'amount': 20000.0,
      'type': 'Deposit',
      'date': 'Jun 09, 2026',
      'flag': false,
    },
    {
      'from': 'Bilal Hassan',
      'to': 'Unknown',
      'amount': 95000.0,
      'type': 'Transfer',
      'date': 'Jun 08, 2026',
      'flag': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLoanActionDialog(Map<String, dynamic> loan, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action Loan'),
        content: Text(
          'Are you sure you want to $action the loan application ${loan['loanId']} for ${loan['customerName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loan ${action}d successfully!'),
                  backgroundColor: action == 'Approve'
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Approve'
                  ? AppColors.success
                  : AppColors.error,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Customers'),
            Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Loans'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCustomersTab(),
          _buildLoansTab(),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  // Customers Tab
  Widget _buildCustomersTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _customers.length,
            itemBuilder: (context, index) {
              final customer = _customers[index];
              final isActive = customer['status'] == 'Active';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        (customer['name'] as String)[0],
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            customer['email'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Rs. ${(customer['balance'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        customer['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Loans Tab
  Widget _buildLoansTab() {
    return _pendingLoans.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: AppColors.success),
                SizedBox(height: 12),
                Text('No pending loan applications',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pendingLoans.length,
            itemBuilder: (context, index) {
              final loan = _pendingLoans[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loan['customerName'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.pending.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(
                              color: AppColors.pending,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(loan['loanId'] as String,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _loanDetail('Type', loan['type'] as String),
                        _loanDetail(
                            'Amount',
                            'Rs. ${(loan['amount'] as double).toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _loanDetail('Income',
                            'Rs. ${(loan['income'] as double).toStringAsFixed(0)}'),
                        _loanDetail(
                            'Employment', loan['employment'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _loanDetail('Purpose', loan['purpose'] as String),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showLoanActionDialog(loan, 'Approve'),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showLoanActionDialog(loan, 'Reject'),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _loanDetail(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Transactions Tab
  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final tx = _recentTransactions[index];
        final isFlagged = tx['flag'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isFlagged
                ? AppColors.error.withOpacity(0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFlagged
                  ? AppColors.error.withOpacity(0.3)
                  : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isFlagged
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.transfer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFlagged ? Icons.warning_amber_rounded : Icons.swap_horiz,
                  color: isFlagged ? AppColors.error : AppColors.transfer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tx['type'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isFlagged) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FLAGGED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${tx['from']} → ${tx['to']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      tx['date'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${(tx['amount'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color:
                      isFlagged ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}