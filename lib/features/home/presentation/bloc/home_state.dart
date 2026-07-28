import 'package:equatable/equatable.dart';
import '../../../../features/tenant/domain/entities/tenant_entity.dart';
import '../../../../features/tenant/domain/entities/room_entity.dart';
import '../../../../features/tenant/domain/entities/tenant_bill_entity.dart';

class HomeState extends Equatable {
  final List<TenantEntity> tenants;
  final List<RoomEntity> rooms;
  final List<TenantBillEntity> bills;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.tenants = const [],
    this.rooms = const [],
    this.bills = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<TenantEntity>? tenants,
    List<RoomEntity>? rooms,
    List<TenantBillEntity>? bills,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      tenants: tenants ?? this.tenants,
      rooms: rooms ?? this.rooms,
      bills: bills ?? this.bills,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [tenants, rooms, bills, isLoading, error];
}
