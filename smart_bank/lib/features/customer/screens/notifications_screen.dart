import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock data — replace with API later
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Transfer Successful',
      'message': 'Rs. 5,000 has been sent to Ali Raza successfully.',
      'time': '2 hours ago',
      'icon': Icons.swap_horiz,
      'color': AppColors.transfer,
      'isRead': false,
    },
    {
      'title': 'Loan Application Received',
      'message': 'Your loan application of Rs. 5,00,000 is under review.',
      'time': '1 day ago',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.pending,
      'isRead': false,
    },
    {
      'title': 'Deposit Confirmed',
      'message': 'Rs. 20,000 salary credit has been added to your account.',
      'time': '2 days ago',
      'icon': Icons.arrow_downward,
      'color': AppColors.deposit,
      'isRead': true,
    },
    {
      'title': 'Loan Approved',
      'message': 'Congratulations! Your personal loan of Rs. 2,00,000 has been approved.',
      'time': '5 days ago',
      'icon': Icons.check_circle_outline,
      'color': AppColors.success,
      'isRead': true,
    },
    {
      'title': 'Withdrawal Successful',
      'message': 'Rs. 3,000 has been withdrawn from your account.',
      'time': '6 days ago',
      'icon': Icons.money_off,
      'color': AppColors.withdrawal,
      'isRead': true,
    },
    {
      'title': 'Account Update',
      'message': 'Your profile information has been updated successfully.',
      'time': '1 week ago',
      'icon': Icons.person_outline,
      'color': AppColors.primary,
      'isRead': true,
    },
  ];

  int get _unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.customerDashboard),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Unread Badge
          if (_unreadCount > 0)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.primary.withOpacity(0.08),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_unreadCount new',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'unread notifications',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.border,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style:
                              TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _notificationCard(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(int index) {
    final n = _notifications[index];
    final isUnread = n['isRead'] == false;

    return Dismissible(
      key: Key('notif_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _markAsRead(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primary.withOpacity(0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withOpacity(0.2)
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (n['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  n['icon'] as IconData,
                  color: n['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            n['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n['message'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}