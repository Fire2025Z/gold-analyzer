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
import 'dart:convert';
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
    
    try {
      // Use Netlify function
      final response = await _dio.get('/.netlify/functions/gold-price');
      
      print('📊 Gold price response status: ${response.statusCode}');
      print('📊 Gold price response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        
        // If response is String, parse it
        if (data is String) {
          try {
            data = jsonDecode(data);
            print('📊 Parsed gold price JSON successfully');
          } catch (e) {
            print('⚠️ Could not parse gold price JSON: $e');
            print('📊 Raw data: ${data.substring(0, 200)}...');
            throw Exception('Invalid gold price JSON response');
          }
        }
        
        // Now data should be a Map
        if (data is Map) {
          final price = data['price'];
          if (price != null && price is num && price > 0) {
            _cachedPrice = price.toDouble();
            _lastFetchTime = DateTime.now();
            print('✅ Gold Price: \$$_cachedPrice');
            return _cachedPrice!;
          } else {
            print('⚠️ Gold price null or invalid from API: $price');
          }
        } else {
          print('⚠️ Gold price response is not a Map: ${data.runtimeType}');
        }
      }
      
      // If we have cached price, use it
      if (_cachedPrice != null) {
        print('⚠️ Using cached gold price: \$${_cachedPrice}');
        return _cachedPrice!;
      }
      
      throw Exception('Unable to fetch gold price');
      
    } catch (e) {
      print('❌ Gold price error: $e');
      
      if (_cachedPrice != null) {
        print('⚠️ Using cached gold price: \$${_cachedPrice}');
        return _cachedPrice!;
      }
      
      // Return a default price instead of throwing (so the app doesn't crash)
      print('⚠️ Returning default gold price: \$4346.80');
      return 4346.80;
    }
  }
  
  Future<double> forceRefreshPrice() async {
    _cachedPrice = null;
    _lastFetchTime = null;
    return await getCurrentGoldPrice();
  }
}