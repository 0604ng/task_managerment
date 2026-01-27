//
// lib/presentation/screen/sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_page.dart';

// === ĐƯỜNG DẪN ĐÚNG THEO CẤU TRÚC CỦA BẠN ===
// file đang ở: lib/presentation/screen/sign_in_page.dart
// auth bloc ở: lib/presentation/blocs/auth/
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/auth/auth_state.dart';

// colors ở lib/const/colors.dart
import '../const/colors.dart';

// sign_up_page giả sử nằm cùng thư mục screen/
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.featured_play_list,
                      size: 100, color: Colors.teal),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back!",
                    style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || !v.contains("@")) {
                              return "Invalid email";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() => _hidePassword = !_hidePassword);
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // === THÊM NÚT FORGOT PASSWORD ===
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text("Forgot password?"),
                          ),
                        ),

                        const SizedBox(height: 10),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (ctx, state) {
                            final loading = state is AuthLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!
                                      .validate()) {
                                    context.read<AuthBloc>().add(
                                      SignInRequested(
                                        _emailCtrl.text.trim(),
                                        _passwordCtrl.text.trim(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: loading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text("Sign In"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text("New user? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}