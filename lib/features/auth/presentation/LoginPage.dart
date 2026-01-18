import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/routes/my_app_router_const.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;


  @override
  void initState() {
    super.initState();
  }

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form validation
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(LoginSubmitted(email: _emailController.text, password: _passwordController.text));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(MyAppRouteConst.home);
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Back button and title
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Welcome text
                    Text(
                      'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your credentials to access your account',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    Text(
                      'Email Number',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      validator: _validatePhone,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.alternate_email_outlined,
                          color: Color(0xFF94A3B8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: !_isPasswordVisible,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2563EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Don't have an account
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.pushReplacement(MyAppRouteConst.signUp);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Or continue with
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Or continue with',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: 'assets/icons/google_logo.png',
                          onPressed: () {
                            // TODO: Implement Google sign in
                            signInWithGoogle();
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: 'assets/icons/facebook_logo.png',
                          onPressed: () {
                            // TODO: Implement Facebook sign in
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: 'assets/icons/apple_logo.png',
                          onPressed: () {
                            // TODO: Implement Apple sign in
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Image.asset(
          icon,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.error_outline,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    context.read<AuthBloc>().add(GoogleLoginSubmitted());
  }

  Future<void> _saveUserToFirestore(User user) async {
    // final doc = _firestore.collection('users').doc(user.uid);
    //
    // await doc.set({
    //   'uid': user.uid,
    //   'name': user.displayName,
    //   'email': user.email,
    //   'photoUrl': user.photoURL ?? '',
    //   'lastLogin': FieldValue.serverTimestamp(),
    //   'createdAt': FieldValue.serverTimestamp(),
    // }, SetOptions(merge: true));
  }

}

