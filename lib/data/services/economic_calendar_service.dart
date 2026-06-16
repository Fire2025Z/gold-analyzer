// economic_calendar_service.dart
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