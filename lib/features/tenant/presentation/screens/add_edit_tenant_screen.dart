import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
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

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _familyMembersController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _rentController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _depositController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _prevMeterReadingController = TextEditingController();
  final _currMeterReadingController = TextEditingController();
  final _unitRateController = TextEditingController();

  DateTime _rentStartDate = DateTime.now();
  TenantStatus _status = TenantStatus.active;

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
            _existingTenant = tenants.firstWhere((t) => t.id == widget.tenantId);
            _populateFields();
          } catch (_) {
            // Not found
          }
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _populateFields() {
    if (_existingTenant == null) return;
    final t = _existingTenant!;

    _nameController.text = t.name;
    _mobileController.text = t.mobile;
    _aadhaarController.text = t.aadhaar ?? '';
    _familyMembersController.text = t.familyMembers.toString();
    _roomNumberController.text = t.roomNumber;
    _rentController.text = t.rent.toString();
    _maintenanceController.text = t.maintenance.toString();
    _depositController.text = t.advance.toString();
    _dueDateController.text = t.rentDueDate.toString();
    _meterNumberController.text = t.meterNumber ?? '';
    _prevMeterReadingController.text = t.previousReading.toString();
    _currMeterReadingController.text = t.previousReading.toString(); // Just default to previous
    _unitRateController.text = t.unitRate.toString();

    _rentStartDate = t.rentStartDate;
    _status = t.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _familyMembersController.dispose();
    _roomNumberController.dispose();
    _rentController.dispose();
    _maintenanceController.dispose();
    _depositController.dispose();
    _dueDateController.dispose();
    _meterNumberController.dispose();
    _prevMeterReadingController.dispose();
    _currMeterReadingController.dispose();
    _unitRateController.dispose();
    super.dispose();
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final localService = sl<ILocalStorageService>();
    final userId = await localService.userId;
    final familyId = await localService.familyId;

    final tenant = TenantEntity(
      id: _existingTenant?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      aadhaar: _aadhaarController.text.trim().isEmpty ? null : _aadhaarController.text.trim(),
      familyMembers: int.tryParse(_familyMembersController.text) ?? 1,
      roomNumber: _roomNumberController.text.trim(),
      photoPath: _existingTenant?.photoPath,
      rent: double.tryParse(_rentController.text) ?? 0.0,
      maintenance: double.tryParse(_maintenanceController.text) ?? 0.0,
      advance: double.tryParse(_depositController.text) ?? 0.0,
      rentStartDate: _rentStartDate,
      rentDueDate: int.tryParse(_dueDateController.text) ?? 1,
      status: _status,
      meterNumber: _meterNumberController.text.trim().isEmpty ? null : _meterNumberController.text.trim(),
      previousReading: double.tryParse(_prevMeterReadingController.text) ?? 0.0,
      unitRate: double.tryParse(_unitRateController.text) ?? 0.0,
      userId: userId ?? '',
      familyId: familyId ?? '',
      isSynced: false,
      isDeleted: false,
    );

    if (_existingTenant != null) {
      final updateTenant = sl<UpdateTenant>();
      await updateTenant(tenant);
    } else {
      final addTenant = sl<AddTenant>();
      await addTenant(tenant);
    }

    if (!mounted) return;
    context.pop(); // Go back
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tenantId != null;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing ? 'Edit Tenant' : 'Add Tenant',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const HugeIcon(size: 18.0,  
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.white, ),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: HugeIcons.strokeRoundedUser,
                    ),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: HugeIcons.strokeRoundedCall,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _aadhaarController,
                      label: 'Aadhaar Number (Optional)',
                      icon: HugeIcons.strokeRoundedLicense,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _familyMembersController,
                      label: 'Number of Family Members',
                      icon: HugeIcons.strokeRoundedUserGroup,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _roomNumberController,
                      label: 'Room / Property Number',
                      icon: HugeIcons.strokeRoundedHome01,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Rental Information'),
                    _buildTextField(
                      controller: _rentController,
                      label: 'Monthly Rent (₹)',
                      icon: HugeIcons.strokeRoundedWallet01,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _maintenanceController,
                      label: 'Maintenance Charges (₹)',
                      icon: HugeIcons.strokeRoundedMoney04,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _depositController,
                      label: 'Security Deposit (₹)',
                      icon: HugeIcons.strokeRoundedSafe,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _dueDateController,
                      label: 'Rent Due Date (e.g. 5)',
                      icon: HugeIcons.strokeRoundedCalendar01,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),
                    _buildStatusDropdown(),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Electricity Information (Optional)'),
                    _buildTextField(
                      controller: _meterNumberController,
                      label: 'Meter Number',
                      icon: HugeIcons.strokeRoundedEnergy,
                    ),
                    _buildTextField(
                      controller: _prevMeterReadingController,
                      label: 'Previous Reading',
                      icon: HugeIcons.strokeRoundedDashboardCircle,
                      keyboardType: TextInputType.number,
                      readOnly: isEditing,
                    ),
                    _buildTextField(
                      controller: _currMeterReadingController,
                      label: 'Current Reading',
                      icon: HugeIcons.strokeRoundedDashboardCircle,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _unitRateController,
                      label: 'Per Unit Rate (₹)',
                      icon: HugeIcons.strokeRoundedMoney01,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveTenant,
                        child: Text(
                          isEditing ? 'Save Changes' : 'Add Tenant',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required dynamic icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: HugeIcon(size: 18.0,  icon: icon, color: Colors.white54, ),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.amber),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Optional fields
            if (label.contains('(Optional)') || label.contains('Electricity'))
              return null;
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _rentStartDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Colors.amber,
                  onPrimary: Colors.black,
                  surface: Color(0xFF1A1A1A),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _rentStartDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const HugeIcon(size: 18.0,  
              icon: HugeIcons.strokeRoundedCalendar01,
              color: Colors.white54, ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rent Start Date',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '${_rentStartDate.day}/${_rentStartDate.month}/${_rentStartDate.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<TenantStatus>(
      value: _status,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Tenant Status',
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const HugeIcon(size: 18.0,  
          icon: HugeIcons.strokeRoundedActivity01,
          color: Colors.white54, ),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: TenantStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _status = val);
      },
    );
  }
}
