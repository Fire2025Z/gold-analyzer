class AppConstants {
  static const String apiBaseUrl = 'https://economic-calendar-api.p.rapidapi.com';
  static const String apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual API key
  static const String apiHost = 'economic-calendar-api.p.rapidapi.com';
  
  static const int highImpactWeight = 3;
  static const int mediumImpactWeight = 2;
  static const int lowImpactWeight = 1;
  
  static const List<String> goldAffectingEvents = [
    'Non-Farm Payrolls',
    'CPI',
    'Core CPI',
    'PPI',
    'GDP',
    'FOMC Statement',
    'Federal Reserve Speech',
    'Interest Rate Decision',
    'Unemployment Claims',
    'Retail Sales',
    'Consumer Confidence',
    'Treasury Auction',
    'Fed Chair Speech',
    'Manufacturing PMI',
    'Services PMI',
    'Durable Goods Orders',
    'Trade Balance',
    'Housing Starts',
    'Industrial Production',
    'Michigan Consumer Sentiment',
  ];
  
  static const List<String> bullishKeywords = [
    'weaker', 'lower', 'decrease', 'miss', 'below forecast',
    'rate cut', 'dovish', 'recession', 'inflation drop'
  ];
  
  static const List<String> bearishKeywords = [
    'stronger', 'higher', 'increase', 'beat', 'above forecast',
    'rate hike', 'hawkish', 'growth', 'inflation rise'
  ];
}