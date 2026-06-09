import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_manager/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_manager/features/family/presentation/bloc/family_event.dart';
import 'package:expense_manager/features/family/presentation/bloc/family_state.dart';

class CreateFamilyDialog extends StatefulWidget {
  final String userId;

  const CreateFamilyDialog({super.key, required this.userId});

  @override
  State<CreateFamilyDialog> createState() => _CreateFamilyDialogState();
}

class _CreateFamilyDialogState extends State<CreateFamilyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<FamilyBloc>().add(
            CreateFamilyEvent(
              familyName: _familyNameController.text.trim(),
              userId: widget.userId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyBloc, FamilyState>(
      listener: (context, state) {
        if (state is FamilyCreatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Family created successfully! Code: ${state.family.familyCode}')),
          );
          context.pop();
        } else if (state is FamilyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is FamilyLoading;

        return AlertDialog(
          title: Text(
            'Create a Family',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start your own family to manage shared expenses. You will receive a 6-character code to share with your family members.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _familyNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a family name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Family Name',
                    hintText: 'e.g., The Smiths',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Create', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
