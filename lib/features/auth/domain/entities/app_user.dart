import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final int? age;
  final String role;
  final bool profileCompleted;
  final String? paymentFrequency;
  final double? paymentAmount;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.age,
    required this.role,
    this.profileCompleted = false,
    this.paymentFrequency,
    this.paymentAmount,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        age,
        role,
        profileCompleted,
        paymentFrequency,
        paymentAmount,
      ];
}