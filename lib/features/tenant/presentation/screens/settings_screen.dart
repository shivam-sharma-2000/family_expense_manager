import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/tenant_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = sl<TenantRepository>();
  final _formKey = GlobalKey<FormState>();

  final _propertyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _rateController = TextEditingController();

  bool _isLoading = false;
  PropertyEntity? _property;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    final familyId = await sl<ILocalStorageService>().familyId ?? '';
    if (familyId.isEmpty) return;

    setState(() => _isLoading = true);
    _repository.getProperty(familyId).first.then((either) {
      either.fold(
        (_) => setState(() => _isLoading = false),
        (prop) {
          if (mounted && prop != null) {
            setState(() {
              _property = prop;
              _propertyNameController.text = prop.name;
              _ownerNameController.text = prop.ownerName;
              _ownerPhoneController.text = prop.ownerPhone;
              _rateController.text = prop.defaultElectricityRate.toString();
              _isLoading = false;
            });
          } else {
            setState(() => _isLoading = false);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _uploadLogo() async {
    if (_property == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('properties/${_property!.id}/logo.png');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final updatedProp = _property!.copyWith(logoUrl: downloadUrl);
      await _repository.updateProperty(updatedProp);
      setState(() {
        _property = updatedProp;
      });
      _showToast('Logo updated successfully');
    } catch (e) {
      _showToast('Failed to upload logo');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final familyId = await sl<ILocalStorageService>().familyId ?? '';

    final prop = PropertyEntity(
      id: _property?.id ?? familyId,
      name: _propertyNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      ownerPhone: _ownerPhoneController.text.trim(),
      logoUrl: _property?.logoUrl,
      defaultElectricityRate: double.tryParse(_rateController.text) ?? 10.0,
      createdAt: _property?.createdAt ?? DateTime.now(),
    );

    final result = await _repository.updateProperty(prop);
    result.fold(
      (fail) => _showToast('Failed to save settings'),
      (_) {
        setState(() => _property = prop);
        _showToast('Settings saved successfully');
      },
    );
    setState(() => _isLoading = false);
  }

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    final familyId = await sl<ILocalStorageService>().familyId ?? '';

    try {
      final db = FirebaseFirestore.instance;
      
      // Fetch collections
      final tenantsSnap = await db.collection('tenants').where('propertyId', isEqualTo: familyId).get();
      final roomsSnap = await db.collection('rooms').where('propertyId', isEqualTo: familyId).get();
      final billsSnap = await db.collection('bills').where('propertyId', isEqualTo: familyId).get();
      final paymentsSnap = await db.collection('payments').where('propertyId', isEqualTo: familyId).get();

      final exportData = {
        'tenants': tenantsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        'rooms': roomsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        'bills': billsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        'payments': paymentsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ledgerly_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], subject: 'Ledgerly Database Backup');
    } catch (e) {
      _showToast('Failed to export data');
    }
    setState(() => _isLoading = false);
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
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
                    // Theme Mode Toggle
                    Text(
                      'App Preferences',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: LedgerlyColors.gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, themeState) {
                          final isDark = themeState.themeMode == ThemeMode.dark;
                          return SwitchListTile(
                            secondary: const HugeIcon(icon: HugeIcons.strokeRoundedMoon02, color: LedgerlyColors.gold),
                            title: const Text('Dark Theme Mode'),
                            value: isDark,
                            onChanged: (val) {
                              context.read<ThemeBloc>().add(const ToggleThemeEvent());
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Property Settings
                    Text(
                      'Property & Owner Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: LedgerlyColors.gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Logo display/upload
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: LedgerlyColors.surfaceAltLight,
                                  backgroundImage: _property?.logoUrl != null && _property!.logoUrl!.isNotEmpty
                                      ? NetworkImage(_property!.logoUrl!)
                                      : null,
                                  child: _property?.logoUrl == null || _property!.logoUrl!.isEmpty
                                      ? const Icon(Icons.business, size: 36, color: LedgerlyColors.inkSoftLight)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton(
                                  onPressed: _uploadLogo,
                                  child: const Text('Upload Logo'),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            TextFormField(
                              controller: _propertyNameController,
                              decoration: const InputDecoration(labelText: 'Property Name'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ownerNameController,
                              decoration: const InputDecoration(labelText: 'Owner Name'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ownerPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Owner Phone'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Default Electricity Unit Rate (₹)'),
                              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LedgerlyColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveSettings,
                        child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Backup & Utilities
                    Text(
                      'Utilities & Audits',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: LedgerlyColors.gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: LedgerlyColors.gold),
                        title: const Text('Export JSON Database'),
                        subtitle: const Text('Complete backup of Tenants, Rooms, Bills, Payments'),
                        onTap: _exportBackup,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
