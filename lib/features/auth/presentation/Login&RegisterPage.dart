import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import '../../../app/routes/my_app_router_const.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/service/auth_service.dart';
import '../../../database/DBHelper.dart';
import 'LoginPage.dart';
import 'bloc/auth_bloc.dart';

class LoginAndRegisterPage extends StatefulWidget {
  const LoginAndRegisterPage({super.key});

  @override
  State<LoginAndRegisterPage> createState() => _LoginAndRegisterPageState();
}

class _LoginAndRegisterPageState extends State<LoginAndRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _familyIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool passwordVisible = false;

  // Form validation
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return showError('unull');
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return showError('nnull');
    }
    if (value.length < 10) {
      return showError('nLen');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return showError('enull');
    }
    // if (value.length < 10) {
    //   return showError('nLen');
    // }
    return null;
  }

  String? _validateFamilyId(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length != 6) {
        return showError('fLen');
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final pattern = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_+\-=\[\]{};:\\|,.<>\/?]).+$',
    );

    if (value == null || value.isEmpty) {
      return showError('pnull');
    }
    if (value.length < 8) {
      return showError("len");
    }
    if (!pattern.hasMatch(value)) {
      return showError("spec");
    }
    return null;
  }

  String? _validateRePassword(String? value) {
    if (value == null || value.isEmpty) {
      return showError('pnull');
    }

    if (!(value == _passwordController.text)) {
      return showError("pre");
    }
    return null;
  }

  showError(String c) {
    switch (c) {
      case "len":
        return "Length should be greater then 8 characters";
      case "nLen":
        return "Please enter a valid phone number";
      case "fLen":
        return "Please enter a valid family id";
      case "spec":
        return "Password should be have\n"
            "* at least one special character\n"
            "* at least one capital later\n"
            "* at least one number";
      case "pnull":
        return "Please enter password";
      case "pre":
        return "Password should match";
      case "unull":
        return "Please enter user name";

      case "nnull":
        return "Please enter your phone number";

      case "enull":
        return "Please enter your email";
      default:
        return null;
    }
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(
        RegisterUserEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          familyId: _familyIdController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _familyIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Welcome text
                  Text(
                    'Welcome to Expense Manager',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please fill in the details to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  Text(
                    'Full Name',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: _validateName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
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

                  // Phone Number Field
                  Text(
                    'Phone Number',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_android_rounded,
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

                  // Email Field
                  Text(
                    'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
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

                  // Family Id Field
                  Text(
                    'Family Id (optional)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _familyIdController,
                    validator: _validateFamilyId,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your family id',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.family_restroom,
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
                    keyboardType: TextInputType.text,
                    obscureText: passwordVisible,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.key,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        child: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      suffixStyle: GoogleFonts.poppins(
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
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
                  Text(
                    'Confirm Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    validator: _validateRePassword,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.key,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixStyle: GoogleFonts.poppins(
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 32),

                  // Register Button
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        context.pushReplacement(MyAppRouteConst.home);
                      }
                      if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    builder: (BuildContext context, AuthState state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegistration,
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
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Already have an account
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
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

                  // Terms and conditions
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'By signing up, you agree to our Terms and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
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
