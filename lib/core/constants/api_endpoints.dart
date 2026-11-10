class ApiEndpoints {
  // Production Base URL
  static const String prodBaseUrl = 'https://idxfalcon.sytes.net/digipay';

  // Local / Dev Fallbacks
  static const String defaultLocalBaseUrl = 'http://localhost:3000';
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:3000';

  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String setupPin = '/api/v1/auth/pin/setup';
  static const String verifyPin = '/api/v1/auth/pin/verify';

  // User & Balance
  static const String balance = '/api/v1/balance';
  static const String profile = '/api/v1/users';

  // Beneficiaries & Banks
  static const String banks = '/api/v1/banks';
  static const String checkAccount = '/api/v1/beneficiaries/check';
  static const String beneficiaries = '/api/v1/beneficiaries';

  // Transfers & Transactions
  static const String transfers = '/api/v1/transfers';
  static const String topup = '/api/v1/transactions/topup';
  static const String history = '/api/v1/transfers';
}
