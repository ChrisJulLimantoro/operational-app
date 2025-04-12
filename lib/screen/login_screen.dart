import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:operational_app/api/auth.dart';
import 'package:operational_app/bloc/permission_bloc.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isDisabled = true;
  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isDisabled =
          _emailController.text.isEmpty || _passwordController.text.isEmpty;
    });
  }

  void _handleLogin(BuildContext context) async {
    debugPrint("Hello");
    final response = await AuthAPI.login(
      context,
      _emailController.text,
      _passwordController.text,
    );
    // if (!context.mounted) return;
    if (response) {
      _emailController.clear();
      _passwordController.clear();

      // Fetching Permissions
      if (!context.mounted) return;
      await context.read<PermissionCubit>().fetchPermissions(context);

      // Assuming the login was successful, navigate to the home screen
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bluePrimary, // Solid blue background
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: Text(
                  "Logamas",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: max(MediaQuery.of(context).size.height - 300, 500),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masuk ke Akun Anda",
                      style: AppTextStyles.headingBlack,
                    ),
                    SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("Email", style: AppTextStyles.subheadingBlue),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.pinkTertiary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.pinkPrimary,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                        ), // Ensure text doesn't touch the border
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Masukkan email Anda",
                            hintStyle: TextStyle(
                              color: AppColors.pinkPrimary,
                              fontSize: 14,
                            ),
                            border: InputBorder.none, // Remove default border
                            filled: true,
                            fillColor:
                                Colors
                                    .transparent, // Prevent background overlap
                          ),
                          cursorColor: AppColors.pinkPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                      child: Text(
                        "Password",
                        style: AppTextStyles.subheadingBlue,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.pinkTertiary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.pinkPrimary,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: isPasswordObscure,
                                decoration: InputDecoration(
                                  hintText: "Masukkan password Anda",
                                  hintStyle: TextStyle(
                                    color: AppColors.pinkPrimary,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor:
                                      Colors.transparent, // Keep it transparent
                                ),
                                cursorColor: AppColors.pinkPrimary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isPasswordObscure
                                    ? CupertinoIcons.eye_fill
                                    : CupertinoIcons.eye_slash_fill,
                                color: AppColors.pinkPrimary,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordObscure = !isPasswordObscure;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                    ElevatedButton(
                      onPressed:
                          isDisabled
                              ? null
                              : () {
                                _handleLogin(context);
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkPrimary,
                        disabledBackgroundColor:
                            AppColors
                                .pinkSecondary, // Correct way to handle disabled color
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Masuk", style: AppTextStyles.buttonText),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
