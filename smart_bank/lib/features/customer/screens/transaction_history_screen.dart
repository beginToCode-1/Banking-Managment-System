import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;

  final List<String> _filters = ['All', 'Deposit', 'Withdrawal', 'Transfer'];

  // Mock data — replace with API later
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'type': 'Transfer',
      'amount': -5000.0,
      'date': 'Jun 10, 2026',
      'description': 'Sent to Ali Raza',
      'status': 'Completed',
      'icon': Icons.arrow_upward,
      'color': AppColors.withdrawal,
    },
    {
      'type': 'Deposit',
      'amount': 20000.0,
      'date': 'Jun 09, 2026',
      'description': 'Salary Credit',
      'status': 'Completed',
      'icon': Icons.arrow_downward,
      'color': AppColors.deposit,
    },
    {
      'type': 'Withdrawal',
      'amount': -3000.0,
      'date': 'Jun 08, 2026',
      'description': 'ATM Withdrawal',
      'status': 'Completed',
      'icon': Icons.money_off,
      'color': AppColors.withdrawal,
    },
    {
      'type': 'Transfer',
      'amount': -1500.0,
      'date': 'Jun 07, 2026',
      'description': 'Sent to Sara',
      'status': 'Completed',
      'icon': Icons.arrow_upward,
      'color': AppColors.withdrawal,
    },
    {
      'type': 'Deposit',
      'amount': 10000.0,
      'date': 'Jun 06, 2026',
      'description': 'Freelance Payment',
      'status': 'Completed',
      'icon': Icons.arrow_downward,
      'color': AppColors.deposit,
    },
    {
      'type': 'Withdrawal',
      'amount': -2000.0,
      'date': 'Jun 05, 2026',
      'description': 'Cash Withdrawal',
      'status': 'Completed',
      'icon': Icons.money_off,
      'color': AppColors.withdrawal,
    },
    {
      'type': 'Transfer',
      'amount': -7500.0,
      'date': 'Jun 04, 2026',
      'description': 'Rent Payment',
      'status': 'Completed',
      'icon': Icons.arrow_upward,
      'color': AppColors.withdrawal,
    },
    {
      'type': 'Deposit',
      'amount': 5000.0,
      'date': 'Jun 03, 2026',
      'description': 'Bonus Credit',
      'status': 'Completed',
      'icon': Icons.arrow_downward,
      'color': AppColors.deposit,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _allTransactions;
    return _allTransactions
        .where((tx) => tx['type'] == _selectedFilter)
        .toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.customerDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _pickDateRange,
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Bar
          Container(
            color: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Total In', '+Rs. 35,000', AppColors.deposit),
                _divider(),
                _summaryItem(
                    'Total Out', '-Rs. 19,000', AppColors.withdrawal),
                _divider(),
                _summaryItem('Net', '+Rs. 16,000', Colors.white),
              ],
            ),
          ),

          // Date Range Chip
          if (_selectedDateRange != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _selectedDateRange = null),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ],
              ),
            ),

          // Filter Tabs
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Transaction Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${transactions.length} transactions',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppColors.border),
                        SizedBox(height: 12),
                        Text(
                          'No transactions found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _transactionCard(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final isPositive = tx['amount'] > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (tx['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(tx['icon'] as IconData,
                color: tx['color'] as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      tx['date'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx['status'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}Rs. ${tx['amount'].abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tx['color'] as Color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tx['type'] as String,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}