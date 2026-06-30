class AppConstants {
  static const String appName = 'BadWallet';
  //static const String baseUrl = 'http://10.0.2.2:8080'; // Pour émulateur Android
  // static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'http://192.168.1.24:8080';
  // static const String baseUrl = 'http://localhost:8080'; // Pour iOS ou physique
  
  static const String apiWallets = '$baseUrl/api/wallets';
  static const String apiExternal = '$baseUrl/api/external';
  
  static const String storageKeyPhone = 'user_phone';
  static const String storageKeyToken = 'auth_token';
  
  static const List<String> serviceProviders = [
    'ISM',
    'WOYAFAL',
    'SENELEC',
    'SONATEL',
    'RAPIDO',
    'ORANGE_MONEY',
    'WAVE'
  ];
}