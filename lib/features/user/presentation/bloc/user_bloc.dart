import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'package:expense_manager/features/user/domain/entities/user_entity.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_event.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  
  // Keep track of subscriptions
  StreamSubscription<UserEntity?>? _userSubscription;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUser(
    LoadUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      
      // Cancel any existing subscription
      await _userSubscription?.cancel();
      
      // Set up new subscription
      _userSubscription = userRepository.userDataChanges(event.userId).listen(
        (user) {
          if (user != null) {
            add(UserProfileUpdatedEvent(user));
          } else {
            add(UserErrorEvent('User not found'));
          }
        },
        onError: (error) => add(UserErrorEvent(error.toString())),
      );
      
      // Initial load
      final user = await userRepository.getUser(event.userId);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('User not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      await userRepository.updateUserProfile(
        userId: event.userId,
        name: event.name,
        photoUrl: event.photoUrl,
      );
      // The stream will automatically update the state
    } catch (e) {
      emit(UserError(e.toString()));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

// Additional event for when user data is updated via stream
class UserProfileUpdatedEvent extends UserEvent {
  final UserEntity user;

  const UserProfileUpdatedEvent(this.user);

  @override
  List<Object?> get props => [user];
}
