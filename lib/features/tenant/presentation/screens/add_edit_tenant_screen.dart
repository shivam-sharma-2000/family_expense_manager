import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/usecases/add_tenant.dart';
import '../../domain/usecases/update_tenant.dart';
import '../../domain/usecases/get_tenants.dart';
import '../../../../core/service/i_local_storage_service.dart';

class AddEditTenantScreen extends StatefulWidget {
  final String? tenantId;

  const AddEditTenantScreen({super.key, this.tenantId});

  @override
  State<AddEditTenantScreen> createState() => _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends State<AddEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TenantEntity? _existingTenant;
  File? _localImageFile;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _joiningDate = DateTime.now();
  DateTime _agreementEndDate = DateTime.now().add(const Duration(days: 365));
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _loadExistingTenant();
  }

  Future<void> _loadExistingTenant() async {
    if (widget.tenantId == null) return;

    setState(() => _isLoading = true);
    final getTenants = sl<GetTenants>();
    final result = await getTenants().first;

    if (!mounted) return;

    result.fold(
      (failure) {
        if (mounted) setState(() => _isLoading = false);
      },
      (tenants) {
        if (mounted) {
          try {
            _existingTenant = tenants.firstWhere(
              (t) => t.id == widget.tenantId,
            );
            _populateFields();
          } catch (_) {}
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _populateFields() {
    if (_existingTenant == null) return;
    final t = _existingTenant!;

    _nameController.text = t.name;
    _phoneController.text = t.phone;
    _emailController.text = t.email;
    _idNumberController.text = t.idNumber;
    _roomNumberController.text = t.roomNumber;
    _floorController.text = t.floor;
    _rentController.text = t.rent.toString();
    _depositController.text = t.deposit.toString();
    _notesController.text = t.notes;

    _joiningDate = t.joiningDate;
    _agreementEndDate = t.agreementEndDate;
    _status = t.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _roomNumberController.dispose();
    _floorController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _localImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final localService = sl<ILocalStorageService>();
    final userId = await localService.userId ?? '';
    final familyId = await localService.familyId ?? '';

    final tenantId = _existingTenant?.id ?? const Uuid().v4();
    String photoUrl = _existingTenant?.photoUrl ?? '';

    // Upload image to Firebase Storage if a new local one was picked
    if (_localImageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('properties/$familyId/tenants/$tenantId/photo.jpg');
        final uploadTask = await storageRef.putFile(_localImageFile!);
        photoUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        _showToast('Failed to upload tenant image.');
      }
    }

    // Tenant Code generation helper
    final code = _existingTenant?.tenantCode ?? 'TNT-${DateTime.now().millisecond}';

    final tenant = TenantEntity(
      id: tenantId,
      propertyId: familyId,
      tenantCode: code,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      idNumber: _idNumberController.text.trim(),
      roomNumber: _roomNumberController.text.trim(),
      floor: _floorController.text.trim(),
      rent: double.tryParse(_rentController.text) ?? 0.0,
      deposit: double.tryParse(_depositController.text) ?? 0.0,
      joiningDate: _joiningDate,
      agreementEndDate: _agreementEndDate,
      status: _status,
      photoUrl: photoUrl,
      notes: _notesController.text.trim(),
      createdAt: _existingTenant?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userId,
    );

    if (_existingTenant != null) {
      final updateTenant = sl<UpdateTenant>();
      await updateTenant(tenant);
    } else {
      final addTenant = sl<AddTenant>();
      await addTenant(tenant);
    }

    if (!mounted) return;
    context.pop();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tenantId != null;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tenant Profile' : 'Register Tenant'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Photo Picker
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: LedgerlyColors.surfaceAltLight,
                            backgroundImage: _localImageFile != null
                                ? FileImage(_localImageFile!)
                                : (_existingTenant != null && _existingTenant!.photoUrl.isNotEmpty
                                    ? NetworkImage(_existingTenant!.photoUrl) as ImageProvider
                                    : null),
                            child: _localImageFile == null && (_existingTenant == null || _existingTenant!.photoUrl.isEmpty)
                                ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 40, color: LedgerlyColors.inkSoftLight)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: LedgerlyColors.gold,
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('Basic Information', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number (10 digits)'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final reg = RegExp(r'^[6-9]\d{9}$');
                        if (!reg.hasMatch(val)) return 'Must be a 10-digit number starting 6-9';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!reg.hasMatch(val)) return 'Enter a valid email format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _idNumberController,
                      decoration: const InputDecoration(labelText: 'Aadhaar / ID Card Number'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    Text('Lease & Rent Details', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _roomNumberController,
                            decoration: const InputDecoration(labelText: 'Room Number'),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _floorController,
                            decoration: const InputDecoration(labelText: 'Floor (e.g. 2nd)'),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Monthly Rent (₹)'),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final rent = double.tryParse(val);
                              if (rent == null || rent < 0) return 'Must be >= 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _depositController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker('Joining Date', _joiningDate, (date) => setState(() => _joiningDate = date)),
                    const SizedBox(height: 12),
                    _buildDatePicker('Agreement End Date', _agreementEndDate, (date) => setState(() => _agreementEndDate = date)),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _status,
                      dropdownColor: context.theme.cardColor,
                      decoration: const InputDecoration(labelText: 'Tenant Status'),
                      items: ['Active', 'Vacated'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Additional Notes / Terms'),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LedgerlyColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveTenant,
                        child: Text(isEditing ? 'Save Changes' : 'Register Tenant', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker(String label, DateTime currentDate, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${currentDate.day}/${currentDate.month}/${currentDate.year}'),
            const Icon(Icons.calendar_today, size: 18, color: LedgerlyColors.inkSoftLight),
          ],
        ),
      ),
    );
  }
}
