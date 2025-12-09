// lib/presentation/screen/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/auth/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController(); // ← KHỞI TẠO
  final _confirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose(); // ← dispose
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AuthAuthenticated) {
              // Optionally pop when registered (if you want)
              Navigator.pop(context);
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // USERNAME
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return "Username required";
                            if (v.trim().length < 3) return "Min 3 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // EMAIL
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Email required";
                            if (!v.contains("@")) return "Invalid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // PASSWORD
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Password required";
                            if (v.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // CONFIRM PASSWORD
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _hideConfirm,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.verified_user_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Confirm password required";
                            if (v != _passwordCtrl.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (ctx, state) {
                            final isLoading = state is AuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!.validate()) {
                                    // GỬI 3 tham số: email, password, username
                                    context.read<AuthBloc>().add(
                                      SignUpRequested(
                                        _emailCtrl.text.trim(),
                                        _passwordCtrl.text.trim(),
                                        _usernameCtrl.text.trim(),
                                      ),
                                    );
                                  }
                                },
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("Register", style: TextStyle(fontSize: 18)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Already have an account? Sign in"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
