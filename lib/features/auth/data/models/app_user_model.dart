import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.age,
    required super.role,
    super.profileCompleted,
    super.paymentFrequency,
    super.paymentAmount,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      role: json['role'] as String? ?? 'usuario',
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      paymentFrequency: json['paymentFrequency'] as String?,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'age': age,
    'role': role,
    'profileCompleted': profileCompleted,
    'paymentFrequency': paymentFrequency,
    'paymentAmount': paymentAmount,
  };
}