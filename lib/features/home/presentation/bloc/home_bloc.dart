import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/tenant/domain/repositories/tenant_repository.dart';
import '../../../../features/tenant/domain/entities/tenant_entity.dart';
import '../../../../features/tenant/domain/entities/room_entity.dart';
import '../../../../features/tenant/domain/entities/tenant_bill_entity.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TenantRepository repository;
  
  StreamSubscription? _tenantsSubscription;
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _billsSubscription;

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<DashboardUpdated>(_onDashboardUpdated);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    // Cancel existing subscriptions if any
    await _cancelSubscriptions();

    // Listen to all three streams
    _tenantsSubscription = repository.getTenants().listen(
      (result) {
        result.fold(
          (failure) => add(DashboardUpdated(
            tenants: state.tenants,
            rooms: state.rooms,
            bills: state.bills,
            isLoading: false,
            error: failure.title,
          )),
          (tenants) => add(DashboardUpdated(
            tenants: tenants,
            rooms: state.rooms,
            bills: state.bills,
            isLoading: false,
          )),
        );
      },
      onError: (e) {
        add(DashboardUpdated(
          tenants: state.tenants,
          rooms: state.rooms,
          bills: state.bills,
          isLoading: false,
          error: e.toString(),
        ));
      }
    );

    _roomsSubscription = repository.getRooms().listen(
      (result) {
        result.fold(
          (failure) => add(DashboardUpdated(
            tenants: state.tenants,
            rooms: state.rooms,
            bills: state.bills,
            isLoading: false,
            error: failure.title,
          )),
          (rooms) => add(DashboardUpdated(
            tenants: state.tenants,
            rooms: rooms,
            bills: state.bills,
            isLoading: false,
          )),
        );
      },
      onError: (e) {
        add(DashboardUpdated(
          tenants: state.tenants,
          rooms: state.rooms,
          bills: state.bills,
          isLoading: false,
          error: e.toString(),
        ));
      }
    );

    _billsSubscription = repository.getAllBills().listen(
      (result) {
        result.fold(
          (failure) => add(DashboardUpdated(
            tenants: state.tenants,
            rooms: state.rooms,
            bills: state.bills,
            isLoading: false,
            error: failure.title,
          )),
          (bills) => add(DashboardUpdated(
            tenants: state.tenants,
            rooms: state.rooms,
            bills: bills,
            isLoading: false,
          )),
        );
      },
      onError: (e) {
        add(DashboardUpdated(
          tenants: state.tenants,
          rooms: state.rooms,
          bills: state.bills,
          isLoading: false,
          error: e.toString(),
        ));
      }
    );
  }

  void _onDashboardUpdated(DashboardUpdated event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      tenants: event.tenants,
      rooms: event.rooms,
      bills: event.bills,
      isLoading: event.isLoading,
      error: event.error,
    ));
  }

  Future<void> _cancelSubscriptions() async {
    await _tenantsSubscription?.cancel();
    await _roomsSubscription?.cancel();
    await _billsSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
