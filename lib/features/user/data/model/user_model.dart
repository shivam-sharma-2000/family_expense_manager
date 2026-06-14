class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final double totalExpense;
  final double totalEarning;
  final String familyId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.totalExpense = 0.0,
    this.totalEarning = 0.0,
    required this.familyId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'totalExpense': totalExpense,
      'totalEarning': totalEarning,
      'familyId': familyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      totalExpense: (map['totalExpense'] ?? 0.0).toDouble(),
      totalEarning: (map['totalEarning'] ?? 0.0).toDouble(),
      familyId: map['familyId'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    double? totalExpense,
    double? totalEarning,
    String? familyId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalExpense: totalExpense ?? this.totalExpense,
      totalEarning: totalEarning ?? this.totalEarning,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
