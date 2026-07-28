import 'package:equatable/equatable.dart';
import '../../../../features/tenant/domain/entities/tenant_entity.dart';
import '../../../../features/tenant/domain/entities/room_entity.dart';
import '../../../../features/tenant/domain/entities/tenant_bill_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends HomeEvent {}

class DashboardUpdated extends HomeEvent {
  final List<TenantEntity> tenants;
  final List<RoomEntity> rooms;
  final List<TenantBillEntity> bills;
  final bool isLoading;
  final String? error;

  const DashboardUpdated({
    required this.tenants,
    required this.rooms,
    required this.bills,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [tenants, rooms, bills, isLoading, error];
}
