// data/services/economic_calendar_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/economic_event_model.dart';


final economicCalendarServiceProvider = Provider((ref) => EconomicCalendarService());

class EconomicCalendarService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

// In the getTodaysEvents method, ensure JSON parsing is handled properly

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
        throw Exception('Function error: ${data['error']}');
      }
      
      // Parse the data - handle both List and Map responses
      List? eventList;
      if (data is List) {
        eventList = data;
      } else if (data is Map) {
        print('📊 Data is Map, keys: ${data.keys}');
        // Try to find the events list
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
        if (data != null) {
          final dataStr = data.toString();
          print('📊 Data preview: ${dataStr.substring(0, dataStr.length > 200 ? 200 : dataStr.length)}...');
        }
      }
    }
    
    // If we get here, something went wrong
    throw Exception('Unable to parse economic calendar data');
    
  } catch (e) {
    print('❌ API Error: $e');
    throw Exception('Failed to fetch economic data: $e');
  }
}

  List<EconomicEventModel> _parseForexFactoryData(List data) {
    final List<EconomicEventModel> events = [];
    
    if (data.isEmpty) {
      print('⚠️ Data list is empty');
      return events;
    }
    
    print('📊 Processing ${data.length} events from Forex Factory');
    
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
        
        // Gold-related events - Expanded list
        final goldEvents = [
          // Inflation
          'CPI', 'Core CPI', 'PCE', 'Core PCE', 'PPI',
          
          // Employment
          'Non-Farm Payrolls', 'NFP', 'Unemployment', 'Jobless Claims', 
          'ADP Employment', 'Employment Change', 'Labor Force',
          
          // Growth
          'GDP', 'GDP Growth',
          
          // FOMC / Fed (MOST IMPORTANT - all variations)
          'FOMC', 'Fed', 'Federal Reserve', 'Interest Rate Decision',
          'Rate Decision', 'Monetary Policy', 'Fed Chair',
          'Press Conference', 'FOMC Statement', 'Fed Press',
          'Jerome Powell', 'Federal Funds Rate', 'Fed Speech',
          'FOMC Economic Projections', 'Fed Meeting',
          
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
                  print('⚠️ Could not parse date: ${item['date']}');
                  continue;
                }
              } catch (e2) {
                print('⚠️ Could not parse date: ${item['date']}');
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
        
        print('📅 Event: $title');
        print('   Date: $eventDate');
        print('   Impact: $impact');
        print('   Forecast: $forecastValue, Actual: $actualValue, Previous: $previousValue');
        
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
}
