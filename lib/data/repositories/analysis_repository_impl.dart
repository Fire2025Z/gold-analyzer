// import '../../domain/repositories/analysis_repository.dart';
// import '../../domain/entities/economic_event.dart';
// import '../../domain/entities/gold_analysis.dart';
// import '../services/economic_calendar_service.dart';
// import '../services/gold_price_service.dart';

// class AnalysisRepositoryImpl implements AnalysisRepository {
//   final EconomicCalendarService _calendarService;
//   final GoldPriceService _goldPriceService;

//   AnalysisRepositoryImpl({
//     EconomicCalendarService? calendarService,
//     GoldPriceService? goldPriceService,
//   }) : _calendarService = calendarService ?? EconomicCalendarService(),
//        _goldPriceService = goldPriceService ?? GoldPriceService();

//   @override
//   Future<GoldAnalysis> analyzeGoldImpact() async {
//     try {
//       final eventModels = await _calendarService.getTodaysEvents();
//       final allEvents = eventModels.map((model) => model.toEntity()).toList();
      
//       final goldAffectingEvents = [
//         'Non-Farm Payrolls',
//         'CPI',
//         'Core CPI',
//         'PPI',
//         'GDP',
//         'FOMC Statement',
//         'Federal Reserve Speech',
//         'Interest Rate Decision',
//         'Unemployment Claims',
//         'Retail Sales',
//         'Consumer Confidence',
//         'Treasury Auction',
//       ];
      
//       final events = allEvents.where((event) => 
//         goldAffectingEvents.any((keyword) => event.title.contains(keyword))
//       ).toList();
      
//       final goldPrice = await _goldPriceService.getCurrentGoldPrice();
      
//       final releasedEvents = events.where((e) => e.isReleased).toList();
//       final upcomingEvents = events.where((e) => e.isUpcoming).toList();
      
//       int bullishCount = 0;
//       int bearishCount = 0;
//       int neutralCount = 0;
//       int bullishScore = 0;
//       int bearishScore = 0;
      
//       for (final event in events) {
//         final impact = event.impactType;
//         final weight = event.impactWeight;
        
//         switch (impact) {
//           case GoldImpact.bullish:
//             bullishCount++;
//             bullishScore += weight;
//             break;
//           case GoldImpact.bearish:
//             bearishCount++;
//             bearishScore += weight;
//             break;
//           case GoldImpact.neutral:
//             neutralCount++;
//             break;
//         }
//       }
      
//       final totalScore = bullishScore + bearishScore;
//       double bullishProbability;
//       double bearishProbability;
      
//       if (totalScore > 0) {
//         bullishProbability = (bullishScore / totalScore) * 100;
//         bearishProbability = (bearishScore / totalScore) * 100;
        
//         final releasedWeight = releasedEvents.length / events.length;
//         bullishProbability = bullishProbability * (0.7 + releasedWeight * 0.3);
//         bearishProbability = bearishProbability * (0.7 + releasedWeight * 0.3);
        
//         final total = bullishProbability + bearishProbability;
//         bullishProbability = (bullishProbability / total) * 100;
//         bearishProbability = (bearishProbability / total) * 100;
//       } else {
//         bullishProbability = 50;
//         bearishProbability = 50;
//       }
      
//       MarketBias bias;
//       if (bullishProbability > 60) {
//         bias = MarketBias.bullish;
//       } else if (bearishProbability > 60) {
//         bias = MarketBias.bearish;
//       } else {
//         bias = MarketBias.neutral;
//       }
      
//       final releasedRatio = releasedEvents.length / events.length;
//       final hasHighImpactEvents = events.any((e) => e.impact == ImpactLevel.high);
//       final scoreDifference = (bullishScore - bearishScore).abs();
//       final maxPossibleScore = events.length * 3;
      
//       double confidence = releasedRatio * 100;
//       if (hasHighImpactEvents) confidence *= 0.8;
//       if (scoreDifference > maxPossibleScore * 0.3) confidence += 10;
      
//       confidence = confidence.clamp(0, 100);
      
//       return GoldAnalysis(
//         currentGoldPrice: goldPrice,
//         lastUpdate: DateTime.now(),
//         events: events,
//         releasedCount: releasedEvents.length,
//         upcomingCount: upcomingEvents.length,
//         bullishCount: bullishCount,
//         bearishCount: bearishCount,
//         neutralCount: neutralCount,
//         bullishScore: bullishScore,
//         bearishScore: bearishScore,
//         bullishProbability: bullishProbability,
//         bearishProbability: bearishProbability,
//         bias: bias,
//         confidence: confidence,
//       );
//     } catch (e) {
//       return GoldAnalysis(
//         currentGoldPrice: 1900.00,
//         lastUpdate: DateTime.now(),
//         events: [],
//         releasedCount: 0,
//         upcomingCount: 0,
//         bullishCount: 0,
//         bearishCount: 0,
//         neutralCount: 0,
//         bullishScore: 0,
//         bearishScore: 0,
//         bullishProbability: 50,
//         bearishProbability: 50,
//         bias: MarketBias.neutral,
//         confidence: 0,
//       );
//     }
//   }

// // Add this method to AnalysisRepositoryImpl class
// Future<double> forceRefreshGoldPrice() async {
//   return await _goldPriceService.forceRefreshPrice();
// }
  
//   @override
//   Future<Map<String, dynamic>> validatePrediction(GoldAnalysis analysis, double actualGoldMove) async {
//     final predictedDirection = analysis.expectedDirection;
//     final actualDirection = actualGoldMove > 0 ? 'UP' : actualGoldMove < 0 ? 'DOWN' : 'SIDEWAYS';
    
//     final bool correct = predictedDirection == actualDirection;
//     final accuracy = correct ? 100.0 : 0.0;
    
//     return {
//       'predictionCorrect': correct,
//       'accuracy': accuracy,
//       'actualMovePercent': actualGoldMove,
//       'actualMoveUsd': (analysis.currentGoldPrice * actualGoldMove) / 100,
//       'predictedDirection': predictedDirection,
//       'actualDirection': actualDirection,
//     };
//   }
// }

// --------- New Version ---------- //

// data/repositories/analysis_repository_impl.dart
import '../../domain/repositories/analysis_repository.dart';
import '../../domain/entities/economic_event.dart';
import '../../domain/entities/gold_analysis.dart';
import '../services/economic_calendar_service.dart';
import '../services/gold_price_service.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final EconomicCalendarService _calendarService;
  final GoldPriceService _goldPriceService;

  AnalysisRepositoryImpl({
    EconomicCalendarService? calendarService,
    GoldPriceService? goldPriceService,
  }) : _calendarService = calendarService ?? EconomicCalendarService(),
       _goldPriceService = goldPriceService ?? GoldPriceService();

  @override
  Future<GoldAnalysis> analyzeGoldImpact() async {
    try {
      // Fetch real events from API - NO FALLBACKS!
      final eventModels = await _calendarService.getTodaysEvents();
      final allEvents = eventModels.map((model) => model.toEntity()).toList();
      
      if (allEvents.isEmpty) {
        throw Exception('No economic events found for today');
      }
      
      // Gold affecting events keywords
      final goldAffectingEvents = [
        'Non-Farm Payrolls', 'NFP', 'CPI', 'Core CPI', 'PCE',
        'PPI', 'GDP', 'FOMC', 'Federal Reserve', 'Fed',
        'Interest Rate Decision', 'Rate Decision', 'Unemployment Claims',
        'Jobless Claims', 'Retail Sales', 'Consumer Confidence',
        'ISM', 'PMI', 'ADP Employment', 'Employment Change',
        'Fed Chair Speech', 'Press Conference', 'Monetary Policy'
      ];
      
      final events = allEvents.where((event) => 
        goldAffectingEvents.any((keyword) => 
          event.title.toLowerCase().contains(keyword.toLowerCase())
        )
      ).toList();
      
      if (events.isEmpty) {
        throw Exception('No gold-impacting events found in the data');
      }
      
      final goldPrice = await _goldPriceService.getCurrentGoldPrice();
      
      final releasedEvents = events.where((e) => e.isReleased).toList();
      final upcomingEvents = events.where((e) => e.isUpcoming).toList();
      
      int bullishCount = 0;
      int bearishCount = 0;
      int neutralCount = 0;
      int bullishScore = 0;
      int bearishScore = 0;
      
      // Analyze each event's impact on Gold
      for (final event in events) {
        final impact = _calculateGoldImpact(event);
        final weight = event.impactWeight;
        
        switch (impact) {
          case GoldImpact.bullish:
            bullishCount++;
            bullishScore += weight;
            break;
          case GoldImpact.bearish:
            bearishCount++;
            bearishScore += weight;
            break;
          case GoldImpact.neutral:
            neutralCount++;
            break;
        }
      }
      
      // Calculate probabilities
      final totalScore = bullishScore + bearishScore;
      double bullishProbability;
      double bearishProbability;
      
      if (totalScore > 0) {
        bullishProbability = (bullishScore / totalScore) * 100;
        bearishProbability = (bearishScore / totalScore) * 100;
        
        // Adjust based on released events (more weight to released events)
        final releasedWeight = releasedEvents.length / events.length;
        bullishProbability = bullishProbability * (0.7 + releasedWeight * 0.3);
        bearishProbability = bearishProbability * (0.7 + releasedWeight * 0.3);
        
        final total = bullishProbability + bearishProbability;
        bullishProbability = (bullishProbability / total) * 100;
        bearishProbability = (bearishProbability / total) * 100;
      } else {
        bullishProbability = 50;
        bearishProbability = 50;
      }
      
      // Determine market bias
      MarketBias bias;
      if (bullishProbability > 60) {
        bias = MarketBias.bullish;
      } else if (bearishProbability > 60) {
        bias = MarketBias.bearish;
      } else {
        bias = MarketBias.neutral;
      }
      
      // Calculate confidence based on released events ratio and high impact events
      final releasedRatio = releasedEvents.length / events.length;
      final hasHighImpactEvents = events.any((e) => e.impact == ImpactLevel.high);
      final scoreDifference = (bullishScore - bearishScore).abs();
      final maxPossibleScore = events.length * 3;
      
      double confidence = releasedRatio * 100;
      if (hasHighImpactEvents) confidence *= 0.8;
      if (scoreDifference > maxPossibleScore * 0.3) confidence += 10;
      
      confidence = confidence.clamp(0, 100);
      
      return GoldAnalysis(
        currentGoldPrice: goldPrice,
        lastUpdate: DateTime.now(),
        events: events,
        releasedCount: releasedEvents.length,
        upcomingCount: upcomingEvents.length,
        bullishCount: bullishCount,
        bearishCount: bearishCount,
        neutralCount: neutralCount,
        bullishScore: bullishScore,
        bearishScore: bearishScore,
        bullishProbability: bullishProbability,
        bearishProbability: bearishProbability,
        bias: bias,
        confidence: confidence,
      );
    } catch (e) {
      // Re-throw with clear message - NO FALLBACKS!
      throw Exception('Analysis failed: $e');
    }
  }

  GoldImpact _calculateGoldImpact(EconomicEvent event) {
    // Only calculate impact for released events
    if (!event.isReleased || event.actual == null || event.forecast == null) {
      return GoldImpact.neutral;
    }
    
    final actual = event.actual!;
    final forecast = event.forecast!;
    final title = event.title.toLowerCase();
    
    // CPI / Inflation Events
    if (title.contains('cpi') || title.contains('inflation') || title.contains('pce')) {
      if (actual < forecast) {
        return GoldImpact.bullish; // Lower inflation = Bullish for Gold
      } else if (actual > forecast) {
        return GoldImpact.bearish; // Higher inflation = Bearish for Gold
      }
      return GoldImpact.neutral;
    }
    
    // Employment / Jobs Data
    if (title.contains('payrolls') || title.contains('jobless') || 
        title.contains('unemployment') || title.contains('adp')) {
      if (actual < forecast) {
        return GoldImpact.bullish; // Weaker jobs = Bullish for Gold
      } else if (actual > forecast) {
        return GoldImpact.bearish; // Stronger jobs = Bearish for Gold
      }
      return GoldImpact.neutral;
    }
    
    // GDP
    if (title.contains('gdp')) {
      if (actual < forecast) {
        return GoldImpact.bullish; // Slower growth = Bullish for Gold
      } else if (actual > forecast) {
        return GoldImpact.bearish; // Stronger growth = Bearish for Gold
      }
      return GoldImpact.neutral;
    }
    
    // Retail Sales
    if (title.contains('retail')) {
      if (actual < forecast) {
        return GoldImpact.bullish; // Weak spending = Bullish for Gold
      } else if (actual > forecast) {
        return GoldImpact.bearish; // Strong spending = Bearish for Gold
      }
      return GoldImpact.neutral;
    }
    
    // Interest Rate / FOMC
    if (title.contains('rate') || title.contains('fomc') || title.contains('fed')) {
      if (title.contains('cut') || title.contains('dovish')) {
        return GoldImpact.bullish; // Rate cuts = Bullish for Gold
      } else if (title.contains('hike') || title.contains('hawkish')) {
        return GoldImpact.bearish; // Rate hikes = Bearish for Gold
      }
      // For interest rate decisions, higher rates = Bearish for Gold
      if (event.forecast != null && event.actual != null) {
        if (actual < forecast) {
          return GoldImpact.bullish; // Lower than expected rates = Bullish
        } else if (actual > forecast) {
          return GoldImpact.bearish; // Higher than expected rates = Bearish
        }
      }
      return GoldImpact.neutral;
    }
    
    // Default: If actual is lower than forecast, it's often bullish for Gold
    if (actual < forecast) {
      return GoldImpact.bullish;
    } else if (actual > forecast) {
      return GoldImpact.bearish;
    }
    
    return GoldImpact.neutral;
  }
  
  @override
  Future<Map<String, dynamic>> validatePrediction(GoldAnalysis analysis, double actualGoldMove) async {
    final predictedDirection = analysis.expectedDirection;
    final actualDirection = actualGoldMove > 0 ? 'UP' : actualGoldMove < 0 ? 'DOWN' : 'SIDEWAYS';
    
    final bool correct = predictedDirection == actualDirection;
    final accuracy = correct ? 100.0 : 0.0;
    
    return {
      'predictionCorrect': correct,
      'accuracy': accuracy,
      'actualMovePercent': actualGoldMove,
      'actualMoveUsd': (analysis.currentGoldPrice * actualGoldMove) / 100,
      'predictedDirection': predictedDirection,
      'actualDirection': actualDirection,
    };
  }
}