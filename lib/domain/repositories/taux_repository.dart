//import 'package:mobile/domain/entities/currency_entity.dart';

abstract class CurrencyRepository {
  Future<Map<String, double>> getExchangeRates(String baseCurrency);
}