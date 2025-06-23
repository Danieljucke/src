import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/domain/repositories/taux_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  
  static String get apiKey => dotenv.env['CURRENCY_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.currencyapi.com/v3/latest';

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(
      Uri.parse('$baseUrl?apikey=$apiKey&base_currency=$baseCurrency'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['data'] as Map<String, dynamic>;
      
      return rates.map((key, value) => MapEntry(
        key, 
        (value['value'] as num).toDouble()
      ));
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}