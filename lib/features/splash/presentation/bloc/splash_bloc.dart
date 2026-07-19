import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../../../../core/service/impl/auth_service_impl.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onStarted);
  }

  final AuthService _authService = sl<AuthServiceImpl>();
  final ILocalStorageService _local = sl<ILocalStorageService>();

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    final role = await _authService.currentRole;
    final isLandingComp = await _local.isOnBoardingComplete ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (!isLandingComp) {
      emit(SplashNavigate(MyAppRouteConst.onboarding));
      return;
    }

    switch (role) {
      case UserRole.authenticated:
        // final uid = await _local.userId ?? '';
        //
        // if (uid.isNotEmpty) {
        //   final user = await UserService().getUser(uid);
        //
        //   if (user != null && user.familyId.isNotEmpty) {
        //     await _local.setFamilyId(user.familyId);
        //   }
        // }
        final hasSynced = await _local.hasSyncedOnce;

        emit(
          SplashNavigate(
            hasSynced ? MyAppRouteConst.home : MyAppRouteConst.sync,
          ),
        );
        break;

      case UserRole.unauthenticated:
      case UserRole.unknown:
        emit(SplashNavigate(MyAppRouteConst.login));
        break;
    }
  }
}
