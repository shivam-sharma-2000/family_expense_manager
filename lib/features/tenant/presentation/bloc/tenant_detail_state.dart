part of 'tenant_detail_bloc.dart';

class TenantDetailState extends Equatable {
  final bool isLoading;
  final List<TenantBillEntity> bills;
  final List<TenantPaymentEntity> payments;
  final Failure? error;

  const TenantDetailState({
    this.isLoading = false,
    this.bills = const [],
    this.payments = const [],
    this.error,
  });

  TenantDetailState copyWith({
    bool? isLoading,
    List<TenantBillEntity>? bills,
    List<TenantPaymentEntity>? payments,
    Failure? error,
  }) {
    return TenantDetailState(
      isLoading: isLoading ?? this.isLoading,
      bills: bills ?? this.bills,
      payments: payments ?? this.payments,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, bills, payments, error];
}
