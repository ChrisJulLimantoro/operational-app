import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/theme/text.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String email = "";
  bool isOwner = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    email = context.read<AuthCubit>().state.userEmail;
    isOwner = context.read<AuthCubit>().state.isOwner;
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting", style: AppTextStyles.headingWhite),
        backgroundColor: AppColors.bluePrimary,
      ),
      body: Container(
        color: AppColors.bluePrimary,
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            spacing: 0,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 100,
                  height: 100,
                  color: AppColors.pinkTertiary,
                  child: Center(
                    child: Text(
                      email.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 70,
                        color: AppColors.pinkPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(email, style: AppTextStyles.headingWhite),
              Text(
                "(${isOwner ? "Owner" : "Pegawai"})",
                style: AppTextStyles.labelWhite,
              ),
              SizedBox(height: 60),
              Divider(),
              ListTile(
                title: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.storefront, color: Colors.white),
                    Text(
                      "Change Active Store",
                      style: AppTextStyles.labelWhite,
                    ),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).push('/active-store');
                },
              ),
              Divider(),
              ListTile(
                title: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.password_outlined, color: Colors.white),
                    Text("Change Password", style: AppTextStyles.labelWhite),
                  ],
                ),
                onTap: () {
                  // GoRouter.of(context).go('/');
                },
              ),
              Divider(),
              ListTile(
                title: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    Text("Logout", style: AppTextStyles.labelWhite),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).go('/');
                },
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
