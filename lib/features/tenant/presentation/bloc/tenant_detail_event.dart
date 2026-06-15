part of 'tenant_detail_bloc.dart';

abstract class TenantDetailEvent extends Equatable {
  const TenantDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadTenantDetailsEvent extends TenantDetailEvent {
  final String tenantId;

  const LoadTenantDetailsEvent({required this.tenantId});

  @override
  List<Object> get props => [tenantId];
}
