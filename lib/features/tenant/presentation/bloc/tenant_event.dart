part of 'tenant_bloc.dart';

abstract class TenantEvent extends Equatable {
  const TenantEvent();

  @override
  List<Object> get props => [];
}

class LoadTenantsEvent extends TenantEvent {}
