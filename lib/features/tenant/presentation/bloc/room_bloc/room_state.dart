part of 'room_bloc.dart';

class RoomState {
  final List<RoomEntity> rooms;
  final String filter;
  final bool loading;
  final String? error;

  const RoomState({
    this.rooms = const [],
    this.filter = 'All',
    this.loading = false,
    this.error,
  });

  List<RoomEntity> get filteredRooms {
    if (filter == 'All') return rooms;

    return rooms
        .where((e) => e.status.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  RoomState copyWith({
    List<RoomEntity>? rooms,
    String? filter,
    bool? loading,
    String? error,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      filter: filter ?? this.filter,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
