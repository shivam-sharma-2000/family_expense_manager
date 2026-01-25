import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/expense/data/models/expense_model.dart';
import 'expense_remote_data_source.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore;

  ExpenseRemoteDataSourceImpl({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final snapshot = await _firebaseFirestore.collection('transactions').get();
    return snapshot.docs.map((doc) {
      return ExpenseModel.fromMap(doc.data());
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
