import 'package:equatable/equatable.dart';

class ElectricityHistoryEntry extends Equatable {
  final DateTime date;
  final double previousReading;
  final double currentReading;
  final double unitsUsed;
  final double ratePerUnit;
  final double charge;

  const ElectricityHistoryEntry({
    required this.date,
    required this.previousReading,
    required this.currentReading,
    required this.unitsUsed,
    required this.ratePerUnit,
    required this.charge,
  });

  @override
  List<Object?> get props => [
        date,
        previousReading,
        currentReading,
        unitsUsed,
        ratePerUnit,
        charge,
      ];
}

class ElectricityReadingEntity extends Equatable {
  final String tenantId;
  final String propertyId;
  final double previousReading;
  final double currentReading;
  final double ratePerUnit;
  final double unitsUsed;
  final double currentCharge;
  final DateTime lastUpdated;
  final List<ElectricityHistoryEntry> history;

  const ElectricityReadingEntity({
    required this.tenantId,
    required this.propertyId,
    required this.previousReading,
    required this.currentReading,
    required this.ratePerUnit,
    required this.unitsUsed,
    required this.currentCharge,
    required this.lastUpdated,
    required this.history,
  });

  @override
  List<Object?> get props => [
        tenantId,
        propertyId,
        previousReading,
        currentReading,
        ratePerUnit,
        unitsUsed,
        currentCharge,
        lastUpdated,
        history,
      ];

  ElectricityReadingEntity copyWith({
    String? tenantId,
    String? propertyId,
    double? previousReading,
    double? currentReading,
    double? ratePerUnit,
    double? unitsUsed,
    double? currentCharge,
    DateTime? lastUpdated,
    List<ElectricityHistoryEntry>? history,
  }) {
    return ElectricityReadingEntity(
      tenantId: tenantId ?? this.tenantId,
      propertyId: propertyId ?? this.propertyId,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      unitsUsed: unitsUsed ?? this.unitsUsed,
      currentCharge: currentCharge ?? this.currentCharge,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      history: history ?? this.history,
    );
  }
}
