import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_manager/features/family/domain/repositories/family_repository.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository familyRepository;
  final UserRepository userRepository;

  FamilyBloc({
    required this.familyRepository,
    required this.userRepository,
  }) : super(FamilyInitial()) {
    on<CreateFamilyEvent>(_onCreateFamily);
  }

  Future<void> _onCreateFamily(
    CreateFamilyEvent event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      emit(FamilyLoading());
      
      final family = await familyRepository.createFamily(event.familyName, event.userId);
      
      // Update the user's profile with the new familyId
      await userRepository.updateUserProfile(
        userId: event.userId,
        familyId: family.familyCode,
      );
      
      emit(FamilyCreatedSuccess(family));
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }
}
