import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/helper/notification.dart';
import 'package:operational_app/helper/router.dart';
import 'package:operational_app/notifier/sales_notifier.dart';
import 'package:operational_app/notifier/stock_opname_notifier.dart';
import 'package:operational_app/notifier/stock_out_notifier.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()..loadAuthParams(context)),
        ChangeNotifierProvider(create: (context) => StockOpnameNotifier()),
        ChangeNotifierProvider(create: (context) => StockOutNotifier()),
        ChangeNotifierProvider(create: (context) => SalesNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Logamas',
      scaffoldMessengerKey: NotificationHelper.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bluePrimary,
          surfaceTintColor: AppColors.bluePrimary,
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}
