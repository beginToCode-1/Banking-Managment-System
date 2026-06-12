import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bank/core/constants/app_colors.dart';

import '../../core/router/app_router.dart' show AppRoutes;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
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
      'joinDate': 'Jan 15, 2026',
    },
    {
      'name': 'Sara Ali',
      'email': 'sara@email.com',
      'account': '9876-5432-1098',
      'status': 'Active',
      'balance': 75000.0,
      'joinDate': 'Feb 20, 2026',
    },
    {
      'name': 'Bilal Hassan',
      'email': 'bilal@email.com',
      'account': '1122-3344-5566',
      'status': 'Frozen',
      'balance': 30000.0,
      'joinDate': 'Mar 05, 2026',
    },
  ];

  final List<Map<String, dynamic>> _employees = [
    {
      'name': 'Usman Malik',
      'email': 'usman@smartbank.com',
      'role': 'Senior Officer',
      'department': 'Loans',
      'joinDate': 'Mar 01, 2025',
      'status': 'Active',
    },
    {
      'name': 'Ayesha Noor',
      'email': 'ayesha@smartbank.com',
      'role': 'Customer Officer',
      'department': 'Support',
      'joinDate': 'Jun 15, 2025',
      'status': 'Active',
    },
  ];

  final Map<String, dynamic> _analytics = {
    'totalCustomers': 1248,
    'totalTransactions': 8542,
    'totalDeposits': 45000000.0,
    'totalLoans': 12500000.0,
    'activeAccounts': 1190,
    'frozenAccounts': 58,
    'pendingLoans': 24,
    'approvedLoans': 312,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
          ],
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
                const SnackBar(
                  content: Text('Employee added successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleAccountStatus(int index) {
    final customer = _customers[index];
    final isActive = customer['status'] == 'Active';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isActive ? 'Freeze Account' : 'Activate Account'),
        content: Text(
          isActive
              ? 'Are you sure you want to freeze ${customer['name']}\'s account?'
              : 'Are you sure you want to activate ${customer['name']}\'s account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customers[index]['status'] =
                    isActive ? 'Frozen' : 'Active';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isActive
                        ? 'Account frozen successfully!'
                        : 'Account activated successfully!',
                  ),
                  backgroundColor:
                      isActive ? AppColors.error : AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isActive ? AppColors.error : AppColors.success,
            ),
            child: Text(isActive ? 'Freeze' : 'Activate'),
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
        title: const Text('Admin Dashboard'),
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
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Analytics'),
            Tab(icon: Icon(Icons.people_outline), text: 'Customers'),
            Tab(icon: Icon(Icons.badge_outlined), text: 'Employees'),
            Tab(icon: Icon(Icons.assessment_outlined), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildCustomersTab(),
          _buildEmployeesTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  // Analytics Tab
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _analyticsCard(
                'Total Customers',
                _analytics['totalCustomers'].toString(),
                Icons.people_outline,
                AppColors.primary,
              ),
              _analyticsCard(
                'Transactions',
                _analytics['totalTransactions'].toString(),
                Icons.receipt_long_outlined,
                AppColors.transfer,
              ),
              _analyticsCard(
                'Active Accounts',
                _analytics['activeAccounts'].toString(),
                Icons.check_circle_outline,
                AppColors.success,
              ),
              _analyticsCard(
                'Frozen Accounts',
                _analytics['frozenAccounts'].toString(),
                Icons.lock_outline,
                AppColors.error,
              ),
              _analyticsCard(
                'Pending Loans',
                _analytics['pendingLoans'].toString(),
                Icons.hourglass_top_rounded,
                AppColors.warning,
              ),
              _analyticsCard(
                'Approved Loans',
                _analytics['approvedLoans'].toString(),
                Icons.check_circle_outline,
                AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _financialCard(
            'Total Deposits',
            'Rs. ${(_analytics['totalDeposits'] / 1000000).toStringAsFixed(1)}M',
            AppColors.deposit,
            Icons.arrow_downward,
            0.75,
          ),
          const SizedBox(height: 10),
          _financialCard(
            'Total Loans Disbursed',
            'Rs. ${(_analytics['totalLoans'] / 1000000).toStringAsFixed(1)}M',
            AppColors.transfer,
            Icons.account_balance_wallet_outlined,
            0.45,
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
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
        ],
      ),
    );
  }

  Widget _financialCard(String label, String value, Color color,
      IconData icon, double progress) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // Customers Tab
  Widget _buildCustomersTab() {
    return Column(
      children: [
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withOpacity(0.1),
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
                                'Joined: ${customer['joinDate']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.visibility_outlined,
                                size: 16),
                            label: const Text('View'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _toggleAccountStatus(index),
                            icon: Icon(
                              isActive
                                  ? Icons.lock_outline
                                  : Icons.lock_open_outlined,
                              size: 16,
                            ),
                            label: Text(
                                isActive ? 'Freeze' : 'Activate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? AppColors.error
                                  : AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  // Employees Tab
  Widget _buildEmployeesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddEmployeeDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add New Employee'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _employees.length,
            itemBuilder: (context, index) {
              final emp = _employees[index];
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
                      backgroundColor: AppColors.accent.withOpacity(0.15),
                      child: Text(
                        (emp['name'] as String)[0],
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${emp['role']} • ${emp['department']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            emp['email'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Remove',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'remove') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Employee removed!'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
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

  // Reports Tab
  Widget _buildReportsTab() {
    final reports = [
      {
        'title': 'Total Customers',
        'value': '1,248',
        'subtitle': 'Registered accounts',
        'icon': Icons.people_outline,
        'color': AppColors.primary,
      },
      {
        'title': 'Total Transactions',
        'value': '8,542',
        'subtitle': 'All time transactions',
        'icon': Icons.receipt_long_outlined,
        'color': AppColors.transfer,
      },
      {
        'title': 'Total Deposits',
        'value': 'Rs. 45M',
        'subtitle': 'All time deposits',
        'icon': Icons.arrow_downward,
        'color': AppColors.deposit,
      },
      {
        'title': 'Total Loans',
        'value': 'Rs. 12.5M',
        'subtitle': 'Disbursed loans',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.warning,
      },
      {
        'title': 'Active Accounts',
        'value': '1,190',
        'subtitle': '95.4% of total',
        'icon': Icons.check_circle_outline,
        'color': AppColors.success,
      },
      {
        'title': 'Frozen Accounts',
        'value': '58',
        'subtitle': '4.6% of total',
        'icon': Icons.lock_outline,
        'color': AppColors.error,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'System Reports',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reports.map((report) => Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (report['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        report['icon'] as IconData,
                        color: report['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            report['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      report['value'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: report['color'] as Color,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}