part of 'room_bloc.dart';

abstract class RoomEvent {}

class LoadRooms extends RoomEvent {}

class AddRoom extends RoomEvent {
  final RoomEntity room;

  AddRoom(this.room);
}

class UpdateRoom extends RoomEvent {
  final RoomEntity room;

  UpdateRoom(this.room);
}

class DeleteRoom extends RoomEvent {
  final String roomId;

  DeleteRoom(this.roomId);
}

class FilterRooms extends RoomEvent {
  final String status;

  FilterRooms(this.status);
}
