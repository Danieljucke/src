import 'package:get/get.dart';
//import '';
import '../../domain/repositories/taux_repository.dart';

class ExchangeController extends GetxController {
  final CurrencyRepository repository;

  ExchangeController(this.repository);

  var isLoading = false.obs;
  var lastUpdated = DateTime.now().obs;
  var baseCurrency = 'MAD'.obs;
  var targetCurrency = 'XOF'.obs;
  var exchangeRate = 0.0.obs;
  var sendAmount = 1000.0.obs;
  var receiveAmount = 0.0.obs;
  var allRates = <String, double>{}.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    try {
      isLoading(true);
      errorMessage('');
      final rates = await repository.getExchangeRates(baseCurrency.value);
      allRates.assignAll(rates);
      updateExchangeRate();
      lastUpdated.value = DateTime.now();
    } catch (e) {
      errorMessage.value = 'Failed to fetch rates: ${e.toString()}';
    } finally {
      isLoading(false);
    }
  }

  void updateExchangeRate() {
    if (allRates.containsKey(targetCurrency.value)) {
      exchangeRate.value = allRates[targetCurrency.value]!;
      calculateReceiveAmount();
    }
  }

  void calculateReceiveAmount() {
    receiveAmount.value = sendAmount.value * exchangeRate.value;
  }

  void updateSendAmount(double amount) {
    sendAmount.value = amount;
    calculateReceiveAmount();
  }

  void changeTargetCurrency(String currencyCode) {
    targetCurrency.value = currencyCode;
    updateExchangeRate();
  }

  void swapCurrencies() {
    final temp = targetCurrency.value;
    targetCurrency.value = baseCurrency.value;
    baseCurrency.value = temp;
    
    // Inverser le taux de change
    exchangeRate.value = 1 / exchangeRate.value;
    calculateReceiveAmount();
    
    fetchExchangeRates();
  }
}