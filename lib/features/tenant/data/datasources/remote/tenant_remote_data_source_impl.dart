import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';
import '../../models/room_model.dart';
import '../../models/electricity_reading_model.dart';
import '../../models/property_model.dart';
import 'tenant_remote_data_source.dart';

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final FirebaseFirestore firestore;

  TenantRemoteDataSourceImpl({required this.firestore});

  // Properties
  @override
  Stream<PropertyModel?> getPropertyStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value(null);
    return firestore.collection('properties').doc(propertyId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PropertyModel.fromMap(doc.id, doc.data()!);
    });
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    await firestore.collection('properties').doc(property.id).set(property.toMap(), SetOptions(merge: true));
  }

  // Tenants
  @override
  Stream<List<TenantModel>> getTenantsStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value([]);
    return firestore
        .collection('tenants')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> addTenant(TenantModel tenant) async {
    final batch = firestore.batch();
    final tenantRef = firestore.collection('tenants').doc(tenant.id);
    batch.set(tenantRef, tenant.toMap());

    // Sync room status: Find corresponding room and set Occupied
    final roomsQuery = await firestore
        .collection('rooms')
        .where('propertyId', isEqualTo: tenant.propertyId)
        .where('number', isEqualTo: tenant.roomNumber)
        .get();

    if (roomsQuery.docs.isNotEmpty) {
      final roomDoc = roomsQuery.docs.first;
      batch.update(roomDoc.reference, {'status': tenant.status == 'Active' ? 'Occupied' : 'Vacant'});
    } else {
      // Room doesn't exist, create it auto
      final roomRef = firestore.collection('rooms').doc();
      batch.set(roomRef, {
        'propertyId': tenant.propertyId,
        'number': tenant.roomNumber,
        'floor': tenant.floor,
        'capacity': 1,
        'rent': tenant.rent,
        'status': tenant.status == 'Active' ? 'Occupied' : 'Vacant',
      });
    }

    // Auto initialize electricity reading record if active
    if (tenant.status == 'Active') {
      final elecRef = firestore.collection('electricityReadings').doc(tenant.id);
      batch.set(elecRef, {
        'propertyId': tenant.propertyId,
        'previousReading': 0.0,
        'currentReading': 0.0,
        'ratePerUnit': 10.0,
        'unitsUsed': 0.0,
        'currentCharge': 0.0,
        'lastUpdated': Timestamp.now(),
        'history': [],
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> updateTenant(TenantModel tenant) async {
    final batch = firestore.batch();
    final tenantRef = firestore.collection('tenants').doc(tenant.id);
    batch.set(tenantRef, tenant.toMap(), SetOptions(merge: true));

    // Update room status
    final roomsQuery = await firestore
        .collection('rooms')
        .where('propertyId', isEqualTo: tenant.propertyId)
        .where('number', isEqualTo: tenant.roomNumber)
        .get();

    if (roomsQuery.docs.isNotEmpty) {
      final roomDoc = roomsQuery.docs.first;
      batch.update(roomDoc.reference, {'status': tenant.status == 'Active' ? 'Occupied' : 'Vacant'});
    }

    await batch.commit();
  }

  @override
  Future<void> deleteTenant(String tenantId) async {
    // Check if room has active tenant reference
    final doc = await firestore.collection('tenants').doc(tenantId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final propertyId = data['propertyId'] as String? ?? '';
    final roomNumber = data['roomNumber'] as String? ?? '';

    final batch = firestore.batch();
    batch.delete(doc.reference);

    // Free the room status
    if (propertyId.isNotEmpty && roomNumber.isNotEmpty) {
      final roomsQuery = await firestore
          .collection('rooms')
          .where('propertyId', isEqualTo: propertyId)
          .where('number', isEqualTo: roomNumber)
          .get();
      if (roomsQuery.docs.isNotEmpty) {
        batch.update(roomsQuery.docs.first.reference, {'status': 'Vacant'});
      }
    }

    // Clean up electricity readings
    batch.delete(firestore.collection('electricityReadings').doc(tenantId));

    await batch.commit();
  }

  // Rooms
  @override
  Stream<List<RoomModel>> getRoomsStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value([]);
    return firestore
        .collection('rooms')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RoomModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> addRoom(RoomModel room) async {
    await firestore.collection('rooms').doc(room.id).set(room.toMap());
  }

  @override
  Future<void> updateRoom(RoomModel room) async {
    await firestore.collection('rooms').doc(room.id).set(room.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    await firestore.collection('rooms').doc(roomId).delete();
  }

  // Electricity
  @override
  Stream<List<ElectricityReadingModel>> getElectricityReadingsStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value([]);
    return firestore
        .collection('electricityReadings')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ElectricityReadingModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> updateElectricityReading(ElectricityReadingModel reading) async {
    await firestore.collection('electricityReadings').doc(reading.tenantId).set(reading.toMap(), SetOptions(merge: true));
  }

  // Bills
  @override
  Stream<List<TenantBillModel>> getBillsStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value([]);
    return firestore
        .collection('bills')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantBillModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<TenantBillModel>> getTenantBillsStream(String tenantId) {
    if (tenantId.isEmpty) return Stream.value([]);
    return firestore
        .collection('bills')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantBillModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> addBill(TenantBillModel bill) async {
    await firestore.collection('bills').doc(bill.id).set(bill.toMap());
  }

  @override
  Future<void> updateBill(TenantBillModel bill) async {
    await firestore.collection('bills').doc(bill.id).set(bill.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBill(String billId) async {
    await firestore.collection('bills').doc(billId).delete();
  }

  // Payments
  @override
  Stream<List<TenantPaymentModel>> getPaymentsStream(String propertyId) {
    if (propertyId.isEmpty) return Stream.value([]);
    return firestore
        .collection('payments')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantPaymentModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<TenantPaymentModel>> getTenantPaymentsStream(String tenantId) {
    if (tenantId.isEmpty) return Stream.value([]);
    return firestore
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantPaymentModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> addPayment(TenantPaymentModel payment) async {
    // Firestore transaction to atomically update payment AND recalculate bill status/due
    await firestore.runTransaction((transaction) async {
      final billRef = firestore.collection('bills').doc(payment.billId);
      final billDoc = await transaction.get(billRef);

      if (billDoc.exists && billDoc.data() != null) {
        final billData = billDoc.data()!;
        final double total = (billData['total'] as num? ?? 0.0).toDouble();
        
        // Find existing payments for this bill to calculate total paid so far
        final paymentsSnapshot = await firestore
            .collection('payments')
            .where('billId', isEqualTo: payment.billId)
            .get();

        double totalPaid = payment.amount;
        for (var pDoc in paymentsSnapshot.docs) {
          totalPaid += (pDoc.data()['amount'] as num? ?? 0.0).toDouble();
        }

        String newStatus = 'Unpaid';
        if (totalPaid >= total) {
          newStatus = 'Paid';
        } else if (totalPaid > 0) {
          newStatus = 'Partially Paid';
        }

        transaction.update(billRef, {
          'status': newStatus,
          'updatedAt': Timestamp.now(),
        });
      }

      final paymentRef = firestore.collection('payments').doc(payment.id);
      transaction.set(paymentRef, payment.toMap());
    });
  }
}
