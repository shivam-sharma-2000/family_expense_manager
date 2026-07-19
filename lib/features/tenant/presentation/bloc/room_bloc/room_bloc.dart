import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../domain/entities/room_entity.dart';
import '../../../domain/repositories/tenant_repository.dart';

part 'room_event.dart';

part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final TenantRepository repository;

  RoomBloc({required this.repository}) : super(const RoomState()) {
    on<LoadRooms>(_loadRooms);

    on<AddRoom>(_addRoom);

    on<UpdateRoom>(_updateRoom);

    on<DeleteRoom>(_deleteRoom);

    on<FilterRooms>((event, emit) {
      emit(state.copyWith(filter: event.status));
    });
  }

  Future<void> _loadRooms(LoadRooms event, Emitter<RoomState> emit) async {
    emit(state.copyWith(loading: true));

    await emit.forEach<Either<dynamic, List<RoomEntity>>>(
      repository.getRooms(),

      onData: (result) {
        return result.fold(
          (failure) {
            return state.copyWith(loading: false, error: failure.toString());
          },

          (rooms) {
            return state.copyWith(rooms: rooms, loading: false);
          },
        );
      },
    );
  }

  Future<void> _addRoom(AddRoom event, Emitter<RoomState> emit) async {
    await repository.addRoom(event.room);
  }

  Future<void> _updateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    await repository.updateRoom(event.room);
  }

  Future<void> _deleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    await repository.deleteRoom(event.roomId);
  }
}
