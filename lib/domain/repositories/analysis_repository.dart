import '../entities/gold_analysis.dart';

abstract class AnalysisRepository {
  Future<GoldAnalysis> analyzeGoldImpact();
  Future<Map<String, dynamic>> validatePrediction(GoldAnalysis analysis, double actualGoldMove);
}