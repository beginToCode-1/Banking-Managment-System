import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/customer/screens/customer_dashboard.dart';
import '../../features/customer/screens/transfer_screen.dart';
import '../../features/customer/screens/deposit_screen.dart';
import '../../features/customer/screens/withdraw_screen.dart';
import '../../features/customer/screens/transaction_history_screen.dart';
import '../../features/customer/screens/loan_application_screen.dart';
import '../../features/customer/screens/loan_status_screen.dart';
import '../../features/customer/screens/profile_screen.dart';
import '../../features/customer/screens/notifications_screen.dart';
import '../../features/employee/screens/employee_dashboard.dart';
import '../../features/admin/screens/admin_dashboard.dart';

// Route names
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const customerDashboard = '/customer/dashboard';
  static const transfer = '/customer/transfer';
  static const deposit = '/customer/deposit';
  static const withdraw = '/customer/withdraw';
  static const transactionHistory = '/customer/transactions';
  static const loanApplication = '/customer/loan/apply';
  static const loanStatus = '/customer/loan/status';
  static const profile = '/customer/profile';
  static const notifications = '/customer/notifications';
  static const employeeDashboard = '/employee/dashboard';
  static const adminDashboard = '/admin/dashboard';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, state) => const CustomerDashboard(),
      ),
      GoRoute(
        path: AppRoutes.transfer,
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: AppRoutes.deposit,
        builder: (context, state) => const DepositScreen(),
      ),
      GoRoute(
        path: AppRoutes.withdraw,
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.loanApplication,
        builder: (context, state) => const LoanApplicationScreen(),
      ),
      GoRoute(
        path: AppRoutes.loanStatus,
        builder: (context, state) => const LoanStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.employeeDashboard,
        builder: (context, state) => const EmployeeDashboard(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
});