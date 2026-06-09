import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/expense/data/models/expense_model.dart';
import 'expense_remote_data_source.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore;

  ExpenseRemoteDataSourceImpl({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  @override
  Future<List<ExpenseModel>> getExpenses({String? userId, String? familyId, List<String>? userIds}) async {
    Query query = _firebaseFirestore.collection('transactions');
    
    if (userIds != null && userIds.isNotEmpty) {
      // Split userIds into chunks of 30 if necessary, but assume < 30 for family
      query = query.where('user_id', whereIn: userIds);
    } else if (familyId != null && familyId.isNotEmpty) {
      query = query.where('family_id', isEqualTo: familyId);
    } else if (userId != null && userId.isNotEmpty) {
      query = query.where('user_id', isEqualTo: userId);
    } else {
      return []; // Requires at least one ID
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject document ID
      return ExpenseModel.fromMap(data);
    }).toList();
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    final docRef = await _firebaseFirestore
        .collection('transactions')
        .add(expense.toMap());

    return docRef.id;
  }
}
