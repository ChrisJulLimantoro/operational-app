import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/auth.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  bool isOldPassword = true;
  final _newPasswordController = TextEditingController();
  bool isNewPassword = true;
  final _confirmPasswordController = TextEditingController();
  bool isConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Ganti Password', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                    child: Text(
                      "Password Lama",
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
                              controller: _oldPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: isOldPassword,
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
                              isOldPassword
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill,
                              color: AppColors.pinkPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                isOldPassword = !isOldPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                    child: Text(
                      "Password Baru",
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
                              controller: _newPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: isNewPassword,
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
                              isNewPassword
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill,
                              color: AppColors.pinkPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                isNewPassword = !isNewPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                    child: Text(
                      "Konfirmasi Password",
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
                              controller: _confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: isConfirmPassword,
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
                              isConfirmPassword
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill,
                              color: AppColors.pinkPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmPassword = !isConfirmPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.success,
                      ),
                    ),

                    child: Center(
                      child: Text(
                        "Ganti Password",
                        style: AppTextStyles.headingWhite,
                      ),
                    ),
                    onPressed: () async {
                      // Add change password logic here
                      await AuthAPI.changePassword(
                        context,
                        _oldPasswordController.value.text,
                        _newPasswordController.value.text,
                        _confirmPasswordController.value.text,
                      );
                      if (!context.mounted) return;
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
