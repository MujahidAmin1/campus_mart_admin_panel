import 'package:campus_mart_admin/core/utils/ktextstyle.dart';
import 'package:campus_mart_admin/features/auth/controller/auth_controller.dart';
import 'package:campus_mart_admin/features/auth/widget/submitBtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Error', style: kTextStyle(size: 20, isBold: true)),
          ],
        ),
        content: Text(message, style: kTextStyle(size: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: kTextStyle(color: Color(0xff8E6CEF), isBold: true)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authstate = ref.watch(authControllerProvider);

    // Listen for authentication errors
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          _showErrorDialog(error.toString().replaceAll('Exception: ', ''));
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff6CEFBD).withOpacity(0.15),
              Colors.white,
              Color(0xff8E6CEF).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff8E6CEF), Color(0xff6CEFBD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff8E6CEF).withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                        child: Text("CampusMart Admin",
                            style: kTextStyle(color: Color(0xff3A2770), size: 26, isBold: true))),
                    Center(
                        child: Text("Web Administration Portal",
                            style: kTextStyle(color: Color(0xff3A2770).withOpacity(0.6), size: 16))),
                    const SizedBox(height: 30),
                    Center(
                        child: Text("Admin Login",
                            style: kTextStyle(size: 28, isBold: true, color: Color(0xff3A2770)))),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 8,
                      shadowColor: Color(0xff8E6CEF).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Color(0xff6CEFBD).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          spacing: 18,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: emailController,
                              cursorColor: Color(0xff8E6CEF),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xff8E6CEF)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xff8E6CEF), width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red.shade300),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              cursorColor: Color(0xff8E6CEF),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: Color(0xff8E6CEF)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xff8E6CEF), width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red.shade300),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            buildSubmitButton(
                              false, // Always false since this is login only
                              authstate, 
                              () async {
                                if (_formKey.currentState!.validate()) {
                                  final authcontroller = ref.read(authControllerProvider.notifier);
                                  await authcontroller.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                }
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}