import 'package:expense_manager/features/family/domain/entity/family_entity.dart';

abstract class FamilyRepository {
  Future<Family> createFamily(String familyName, String userId);
}
