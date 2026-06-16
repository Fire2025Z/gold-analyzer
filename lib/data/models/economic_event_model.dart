import 'package:equatable/equatable.dart';
import '../../domain/entities/economic_event.dart';

class EconomicEventModel extends Equatable {
  final String id;
  final String title;
  final String country;
  final String impact;
  final DateTime dateTime;
  final double? forecast;
  final double? actual;
  final double? previous;
  
  const EconomicEventModel({
    required this.id,
    required this.title,
    required this.country,
    required this.impact,
    required this.dateTime,
    this.forecast,
    this.actual,
    this.previous,
  });
  
  factory EconomicEventModel.fromJson(Map<String, dynamic> json) {
    return EconomicEventModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      country: json['country'] ?? 'USD',
      impact: json['impact'] ?? 'Medium',
      dateTime: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      forecast: json['forecast'] != null ? double.tryParse(json['forecast'].toString()) : null,
      actual: json['actual'] != null ? double.tryParse(json['actual'].toString()) : null,
      previous: json['previous'] != null ? double.tryParse(json['previous'].toString()) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'country': country,
      'impact': impact,
      'date': dateTime.toIso8601String(),
      'forecast': forecast,
      'actual': actual,
      'previous': previous,
    };
  }
  
  EconomicEvent toEntity() {
    ImpactLevel impactLevel;
    switch (impact.toLowerCase()) {
      case 'high':
        impactLevel = ImpactLevel.high;
        break;
      case 'medium':
        impactLevel = ImpactLevel.medium;
        break;
      default:
        impactLevel = ImpactLevel.low;
    }
    
    EventStatus status;
    if (dateTime.isBefore(DateTime.now())) {
      status = EventStatus.released;
    } else {
      status = EventStatus.upcoming;
    }
    
    return EconomicEvent(
      id: id,
      title: title,
      currency: country,
      impact: impactLevel,
      eventTime: dateTime,
      forecast: forecast,
      actual: actual,
      previous: previous,
      status: status,
    );
  }
  
  @override
  List<Object?> get props => [id, title, country, impact, dateTime, forecast, actual, previous];
}