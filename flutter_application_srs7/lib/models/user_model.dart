class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.fcmToken,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'fcmToken': fcmToken ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return UserModel(
      id: id,
      fullName: (map['fullName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
      fcmToken: (map['fcmToken'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
