import 'package:expense_manager/core/service/auth_service.dart';
import 'package:flutter/material.dart';
import '../core/di/injection_container.dart';
import '../core/service/user_service.dart';

class FamilyIdScreen extends StatefulWidget {
  final String email;
  final String password;
  final bool isGoogleSignIn;
  
  const FamilyIdScreen({
    Key? key,
    required this.email,
    required this.password,
    this.isGoogleSignIn = false,
  }) : super(key: key);

  @override
  _FamilyIdScreenState createState() => _FamilyIdScreenState();
}

class _FamilyIdScreenState extends State<FamilyIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyIdController = TextEditingController();
  bool _isLoading = false;
  bool _createNewFamily = false;

  @override
  void dispose() {
    _familyIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = sl<AuthService>();
      final userService = sl<UserService>();
      
      if (widget.isGoogleSignIn) {
        // Handle Google sign-in with family ID
        final user = await authService.signInWithGoogle();
        if (user != null && !_createNewFamily && _familyIdController.text.isNotEmpty) {
          await userService.joinFamily(user.uid, _familyIdController.text);
        }
      } else {
        // Handle email sign-up with family ID
        final familyId = _createNewFamily ? null : _familyIdController.text;
        await authService.registerWithEmail(
          email: widget.email,
          password: widget.password,
          familyId: familyId,
        );
      }
      
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join or Create a Family',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Create a new family group'),
                value: _createNewFamily,
                onChanged: (value) {
                  setState(() {
                    _createNewFamily = value ?? false;
                    if (_createNewFamily) {
                      _familyIdController.clear();
                    }
                  });
                },
              ),
              if (!_createNewFamily) ...[  
                const SizedBox(height: 10),
                TextFormField(
                  controller: _familyIdController,
                  decoration: const InputDecoration(
                    labelText: 'Family ID',
                    hintText: 'Enter your family ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_createNewFamily && (value == null || value.isEmpty)) {
                      return 'Please enter a family ID or check "Create new family"';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ask your family members for the family ID or create a new family group.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
