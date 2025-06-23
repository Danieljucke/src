
// Beneficiary Model
import 'dart:ui';

class Beneficiary {
  final String id;
  final String name;
  final String initials;
  final String tag;
  final Color tagColor;
  final String bank;
  final String country;
  final String phone;
  final String email;
  final BeneficiaryStatus status;

  Beneficiary({
    required this.id,
    required this.name,
    required this.initials,
    required this.tag,
    required this.tagColor,
    required this.bank,
    required this.country,
    required this.phone,
    required this.email,
    required this.status,
  });
}

enum BeneficiaryStatus {
  active,
  suspended,
  closed,
}