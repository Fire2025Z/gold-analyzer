import 'package:equatable/equatable.dart';
import 'economic_event.dart';

class GoldAnalysis extends Equatable {
  final double currentGoldPrice;
  final DateTime lastUpdate;
  final List<EconomicEvent> events;
  final int releasedCount;
  final int upcomingCount;
  final int bullishCount;
  final int bearishCount;
  final int neutralCount;
  final int bullishScore;
  final int bearishScore;
  final double bullishProbability;
  final double bearishProbability;
  final MarketBias bias;
  final double confidence;
  
  const GoldAnalysis({
    required this.currentGoldPrice,
    required this.lastUpdate,
    required this.events,
    required this.releasedCount,
    required this.upcomingCount,
    required this.bullishCount,
    required this.bearishCount,
    required this.neutralCount,
    required this.bullishScore,
    required this.bearishScore,
    required this.bullishProbability,
    required this.bearishProbability,
    required this.bias,
    required this.confidence,
  });
  
  int get totalEvents => events.length;
  int get netScore => bullishScore - bearishScore;
  
  String get expectedDirection => bias == MarketBias.bullish ? 'UP' : bias == MarketBias.bearish ? 'DOWN' : 'SIDEWAYS';
  
  String get confidenceLevel {
    if (confidence >= 70) return 'High';
    if (confidence >= 50) return 'Moderate';
    return 'Low';
  }
  
  @override
  List<Object?> get props => [
    currentGoldPrice,
    lastUpdate,
    events,
    releasedCount,
    upcomingCount,
    bullishCount,
    bearishCount,
    neutralCount,
    bullishScore,
    bearishScore,
    bullishProbability,
    bearishProbability,
    bias,
    confidence,
  ];
}

enum MarketBias { bullish, bearish, neutral }

extension MarketBiasExtension on MarketBias {
  String get displayName {
    switch (this) {
      case MarketBias.bullish:
        return 'Bullish';
      case MarketBias.bearish:
        return 'Bearish';
      case MarketBias.neutral:
        return 'Neutral';
    }
  }
}