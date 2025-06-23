class Currency {
  final String code;
  final String flag;
  final String name;
  final double rate;
  final double? change;
  final String? country;
  final DateTime? lastUpdated;

  Currency({
    required this.code,
    required this.flag,
    required this.name,
    required this.rate,
    this.change,
    this.country,
    this.lastUpdated,
  });
}