import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';
import 'tenant_remote_data_source.dart';

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final FirebaseFirestore firestore;

  TenantRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> syncTenants(List<TenantModel> tenants, String familyId, String userId) async {
    final batch = firestore.batch();
    for (var tenant in tenants) {
      final docRef = firestore.collection('tenants').doc(tenant.id);
      if (tenant.isDeleted) {
        batch.delete(docRef);
      } else {
        batch.set(docRef, tenant.toMap());
      }
    }
    await batch.commit();
  }

  @override
  Future<void> syncTenantBills(List<TenantBillModel> bills, String familyId, String userId) async {
    final batch = firestore.batch();
    for (var bill in bills) {
      final docRef = firestore.collection('tenant_bills').doc(bill.id);
      if (bill.isDeleted) {
        batch.delete(docRef);
      } else {
        batch.set(docRef, bill.toMap());
      }
    }
    await batch.commit();
  }

  @override
  Future<void> syncTenantPayments(List<TenantPaymentModel> payments, String familyId, String userId) async {
    final batch = firestore.batch();
    for (var payment in payments) {
      final docRef = firestore.collection('tenant_payments').doc(payment.id);
      if (payment.isDeleted) {
        batch.delete(docRef);
      } else {
        batch.set(docRef, payment.toMap());
      }
    }
    await batch.commit();
  }

  @override
  Future<List<TenantModel>> getTenants(String familyId, String userId) async {
    Query query = firestore.collection('tenants');
    if (familyId.isNotEmpty && userId.isNotEmpty) {
      query = query.where(Filter.or(Filter('family_id', isEqualTo: familyId), Filter('user_id', isEqualTo: userId)));
    } else if (familyId.isNotEmpty) {
      query = query.where('family_id', isEqualTo: familyId);
    } else if (userId.isNotEmpty) {
      query = query.where('user_id', isEqualTo: userId);
    } else {
      return [];
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TenantModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TenantBillModel>> getTenantBills(String familyId, String userId) async {
    Query query = firestore.collection('tenant_bills');
    if (familyId.isNotEmpty && userId.isNotEmpty) {
      query = query.where(Filter.or(Filter('family_id', isEqualTo: familyId), Filter('user_id', isEqualTo: userId)));
    } else if (familyId.isNotEmpty) {
      query = query.where('family_id', isEqualTo: familyId);
    } else if (userId.isNotEmpty) {
      query = query.where('user_id', isEqualTo: userId);
    } else {
      return [];
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TenantBillModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TenantPaymentModel>> getTenantPayments(String familyId, String userId) async {
    Query query = firestore.collection('tenant_payments');
    if (familyId.isNotEmpty && userId.isNotEmpty) {
      query = query.where(Filter.or(Filter('family_id', isEqualTo: familyId), Filter('user_id', isEqualTo: userId)));
    } else if (familyId.isNotEmpty) {
      query = query.where('family_id', isEqualTo: familyId);
    } else if (userId.isNotEmpty) {
      query = query.where('user_id', isEqualTo: userId);
    } else {
      return [];
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TenantPaymentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
