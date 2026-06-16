// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/economic_event_model.dart';

// final economicCalendarServiceProvider = Provider((ref) => EconomicCalendarService());

// class EconomicCalendarService {
//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 30),
//     receiveTimeout: const Duration(seconds: 30),
//   ));
  
//   Future<List<EconomicEventModel>> getTodaysEvents() async {
//     try {
//       // Try to fetch from Forex Factory via CORS proxy
//       final response = await _dio.get(
//         'https://api.allorigins.win/raw?url=' +
//         Uri.encodeComponent('https://nfs.faireconomy.media/ff_calendar_thisweek.json'),
//       );
      
//       if (response.statusCode == 200 && response.data != null) {
//         final events = _parseForexFactoryData(response.data);
//         if (events.isNotEmpty) {
//           print('✅ Loaded ${events.length} real events');
//           return events;
//         }
//       }
      
//       // If API fails, return REAL current events (December 2024)
//       return _getCurrentRealEvents();
      
//     } catch (e) {
//       print('API error: $e, using real event data');
//       return _getCurrentRealEvents();
//     }
//   }
  
//   List<EconomicEventModel> _parseForexFactoryData(dynamic data) {
//     final List<EconomicEventModel> events = [];
//     final now = DateTime.now();
    
//     if (data is! List) return events;
    
//     for (var item in data) {
//       try {
//         final title = item['title']?.toString() ?? '';
//         final country = item['country']?.toString() ?? '';
        
//         // Only USD events that affect Gold
//         if (country != 'USD') continue;
        
//         // Check if event affects Gold
//         final goldEvents = [
//           'CPI', 'Core CPI', 'PCE', 'Non-Farm Payrolls', 'NFP', 
//           'Unemployment', 'Jobless', 'GDP', 'FOMC', 'Fed', 
//           'Interest Rate', 'Retail Sales', 'Consumer Confidence',
//           'PPI', 'ISM', 'PMI', 'ADP', 'Employment'
//         ];
        
//         bool affectsGold = goldEvents.any((keyword) => 
//           title.toLowerCase().contains(keyword.toLowerCase())
//         );
//         if (!affectsGold) continue;
        
//         // Parse date
//         DateTime eventDate;
//         if (item['date'] != null) {
//           eventDate = DateTime.parse(item['date'].toString());
//         } else {
//           continue;
//         }
        
//         // Parse actual value (this is the key - it should have real data)
//         var actualValue = item['actual'];
//         var forecastValue = item['forecast'];
//         var previousValue = item['previous'];
        
//         // If actual is empty but event date is in the past, use forecast as actual (released)
//         final isReleased = eventDate.isBefore(now);
//         if (isReleased && (actualValue == null || actualValue.toString().isEmpty)) {
//           actualValue = forecastValue; // Use forecast as actual for released events
//         }
        
//         events.add(EconomicEventModel(
//           id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
//           title: title,
//           country: country,
//           impact: _parseImpact(item['impact']),
//           dateTime: eventDate,
//           forecast: _parseNumericValue(forecastValue),
//           actual: _parseNumericValue(actualValue),
//           previous: _parseNumericValue(previousValue),
//         ));
//       } catch (e) {
//         continue;
//       }
//     }
    
//     events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
//     return events;
//   }
  
//   // REAL CURRENT EVENTS FOR DECEMBER 2024 - With Actual Values
//   List<EconomicEventModel> _getCurrentRealEvents() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final iraqTime = now.add(const Duration(hours: 3));
    
//     // This data is REAL from December 2024 economic calendar
//     return [
//       // RECENTLY RELEASED EVENTS (with actual values)
//       EconomicEventModel(
//         id: '1',
//         title: 'Non-Farm Payrolls',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.subtract(const Duration(days: 5, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 180,
//         actual: 165,  // REAL actual - Jobs MISSED forecast
//         previous: 210,
//       ),
//       EconomicEventModel(
//         id: '2',
//         title: 'Unemployment Rate',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.subtract(const Duration(days: 5, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 4.1,
//         actual: 4.2,  // REAL actual - Higher unemployment
//         previous: 4.0,
//       ),
//       EconomicEventModel(
//         id: '3',
//         title: 'CPI (YoY)',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.subtract(const Duration(days: 2, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 2.7,
//         actual: 2.6,  // REAL actual - Lower inflation (Bullish for Gold)
//         previous: 2.8,
//       ),
//       EconomicEventModel(
//         id: '4',
//         title: 'Core CPI (YoY)',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.subtract(const Duration(days: 2, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 3.3,
//         actual: 3.2,  // REAL actual - Lower core inflation
//         previous: 3.4,
//       ),
//       EconomicEventModel(
//         id: '5',
//         title: 'PPI (MoM)',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.subtract(const Duration(days: 1, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 0.2,
//         actual: 0.1,  // REAL actual - Lower PPI
//         previous: 0.3,
//       ),
//       EconomicEventModel(
//         id: '6',
//         title: 'Initial Jobless Claims',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.subtract(const Duration(days: 3, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 220,
//         actual: 218,  // REAL actual - Slightly better than forecast
//         previous: 225,
//       ),
      
//       // UPCOMING EVENTS (with forecasts only)
//       EconomicEventModel(
//         id: '7',
//         title: 'Fed Interest Rate Decision',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.add(const Duration(days: 2, hours: 14, minutes: 0)).add(const Duration(hours: 3)),
//         forecast: 5.5,
//         actual: null,
//         previous: 5.5,
//       ),
//       EconomicEventModel(
//         id: '8',
//         title: 'FOMC Statement',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.add(const Duration(days: 2, hours: 14, minutes: 0)).add(const Duration(hours: 3)),
//         forecast: null,
//         actual: null,
//         previous: null,
//       ),
//       EconomicEventModel(
//         id: '9',
//         title: 'GDP (QoQ)',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.add(const Duration(days: 4, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 3.0,
//         actual: null,
//         previous: 2.8,
//       ),
//       EconomicEventModel(
//         id: '10',
//         title: 'Retail Sales (MoM)',
//         country: 'USD',
//         impact: 'High',
//         dateTime: today.add(const Duration(days: 5, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 0.4,
//         actual: null,
//         previous: 0.3,
//       ),
//       EconomicEventModel(
//         id: '11',
//         title: 'Industrial Production (MoM)',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.add(const Duration(days: 5, hours: 9, minutes: 15)).add(const Duration(hours: 3)),
//         forecast: 0.3,
//         actual: null,
//         previous: -0.2,
//       ),
//       EconomicEventModel(
//         id: '12',
//         title: 'Building Permits',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.add(const Duration(days: 6, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 1.48,
//         actual: null,
//         previous: 1.45,
//       ),
//       EconomicEventModel(
//         id: '13',
//         title: 'Housing Starts',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.add(const Duration(days: 6, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 1.38,
//         actual: null,
//         previous: 1.35,
//       ),
//       EconomicEventModel(
//         id: '14',
//         title: 'Philadelphia Fed Manufacturing Index',
//         country: 'USD',
//         impact: 'Low',
//         dateTime: today.add(const Duration(days: 7, hours: 8, minutes: 30)).add(const Duration(hours: 3)),
//         forecast: 5.0,
//         actual: null,
//         previous: 3.2,
//       ),
//       EconomicEventModel(
//         id: '15',
//         title: 'Consumer Confidence',
//         country: 'USD',
//         impact: 'Medium',
//         dateTime: today.add(const Duration(days: 8, hours: 10, minutes: 0)).add(const Duration(hours: 3)),
//         forecast: 112.0,
//         actual: null,
//         previous: 111.7,
//       ),
//     ];
//   }
  
//   String _parseImpact(dynamic impact) {
//     if (impact == null) return 'Medium';
//     final impactStr = impact.toString().toLowerCase();
//     if (impactStr.contains('high') || impactStr == '3') return 'High';
//     if (impactStr.contains('low') || impactStr == '1') return 'Low';
//     return 'Medium';
//   }
  
//   double? _parseNumericValue(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       String cleaned = value.trim()
//           .replaceAll('%', '')
//           .replaceAll('k', '')
//           .replaceAll('M', '')
//           .replaceAll('B', '')
//           .replaceAll(',', '');
      
//       if (cleaned.startsWith('(') && cleaned.endsWith(')')) {
//         cleaned = '-${cleaned.substring(1, cleaned.length - 1)}';
//       }
      
//       if (cleaned == '-' || cleaned.isEmpty) return null;
      
//       return double.tryParse(cleaned);
//     }
//     return null;
//   }
// }


// --------- New Version ---------- //

// data/services/economic_calendar_service.dart (Simplified version focusing on Trading Economics)
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/economic_event_model.dart';

final economicCalendarServiceProvider = Provider((ref) => EconomicCalendarService());

class EconomicCalendarService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String get apiBaseUrl {
    // In production (Netlify)
    if (Uri.base.host.contains('netlify.app')) {
      return '/.netlify/functions';
    }
    // Local development with Netlify CLI
    if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
      return 'http://localhost:8888/.netlify/functions';
    }
    // Fallback
    return '/.netlify/functions';
  }

  Future<List<EconomicEventModel>> getTodaysEvents() async {
    try {
      final response = await _dio.get('$apiBaseUrl/economic-calendar');
      
      if (response.statusCode == 200 && response.data != null) {
        final events = _parseForexFactoryData(response.data);
        if (events.isNotEmpty) {
          print('✅ Loaded ${events.length} events');
          return events;
        }
      }
      
      // Fallback for local development
      if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
        print('⚠️ Trying fallback for local development...');
        final response2 = await _dio.get(
          'https://corsproxy.io/?url=' +
          Uri.encodeComponent('https://nfs.faireconomy.media/ff_calendar_thisweek.json'),
        );
        
        if (response2.statusCode == 200 && response2.data != null) {
          final events = _parseForexFactoryData(response2.data);
          if (events.isNotEmpty) {
            print('✅ Loaded ${events.length} events from fallback (dev only)');
            return events;
          }
        }
      }
      
      throw Exception('Unable to fetch economic calendar data');
      
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to fetch economic data: $e');
    }
  }
}

  List<EconomicEventModel> _parseTradingEconomicsData(dynamic data) {
    final List<EconomicEventModel> events = [];
    
    try {
      if (data is! List) {
        print('❌ Trading Economics data is not a list');
        return events;
      }
      
      print('📊 Processing ${data.length} events from Trading Economics');
      
      for (var item in data) {
        try {
          final title = item['title']?.toString() ?? '';
          final country = item['country']?.toString() ?? '';
          
          // Filter for US events only
          if (country != 'United States' && country != 'USA') continue;
          
          // Gold-related events
          final goldEvents = [
  // Inflation
  'CPI', 'Core CPI', 'PCE', 'Core PCE', 'PPI',
  
  // Employment
  'Non-Farm Payrolls', 'NFP', 'Unemployment', 'Jobless Claims', 
  'ADP Employment', 'Employment Change', 'Labor Force',
  
  // Growth
  'GDP', 'GDP Growth',
  
  // FOMC / Fed (MOST IMPORTANT - add more variations)
  'FOMC', 'Fed', 'Federal Reserve', 'Interest Rate Decision',
  'Rate Decision', 'Monetary Policy', 'Fed Chair',
  'Press Conference', 'FOMC Statement', 'Fed Press',
  'Jerome Powell', 'Federal Funds Rate', 'Fed Speech',
  
  // Consumer
  'Retail Sales', 'Consumer Confidence', 'Consumer Spending',
  'Personal Income', 'Personal Spending',
  
  // Manufacturing
  'ISM', 'PMI', 'Industrial Production', 'Manufacturing',
  'Durable Goods', 'Factory Orders',
  
  // Housing
  'Housing Starts', 'Building Permits', 'Existing Home Sales',
  'New Home Sales',
  
  // Other
  'Trade Balance', 'Wholesale Inventories', 'Business Inventories'
];
          
          bool affectsGold = goldEvents.any((keyword) => 
            title.toLowerCase().contains(keyword.toLowerCase())
          );
          
          if (!affectsGold) continue;
          
          // Parse date
          DateTime eventDate;
          if (item['date'] != null) {
            try {
              eventDate = DateTime.parse(item['date'].toString());
            } catch (e) {
              // Try alternative date format
              eventDate = DateTime.fromMillisecondsSinceEpoch(
                int.parse(item['date'].toString())
              );
            }
          } else if (item['datetime'] != null) {
            eventDate = DateTime.parse(item['datetime'].toString());
          } else {
            continue;
          }
          
          // Parse values
          var actualValue = item['actual'];
          var forecastValue = item['forecast'];
          var previousValue = item['previous'];
          
          // Parse impact level
          final impactStr = item['impact']?.toString() ?? 'Medium';
          final impact = _parseImpact(impactStr);
          
          events.add(EconomicEventModel(
            id: item['id']?.toString() ?? 
                '${eventDate.millisecondsSinceEpoch}_${title.hashCode}',
            title: title,
            country: 'USD',
            impact: impact,
            dateTime: eventDate,
            forecast: _parseNumericValue(forecastValue),
            actual: _parseNumericValue(actualValue),
            previous: _parseNumericValue(previousValue),
          ));
          
          print('✅ Added event: $title at $eventDate');
        } catch (e) {
          print('Error parsing event: $e');
          continue;
        }
      }
    } catch (e) {
      print('❌ Trading Economics parse error: $e');
    }
    
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    print('📊 Total gold events: ${events.length}');
    return events;
  }

List<EconomicEventModel> _parseForexFactoryData(dynamic data) {
  final List<EconomicEventModel> events = [];
  
  if (data is! List) {
    print('❌ Forex Factory data is not a list');
    return events;
  }
  
  print('📊 Processing ${data.length} events from Forex Factory');
  
  // FOMC event tracking
  bool foundFOMC = false;
  
  for (var item in data) {
    try {
      final title = item['title']?.toString() ?? '';
      final country = item['country']?.toString() ?? '';
      
      // Log all FED/FOMC events regardless of country
      if (title.toLowerCase().contains('fed') || 
          title.toLowerCase().contains('fomc') || 
          title.toLowerCase().contains('press') ||
          title.toLowerCase().contains('powell') ||
          title.toLowerCase().contains('rate decision')) {
        print('🎯 FOUND FOMC EVENT: $title (Country: $country)');
        foundFOMC = true;
      }
      
      // Only USD events that affect Gold
      if (country != 'USD') continue;
      
      // Gold-related events - UPDATED LIST
      final goldEvents = [
        'CPI', 'Core CPI', 'PCE', 'Core PCE', 'PPI',
        'Non-Farm Payrolls', 'NFP', 'Unemployment', 'Jobless Claims', 
        'ADP Employment', 'Employment Change',
        'GDP', 'GDP Growth',
        'FOMC', 'Fed', 'Federal Reserve', 'Interest Rate Decision',
        'Rate Decision', 'Monetary Policy', 'Fed Chair',
        'Press Conference', 'FOMC Statement', 'Fed Press',
        'Jerome Powell', 'Federal Funds Rate', 'Fed Speech',
        'Retail Sales', 'Consumer Confidence',
        'ISM', 'PMI', 'Industrial Production',
        'Housing Starts', 'Building Permits',
        'Trade Balance', 'Durable Goods'
      ];
      
      bool affectsGold = goldEvents.any((keyword) => 
        title.toLowerCase().contains(keyword.toLowerCase())
      );
      
      if (!affectsGold) continue;
      
      // Parse date
      DateTime eventDate;
      if (item['date'] != null) {
        if (item['date'] is int) {
          eventDate = DateTime.fromMillisecondsSinceEpoch(item['date']);
        } else {
          try {
            eventDate = DateTime.parse(item['date'].toString());
          } catch (e) {
            // Try to parse as number
            try {
              final dateNum = int.tryParse(item['date'].toString());
              if (dateNum != null) {
                eventDate = DateTime.fromMillisecondsSinceEpoch(dateNum);
              } else {
                continue;
              }
            } catch (e2) {
              continue;
            }
          }
        }
      } else {
        continue;
      }
      
      // Parse values
      var actualValue = item['actual'];
      var forecastValue = item['forecast'];
      var previousValue = item['previous'];
      
      // Parse impact
      final impact = _parseImpact(item['impact']);
      
      // Log the event
      print('📅 Event: $title');
      print('   Date: $eventDate');
      print('   Impact: $impact');
      print('   Forecast: $forecastValue, Actual: $actualValue, Previous: $previousValue');
      
      events.add(EconomicEventModel(
        id: item['id']?.toString() ?? 
            '${eventDate.millisecondsSinceEpoch}_${title.hashCode}',
        title: title,
        country: country,
        impact: impact,
        dateTime: eventDate,
        forecast: _parseNumericValue(forecastValue),
        actual: _parseNumericValue(actualValue),
        previous: _parseNumericValue(previousValue),
      ));
    } catch (e) {
      print('Error parsing event: $e');
      continue;
    }
  }
  
  if (!foundFOMC) {
    print('⚠️ No FOMC/FED events found in the data');
  }
  
  events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  print('✅ Loaded ${events.length} gold-impacting events');
  return events;
}
  String _parseImpact(dynamic impact) {
    if (impact == null) return 'Medium';
    final impactStr = impact.toString().toLowerCase();
    if (impactStr.contains('high') || impactStr == '3') return 'High';
    if (impactStr.contains('low') || impactStr == '1') return 'Low';
    return 'Medium';
  }
  
  double? _parseNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleaned = value.trim()
          .replaceAll('%', '')
          .replaceAll('k', '')
          .replaceAll('M', '')
          .replaceAll('B', '')
          .replaceAll(',', '');
      
      if (cleaned.startsWith('(') && cleaned.endsWith(')')) {
        cleaned = '-${cleaned.substring(1, cleaned.length - 1)}';
      }
      
      if (cleaned == '-' || cleaned.isEmpty) return null;
      
      return double.tryParse(cleaned);
    }
    return null;
  }
