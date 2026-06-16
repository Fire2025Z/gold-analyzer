import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class EconomicEvent extends Equatable {
  final String id;
  final String title;
  final String currency;
  final ImpactLevel impact;
  final DateTime eventTime;
  final double? forecast;
  final double? actual;
  final double? previous;
  final EventStatus status;
  
  const EconomicEvent({
    required this.id,
    required this.title,
    required this.currency,
    required this.impact,
    required this.eventTime,
    this.forecast,
    this.actual,
    this.previous,
    required this.status,
  });
  
  bool get isReleased => status == EventStatus.released;
  bool get isUpcoming => status == EventStatus.upcoming;
  
  GoldImpact get impactType {
    if (actual == null || forecast == null) return GoldImpact.neutral;
    
    // Determine impact based on event type and actual vs forecast
    if (title.contains('CPI') || title.contains('Inflation')) {
      if (actual! < forecast!) return GoldImpact.bullish;
      if (actual! > forecast!) return GoldImpact.bearish;
    }
    
    if (title.contains('Non-Farm Payrolls') || title.contains('Unemployment')) {
      if (actual! < forecast!) return GoldImpact.bullish;
      if (actual! > forecast!) return GoldImpact.bearish;
    }
    
    if (title.contains('GDP')) {
      if (actual! < forecast!) return GoldImpact.bullish;
      if (actual! > forecast!) return GoldImpact.bearish;
    }
    
    if (title.contains('Rate Decision') || title.contains('FOMC')) {
      if (title.contains('dovish') || title.contains('cut')) return GoldImpact.bullish;
      if (title.contains('hawkish') || title.contains('hike')) return GoldImpact.bearish;
    }
    
    if (title.contains('Retail Sales')) {
      if (actual! < forecast!) return GoldImpact.bullish;
      if (actual! > forecast!) return GoldImpact.bearish;
    }
    
    return GoldImpact.neutral;
  }
  
  int get impactWeight {
    switch (impact) {
      case ImpactLevel.high:
        return 3;
      case ImpactLevel.medium:
        return 2;
      case ImpactLevel.low:
        return 1;
    }
  }
  
  @override
  List<Object?> get props => [id, title, currency, impact, eventTime, forecast, actual, previous, status];
}

enum ImpactLevel { high, medium, low }
enum EventStatus { released, upcoming }
enum GoldImpact { bullish, bearish, neutral }

extension GoldImpactExtension on GoldImpact {
  String get displayName {
    switch (this) {
      case GoldImpact.bullish:
        return 'Bullish';
      case GoldImpact.bearish:
        return 'Bearish';
      case GoldImpact.neutral:
        return 'Neutral';
    }
  }
  
  Color getColor(BuildContext context) {
    switch (this) {
      case GoldImpact.bullish:
        return Colors.green;
      case GoldImpact.bearish:
        return Colors.red;
      case GoldImpact.neutral:
        return Colors.grey;
    }
  }
}