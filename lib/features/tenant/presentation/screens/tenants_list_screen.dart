import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_entity.dart';
import '../bloc/tenant_bloc.dart';

class TenantsListScreen extends StatefulWidget {
  const TenantsListScreen({super.key});

  @override
  State<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends State<TenantsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // All | Active | Vacated
  String _sortBy = 'Name'; // Name | Room | Rent
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TenantBloc>().add(LoadTenantsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tenants Ledger'),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: LedgerlyColors.gold),
            onPressed: () {
              context.push(MyAppRouteConst.addEditTenant);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tenants by name...',
                    prefixIcon: const Icon(Icons.search, color: LedgerlyColors.inkSoftLight),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        dropdownColor: context.theme.cardColor,
                        style: TextStyle(color: context.theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All', 'Active', 'Vacated'].map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _statusFilter = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        dropdownColor: context.theme.cardColor,
                        style: TextStyle(color: context.theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['Name', 'Room', 'Rent'].map((sort) {
                          return DropdownMenuItem(value: sort, child: Text(sort));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _sortBy = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Header line with uppercase column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TENANT NAME / ROOM',
                  style: GoogleFonts.plusJakartaSans(
                    color: LedgerlyColors.inkFaintLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'RENT & STATUS',
                  style: GoogleFonts.plusJakartaSans(
                    color: LedgerlyColors.inkFaintLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Tenants list builder
          Expanded(
            child: BlocBuilder<TenantBloc, TenantState>(
              builder: (context, state) {
                if (state is TenantLoading) {
                  return const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold));
                } else if (state is TenantError) {
                  return Center(
                    child: Text('Failed to load tenants: ${state.failure.title}'),
                  );
                } else if (state is TenantLoaded) {
                  var filtered = state.tenants.where((tenant) {
                    final matchesSearch = tenant.name.toLowerCase().contains(_searchQuery);
                    final matchesStatus = _statusFilter == 'All' || tenant.status == _statusFilter;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  // Sort list
                  if (_sortBy == 'Name') {
                    filtered.sort((a, b) => a.name.compareTo(b.name));
                  } else if (_sortBy == 'Room') {
                    filtered.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
                  } else if (_sortBy == 'Rent') {
                    filtered.sort((a, b) => b.rent.compareTo(a.rent));
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No tenants match your search.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tenant = filtered[index];
                      final isActive = tenant.status == 'Active';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            context.push('${MyAppRouteConst.tenantDetail}/${tenant.id}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isActive ? LedgerlyColors.tealSoft : LedgerlyColors.surfaceAltLight,
                                  backgroundImage: tenant.photoUrl.isNotEmpty ? NetworkImage(tenant.photoUrl) : null,
                                  child: tenant.photoUrl.isEmpty
                                      ? Text(
                                          tenant.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: isActive ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tenant.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: LedgerlyColors.navy950,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Room ${tenant.roomNumber} • Floor ${tenant.floor}',
                                        style: const TextStyle(color: LedgerlyColors.inkSoftLight, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${tenant.rent.toStringAsFixed(0)}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: LedgerlyColors.navy900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? LedgerlyColors.tealSoft : LedgerlyColors.surfaceAltLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tenant.status,
                                        style: TextStyle(
                                          color: isActive ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
