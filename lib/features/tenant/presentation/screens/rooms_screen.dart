import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../../../../core/di/injection_container.dart';

import '../../domain/entities/room_entity.dart';
import '../bloc/room_bloc/room_bloc.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<RoomBloc>().add(LoadRooms());
  }

  void _showAddEditRoomDialog([RoomEntity? room]) {
    final isEditing = room != null;

    final numberController = TextEditingController(text: room?.number ?? '');

    final floorController = TextEditingController(text: room?.floor ?? '');

    final capacityController = TextEditingController(
      text: room?.capacity.toString() ?? '1',
    );

    final rentController = TextEditingController(
      text: room?.rent.toString() ?? '',
    );

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
                    decoration: const InputDecoration(labelText: 'Room Number'),

                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: floorController,
                    decoration: const InputDecoration(labelText: 'Floor'),

                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: capacityController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(labelText: 'Capacity'),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: rentController,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(labelText: 'Rent'),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final familyId =
                    await sl<ILocalStorageService>().familyId ?? '';

                final newRoom = RoomEntity(
                  id: room?.id ?? const Uuid().v4(),

                  propertyId: room?.propertyId ?? familyId,

                  number: numberController.text.trim(),

                  floor: floorController.text.trim(),

                  capacity: int.parse(capacityController.text),

                  rent: double.parse(rentController.text),

                  status: room?.status ?? 'Vacant',
                );

                if (isEditing) {
                  context.read<RoomBloc>().add(UpdateRoom(newRoom));
                } else {
                  context.read<RoomBloc>().add(AddRoom(newRoom));
                }

                if (mounted) {
                  context.pop();
                }
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
        const SnackBar(content: Text('Cannot delete occupied room')),
      );

      return;
    }

    final result = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Room'),

          content: Text('Delete Room ${room.number}?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      context.read<RoomBloc>().add(DeleteRoom(room.id));
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
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,

              color: LedgerlyColors.gold,
            ),

            onPressed: () {
              _showAddEditRoomDialog();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          BlocBuilder<RoomBloc, RoomState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: ['All', 'Occupied', 'Vacant'].map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(
                        label: Text(filter),

                        selected: state.filter == filter,

                        onSelected: (value) {
                          if (value) {
                            context.read<RoomBloc>().add(FilterRooms(filter));
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          Expanded(
            child: BlocBuilder<RoomBloc, RoomState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = state.filteredRooms;

                if (rooms.isEmpty) {
                  return const Center(child: Text('No rooms found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: rooms.length,

                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final isOccupied = room.status == 'Occupied';
                    final accentColor = isOccupied
                        ? LedgerlyColors.teal
                        : LedgerlyColors.inkSoftLight;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      // Important
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                          color: LedgerlyColors.borderLight,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(width: 4, color: accentColor),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Room ${room.number}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isOccupied
                                      ? LedgerlyColors.tealSoft
                                      : LedgerlyColors.surfaceAltLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  room.status,
                                  style: GoogleFonts.inter(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Floor: ${room.floor} | Max: ${room.capacity} Pax\n'
                              'Rent: ₹${room.rent.toStringAsFixed(0)}/mo',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit02,
                                  color: LedgerlyColors.gold,
                                ),
                                onPressed: () => _showAddEditRoomDialog(room),
                              ),
                              IconButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete02,
                                  color: LedgerlyColors.coral,
                                ),
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
            ),
          ),
        ],
      ),
    );
  }
}
