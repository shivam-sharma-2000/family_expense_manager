part of 'tenant_bloc.dart';

abstract class TenantState extends Equatable {
  const TenantState();

  @override
  List<Object> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final List<TenantEntity> tenants;

  const TenantLoaded({required this.tenants});

  @override
  List<Object> get props => [tenants];
}

class TenantError extends TenantState {
  final Failure failure;

  const TenantError({required this.failure});

  @override
  List<Object> get props => [failure];
}
