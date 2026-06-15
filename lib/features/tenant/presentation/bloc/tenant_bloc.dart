import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/usecases/get_tenants.dart';
import '../../../../core/errors/failure/failure.dart';

part 'tenant_event.dart';
part 'tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final GetTenants getTenants;

  TenantBloc({required this.getTenants}) : super(TenantInitial()) {
    on<LoadTenantsEvent>(_onLoadTenants);
  }

  Future<void> _onLoadTenants(LoadTenantsEvent event, Emitter<TenantState> emit) async {
    emit(TenantLoading());
    await emit.forEach(
      getTenants(),
      onData: (result) {
        return result.fold(
          (failure) => TenantError(failure: failure),
          (tenants) => TenantLoaded(tenants: tenants),
        );
      },
      onError: (error, stackTrace) => const TenantError(failure: UnexpectedFailure()),
    );
  }
}
