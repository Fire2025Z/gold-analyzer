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

// data/services/economic_calendar_service.dart (add this to the beginning of getTodaysEvents)
Future<List<EconomicEventModel>> getTodaysEvents() async {
  try {
    // Try direct function URL first
    final String url = '/.netlify/functions/economic-calendar';
    
    print('📊 Fetching from: $url');
    final response = await _dio.get(url);
    
    print('📊 Response status: ${response.statusCode}');
    print('📊 Response data type: ${response.data.runtimeType}');
    
    if (response.statusCode == 200 && response.data != null) {
      dynamic data = response.data;
      
      // If response is String, parse it
      if (data is String) {
        try {
          data = jsonDecode(data);
          print('📊 Parsed JSON successfully');
        } catch (e) {
          print('⚠️ Could not parse JSON: $e');
          // Try to extract data from HTML (if it's HTML)
          if (data.contains('[') && data.contains(']')) {
            try {
              final start = data.indexOf('[');
              final end = data.lastIndexOf(']') + 1;
              if (start != -1 && end != -1) {
                final jsonStr = data.substring(start, end);
                data = jsonDecode(jsonStr);
                print('📊 Extracted JSON from HTML');
              }
            } catch (e2) {
              print('⚠️ Could not extract JSON from HTML');
            }
          }
        }
      }
      
      // Check if it's an error response
      if (data is Map && data.containsKey('error')) {
        print('❌ Function returned error: ${data['error']}');
        // Check if there's fallback data
        if (data.containsKey('data')) {
          data = data['data'];
        } else {
          throw Exception('Function error: ${data['error']}');
        }
      }
      
      // Parse the data
      List? eventList;
      if (data is List) {
        eventList = data;
      } else if (data is Map) {
        print('📊 Data is Map, keys: ${data.keys}');
        if (data.containsKey('events')) {
          eventList = data['events'] as List?;
        } else if (data.containsKey('data')) {
          eventList = data['data'] as List?;
        } else if (data.containsKey('calendar')) {
          eventList = data['calendar'] as List?;
        } else {
          // Try to find any list in the map
          for (var value in data.values) {
            if (value is List) {
              eventList = value;
              break;
            }
          }
        }
      }
      
      if (eventList != null && eventList.isNotEmpty) {
        final events = _parseForexFactoryData(eventList);
        if (events.isNotEmpty) {
          print('✅ Loaded ${events.length} events');
          return events;
        } else {
          print('⚠️ No gold-impacting events found');
        }
      } else {
        print('⚠️ No event list found in data');
        print('📊 Data preview: ${data.toString().substring(0, 200)}...');
      }
    }
    
    // If we get here, something went wrong
    throw Exception('Unable to parse economic calendar data');
    
  } catch (e) {
    print('❌ API Error: $e');
    throw Exception('Failed to fetch economic data: $e');
  }
}