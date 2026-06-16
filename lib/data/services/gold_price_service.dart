// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final goldPriceServiceProvider = Provider((ref) => GoldPriceService());

// class GoldPriceService {
//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 10),
//     receiveTimeout: const Duration(seconds: 10),
//   ));
  
//   // Your Twelve Data API key
//   final String _twelveDataApiKey = '2fa1507bcb684b849020b306442fa88d';
  
//   double? _cachedPrice;
//   DateTime? _lastFetchTime;
//   final Duration _cacheDuration = const Duration(seconds: 30);
  
//   Future<double> getCurrentGoldPrice() async {
//     // Return cached price if still valid
//     if (_cachedPrice != null && _lastFetchTime != null) {
//       if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
//         return _cachedPrice!;
//       }
//     }
    
//     // Try Twelve Data API first (most reliable)
//     double? price = await _fetchFromTwelveData();
//     if (price != null && price > 0) {
//       _cachedPrice = price;
//       _lastFetchTime = DateTime.now();
//       return price;
//     }
    
//     // Fallback to other free APIs
//     price = await _fetchFromGOLDAPI();
//     if (price != null && price > 0) {
//       _cachedPrice = price;
//       _lastFetchTime = DateTime.now();
//       return price;
//     }
    
//     price = await _fetchFromExchangeRateAPI();
//     if (price != null && price > 0) {
//       _cachedPrice = price;
//       _lastFetchTime = DateTime.now();
//       return price;
//     }
    
//     // Return cached price or current market price
//     return _cachedPrice ?? 4346.80;
//   }
  
//   // Twelve Data API - Using your API key
//   Future<double?> _fetchFromTwelveData() async {
//     try {
//       final response = await _dio.get(
//         'https://api.twelvedata.com/price',
//         queryParameters: {
//           'symbol': 'XAU/USD',
//           'apikey': _twelveDataApiKey,
//         },
//       );
      
//       if (response.statusCode == 200 && response.data != null) {
//         final price = double.tryParse(response.data['price']?.toString() ?? '');
//         if (price != null && price > 4000 && price < 5000) {
//           print('Twelve Data API Price: \$ $price');
//           return price;
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Twelve Data API Error: $e');
//       return null;
//     }
//   }
  
//   // Backup API 1
//   Future<double?> _fetchFromGOLDAPI() async {
//     try {
//       final response = await _dio.get(
//         'https://api.gold-api.com/price/XAUUSD',
//       );
      
//       if (response.statusCode == 200 && response.data != null) {
//         final price = response.data['price']?.toDouble();
//         if (price != null && price > 4000 && price < 5000) {
//           return price;
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }
  
//   // Backup API 2
//   Future<double?> _fetchFromExchangeRateAPI() async {
//     try {
//       final response = await _dio.get(
//         'https://api.exchangerate-api.com/v4/latest/USD',
//       );
      
//       if (response.statusCode == 200 && response.data != null) {
//         final xauRate = response.data['rates']?['XAU'];
//         if (xauRate != null && xauRate > 0) {
//           final price = 1 / xauRate;
//           if (price > 4000 && price < 5000) {
//             return price;
//           }
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }
  
//   // Force refresh price
//   Future<double> forceRefreshPrice() async {
//     // Clear cache to force new API call
//     _cachedPrice = null;
//     _lastFetchTime = null;
    
//     final price = await getCurrentGoldPrice();
//     return price;
//   }
  
//   // Get historical prices for chart
//   Future<List<Map<String, dynamic>>> getHistoricalPrices(String interval, int outputSize) async {
//     try {
//       final response = await _dio.get(
//         'https://api.twelvedata.com/time_series',
//         queryParameters: {
//           'symbol': 'XAU/USD',
//           'interval': interval, // '1min', '5min', '15min', '30min', '1h', '1day'
//           'outputsize': outputSize,
//           'apikey': _twelveDataApiKey,
//         },
//       );
      
//       if (response.statusCode == 200 && response.data != null) {
//         final values = response.data['values'] as List?;
//         if (values != null) {
//           return values.map((v) => {
//             'datetime': v['datetime'],
//             'price': double.parse(v['close'].toString()),
//           }).toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Historical data error: $e');
//       return [];
//     }
//   }
// }


// --------- New Version ---------- //

// data/services/gold_price_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goldPriceServiceProvider = Provider((ref) => GoldPriceService());

class GoldPriceService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  
  double? _cachedPrice;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(seconds: 10);

  Future<double> getCurrentGoldPrice() async {
    // Return cached price if still valid
    if (_cachedPrice != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedPrice!;
      }
    }
    
    // Try multiple free APIs
    double? price;
    
    // Try 1: Twelve Data (using your API key with proxy)
    price = await _fetchFromTwelveData();
    if (price != null && price > 0) {
      _cachedPrice = price;
      _lastFetchTime = DateTime.now();
      return price;
    }
    
    // Try 2: GOLD-API via alternative proxy
    price = await _fetchFromGoldAPIAlternative();
    if (price != null && price > 0) {
      _cachedPrice = price;
      _lastFetchTime = DateTime.now();
      return price;
    }
    
    // Try 3: Exchange Rate API
    price = await _fetchFromExchangeRateAPI();
    if (price != null && price > 0) {
      _cachedPrice = price;
      _lastFetchTime = DateTime.now();
      return price;
    }
    
    // If all fail, throw error - NO FALLBACKS!
    throw Exception('Unable to fetch live gold price from any API. Please check your internet connection.');
  }
  
  // Method 1: Twelve Data API with proxy
// Alternative gold price method using Twelve Data with proxy
Future<double?> _fetchFromTwelveData() async {
  try {
    final response = await _dio.get(
      'https://corsproxy.io/?url=' +
      Uri.encodeComponent('https://api.twelvedata.com/price?symbol=XAU/USD&apikey=2fa1507bcb684b849020b306442fa88d'),
    );
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map?;
      if (data != null && data.containsKey('price')) {
        final price = double.tryParse(data['price'].toString());
        if (price != null && price > 4000 && price < 5000) {
          print('✅ Twelve Data Price: \$$price');
          return price;
        }
      }
    }
    return null;
  } catch (e) {
    print('❌ Twelve Data error: $e');
    return null;
  }
}

  // Method 2: Alternative gold API (using a different endpoint)
  Future<double?> _fetchFromGoldAPIAlternative() async {
    try {
      // Using a different proxy and endpoint
      final response = await _dio.get(
        'https://cors-anywhere.herokuapp.com/https://www.gold-api.com/price/XAU',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map?;
        if (data != null && data.containsKey('price')) {
          final price = data['price']?.toDouble();
          if (price != null && price > 4000 && price < 5000) {
            print('✅ Gold API Price: \$$price');
            return price;
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Gold API alternative error: $e');
      return null;
    }
  }

  // Method 3: Exchange Rate API (free, no CORS issues)
  Future<double?> _fetchFromExchangeRateAPI() async {
    try {
      final response = await _dio.get(
        'https://api.exchangerate-api.com/v4/latest/USD',
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map?;
        if (data != null && data.containsKey('rates')) {
          final rates = data['rates'] as Map?;
          if (rates != null && rates.containsKey('XAU')) {
            final xauRate = rates['XAU'];
            if (xauRate != null && xauRate > 0) {
              final price = 1 / xauRate;
              if (price > 4000 && price < 5000) {
                print('✅ Exchange Rate API Price: \$$price');
                return price;
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Exchange Rate API error: $e');
      return null;
    }
  }

  // Method 4: Using a different free gold price API
  Future<double?> _fetchFromGoldPriceOrg() async {
    try {
      final response = await _dio.get(
        'https://www.goldprice.org/feed/GetJson.aspx',
        queryParameters: {
          'd': 'USD',
          'm': 'XAU',
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map?;
        if (data != null && data.containsKey('goldprice')) {
          final price = double.tryParse(data['goldprice'].toString());
          if (price != null && price > 4000 && price < 5000) {
            print('✅ Gold Price Org: \$$price');
            return price;
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Gold Price Org error: $e');
      return null;
    }
  }
  
  Future<double> forceRefreshPrice() async {
    _cachedPrice = null;
    _lastFetchTime = null;
    return await getCurrentGoldPrice();
  }
}