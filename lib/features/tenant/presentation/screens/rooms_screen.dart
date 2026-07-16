import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../../../../core/service/i_local_storage_service.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String _statusFilter = 'All'; // All | Occupied | Vacant
  final _repository = sl<TenantRepository>();

  void _showAddEditRoomDialog([RoomEntity? room]) {
    final isEditing = room != null;
    final numberController = TextEditingController(text: room?.number ?? '');
    final floorController = TextEditingController(text: room?.floor ?? '');
    final capacityController = TextEditingController(text: room?.capacity.toString() ?? '1');
    final rentController = TextEditingController(text: room?.rent.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Room' : 'Add Room'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'Room Number (e.g. 101)'),
                    validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: floorController,
                    decoration: const InputDecoration(labelText: 'Floor (e.g. 1st Floor)'),
                    validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Capacity (persons)'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Standard Rent (₹)'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Enter valid rate';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: LedgerlyColors.inkSoftLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LedgerlyColors.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final pId = await sl<ILocalStorageService>().familyId ?? '';
                final newRoom = RoomEntity(
                  id: room?.id ?? const Uuid().v4(),
                  propertyId: room?.propertyId ?? pId,
                  number: numberController.text.trim(),
                  floor: floorController.text.trim(),
                  capacity: int.parse(capacityController.text),
                  rent: double.parse(rentController.text),
                  status: room?.status ?? 'Vacant',
                );

                if (isEditing) {
                  await _repository.updateRoom(newRoom);
                } else {
                  await _repository.addRoom(newRoom);
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRoom(RoomEntity room) async {
    if (room.status == 'Occupied') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete an occupied room.'),
          backgroundColor: LedgerlyColors.coral,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete Room ${room.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LedgerlyColors.coral),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteRoom(room.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rooms Manager'),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: LedgerlyColors.gold),
            onPressed: () => _showAddEditRoomDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Occupied', 'Vacant'].map((filter) {
                final isSelected = _statusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: LedgerlyColors.goldSoft,
                    labelStyle: TextStyle(
                      color: isSelected ? LedgerlyColors.gold : LedgerlyColors.inkSoftLight,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _statusFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Rooms List
          Expanded(
            child: StreamBuilder(
              stream: _repository.getRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No rooms found.'));
                }

                final either = snapshot.data as fp.Either<dynamic, List<RoomEntity>>;
                return either.fold(
                  (fail) => const Center(child: Text('Failed to load rooms.')),
                  (rooms) {
                    final filteredRooms = rooms.where((room) {
                      if (_statusFilter == 'All') return true;
                      return room.status.toLowerCase() == _statusFilter.toLowerCase();
                    }).toList();

                    if (filteredRooms.isEmpty) {
                      return const Center(child: Text('No matching rooms.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        final isOccupied = room.status == 'Occupied';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: LedgerlyColors.borderLight),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 4,
                                  color: isOccupied ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                children: [
                                  Text(
                                    'Room ${room.number}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOccupied ? LedgerlyColors.tealSoft : LedgerlyColors.surfaceAltLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      room.status,
                                      style: GoogleFonts.inter(
                                        color: isOccupied ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Floor: ${room.floor} | Max: ${room.capacity} Pax\nRent: ₹${room.rent.toStringAsFixed(0)}/mo',
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: LedgerlyColors.gold),
                                    onPressed: () => _showAddEditRoomDialog(room),
                                  ),
                                  IconButton(
                                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: LedgerlyColors.coral),
                                    onPressed: () => _deleteRoom(room),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
