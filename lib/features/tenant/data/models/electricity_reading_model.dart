import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/electricity_reading_entity.dart';

class ElectricityReadingModel extends ElectricityReadingEntity {
  const ElectricityReadingModel({
    required super.tenantId,
    required super.propertyId,
    required super.previousReading,
    required super.currentReading,
    required super.ratePerUnit,
    required super.unitsUsed,
    required super.currentCharge,
    required super.lastUpdated,
    required super.history,
  });

  factory ElectricityReadingModel.fromMap(String tenantId, Map<String, dynamic> map) {
    final historyList = map['history'] as List<dynamic>? ?? [];
    final history = historyList.map((e) {
      final entryMap = e as Map<String, dynamic>;
      return ElectricityHistoryEntry(
        date: entryMap['date'] is Timestamp
            ? (entryMap['date'] as Timestamp).toDate()
            : entryMap['date'] is num
                ? DateTime.fromMillisecondsSinceEpoch((entryMap['date'] as num).toInt())
                : DateTime.now(),
        previousReading: (entryMap['previousReading'] as num? ?? 0.0).toDouble(),
        currentReading: (entryMap['currentReading'] as num? ?? 0.0).toDouble(),
        unitsUsed: (entryMap['unitsUsed'] as num? ?? 0.0).toDouble(),
        ratePerUnit: (entryMap['ratePerUnit'] as num? ?? 0.0).toDouble(),
        charge: (entryMap['charge'] as num? ?? 0.0).toDouble(),
      );
    }).toList();

    return ElectricityReadingModel(
      tenantId: tenantId,
      propertyId: map['propertyId'] as String? ?? '',
      previousReading: (map['previousReading'] as num? ?? 0.0).toDouble(),
      currentReading: (map['currentReading'] as num? ?? 0.0).toDouble(),
      ratePerUnit: (map['ratePerUnit'] as num? ?? 0.0).toDouble(),
      unitsUsed: (map['unitsUsed'] as num? ?? 0.0).toDouble(),
      currentCharge: (map['currentCharge'] as num? ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : map['lastUpdated'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['lastUpdated'] as num).toInt())
              : DateTime.now(),
      history: history,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'ratePerUnit': ratePerUnit,
      'unitsUsed': unitsUsed,
      'currentCharge': currentCharge,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'history': history.map((e) => {
            'date': Timestamp.fromDate(e.date),
            'previousReading': e.previousReading,
            'currentReading': e.currentReading,
            'unitsUsed': e.unitsUsed,
            'ratePerUnit': e.ratePerUnit,
            'charge': e.charge,
          }).toList(),
    };
  }

  factory ElectricityReadingModel.fromEntity(ElectricityReadingEntity entity) {
    return ElectricityReadingModel(
      tenantId: entity.tenantId,
      propertyId: entity.propertyId,
      previousReading: entity.previousReading,
      currentReading: entity.currentReading,
      ratePerUnit: entity.ratePerUnit,
      unitsUsed: entity.unitsUsed,
      currentCharge: entity.currentCharge,
      lastUpdated: entity.lastUpdated,
      history: entity.history,
    );
  }
}
