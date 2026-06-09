import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/family/domain/entity/family_entity.dart';
import 'package:expense_manager/features/family/domain/repositories/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FirebaseFirestore _firestore;

  FamilyRepositoryImpl(this._firestore);

  @override
  Future<Family> createFamily(String familyName, String userId) async {
    try {
      final familyCode = _generateFamilyCode();
      final familyDoc = _firestore.collection('families').doc();
      
      final createdAt = DateTime.now();
      
      final family = Family(
        id: familyDoc.id,
        familyCode: familyCode,
        familyName: familyName,
        createdByUserId: userId,
        createdAt: createdAt,
      );

      await familyDoc.set({
        'id': family.id,
        'familyCode': family.familyCode,
        'familyName': family.familyName,
        'createdByUserId': family.createdByUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return family;
    } catch (e) {
      rethrow;
    }
  }

  String _generateFamilyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
