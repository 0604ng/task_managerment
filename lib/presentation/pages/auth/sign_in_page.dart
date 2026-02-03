import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.featured_play_list, size: 100, color: Colors.teal),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                        const SizedBox(height: 20),

                        // PASSWORD
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
                            if (v == null || v.isEmpty) return "Password required";
                            if (v.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<AuthBloc>(),
                                    child: const ForgotPasswordPage(),
                                  ),
                                ),
                              );
                            },
                            child: const Text("Forgot password?"),
                          ),
                        ),
                        const SizedBox(height: 10),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (ctx, state) {
                            final isLoading = state is AuthLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      SignInRequested(
                                        _emailCtrl.text.trim(),
                                        _passwordCtrl.text.trim(),
                                      ),
                                    );
                                  }
                                },
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New user?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                        child: const Text("Register"),
                      ),
                    ],
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
