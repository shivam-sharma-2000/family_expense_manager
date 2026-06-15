import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/usecases/get_tenant_bills.dart';
import '../../domain/usecases/get_tenant_payments.dart';
import '../../../../core/errors/failure/failure.dart';

part 'tenant_detail_event.dart';
part 'tenant_detail_state.dart';

class TenantDetailBloc extends Bloc<TenantDetailEvent, TenantDetailState> {
  final GetTenantBills getTenantBills;
  final GetTenantPayments getTenantPayments;

  TenantDetailBloc({
    required this.getTenantBills,
    required this.getTenantPayments,
  }) : super(const TenantDetailState()) {
    on<LoadTenantDetailsEvent>(_onLoadTenantDetails);
  }

  Future<void> _onLoadTenantDetails(LoadTenantDetailsEvent event, Emitter<TenantDetailState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    await Future.wait([
      emit.forEach(
        getTenantBills(event.tenantId),
        onData: (result) {
          return result.fold(
            (failure) => state.copyWith(isLoading: false, error: failure),
            (bills) => state.copyWith(isLoading: false, bills: bills),
          );
        },
      ),
      emit.forEach(
        getTenantPayments(event.tenantId),
        onData: (result) {
          return result.fold(
            (failure) => state.copyWith(isLoading: false, error: failure),
            (payments) => state.copyWith(isLoading: false, payments: payments),
          );
        },
      ),
    ]);
  }
}
