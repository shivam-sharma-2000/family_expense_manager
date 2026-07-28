import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../../../../features/tenant/domain/repositories/tenant_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final TenantRepository repository;
  final ILocalStorageService localStorageService;

  SyncBloc({
    required this.repository,
    required this.localStorageService,
  }) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
  }

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());

    try {
      final result = await repository.syncWithFirebase();
      
      await result.fold(
        (failure) async {
          emit(SyncFailure(error: failure.title));
        },
        (_) async {
          await localStorageService.setHasSyncedOnce(true);
          emit(SyncSuccess());
        },
      );
    } catch (e) {
      emit(SyncFailure(error: 'An unexpected error occurred during sync'));
    }
  }
}
