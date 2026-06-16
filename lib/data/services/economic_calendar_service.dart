// data/services/economic_calendar_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/economic_event_model.dart';

final economicCalendarServiceProvider = Provider((ref) => EconomicCalendarService());

class EconomicCalendarService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<List<EconomicEventModel>> getTodaysEvents() async {
    try {
      // Use Netlify function
      final response = await _dio.get('/api/economic-calendar');
      
      print('📊 Response status: ${response.statusCode}');
      print('📊 Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 && response.data != null) {
        // The function returns the raw data from Forex Factory
        final rawData = response.data;
        
        // Check if it's a List or Map
        List? eventList;
        if (rawData is List) {
          eventList = rawData;
        } else if (rawData is Map) {
          // If it's a Map, it might be wrapped in an 'events' key or similar
          print('📊 Data is Map, keys: ${rawData.keys}');
          
          // Try common keys
          if (rawData.containsKey('events')) {
            eventList = rawData['events'] as List?;
          } else if (rawData.containsKey('data')) {
            eventList = rawData['data'] as List?;
          } else if (rawData.containsKey('calendar')) {
            eventList = rawData['calendar'] as List?;
          } else {
            // Try the first value if it's a List
            for (var value in rawData.values) {
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
            print('✅ Loaded ${events.length} events from Netlify function');
            return events;
          }
        }
        
        // If we got data but couldn't parse it, log it
        print('⚠️ Could not parse data: ${response.data.toString().substring(0, 200)}...');
      }
      
      throw Exception('Unable to parse economic calendar data');
      
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to fetch economic data: $e');
    }
  }

  List<EconomicEventModel> _parseForexFactoryData(List data) {
    final List<EconomicEventModel> events = [];
    
    print('📊 Processing ${data.length} events from Forex Factory');
    
    for (var item in data) {
      try {
        final title = item['title']?.toString() ?? '';
        final country = item['country']?.toString() ?? '';
        
        // Only USD events
        if (country != 'USD') continue;
        
        // Gold-related events
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
              continue;
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
      } catch (e) {
        print('Error parsing event: $e');
        continue;
      }
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