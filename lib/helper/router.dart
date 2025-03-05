import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/model/category.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/model/transaction.dart';
import 'package:operational_app/screen/active_store_screen.dart';
import 'package:operational_app/screen/category_detail_screen.dart';
import 'package:operational_app/screen/employee_screen.dart';
import 'package:operational_app/screen/home_screen.dart';
import 'package:operational_app/screen/login_screen.dart';
import 'package:operational_app/screen/company_screen.dart';
import 'package:operational_app/screen/setting_screen.dart';
import 'package:operational_app/screen/store_detail_screen.dart';
import 'package:operational_app/screen/transaction_detail_screen.dart';
import 'package:operational_app/screen/transaction_screen.dart';
import 'package:operational_app/screen/category_screen.dart';
import 'package:operational_app/screen/store_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final isLogin = false;

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: isLogin ? '/home' : '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/setting',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: '/active-store',
      builder: (context, state) => const ActiveStoreScreen(),
    ),
    GoRoute(
      path: '/company',
      builder: (context, state) => const CompanyScreen(),
    ),
    GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
    GoRoute(
      path: '/store-detail',
      builder: (context, state) {
        final store = state.extra as Store;
        return StoreDetailScreen(store: store);
      },
    ),
    GoRoute(
      path: '/employee',
      builder: (context, state) => const EmployeeScreen(),
    ),
    GoRoute(
      path: '/category',
      builder: (context, state) => const CategoryScreen(),
    ),
    GoRoute(
      path: '/category-detail',
      builder: (context, state) {
        final category = state.extra as Category;
        return CategoryDetailScreen(category: category);
      },
    ),
    GoRoute(
      path: '/transaction',
      builder: (context, state) => const TransactionScreen(),
    ),
    GoRoute(
      path: '/transaction-detail',
      builder: (context, state) {
        final transaction = state.extra as Transaction;
        return TransactionDetailScreen(transaction: transaction);
      },
    ),
  ],
);
