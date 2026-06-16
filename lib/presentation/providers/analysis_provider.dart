// presentation/providers/analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gold_analysis.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../../data/repositories/analysis_repository_impl.dart';

// Provider for the analysis repository
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepositoryImpl();
});

// State class for analysis
class AnalysisState {
  final GoldAnalysis? analysis;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const AnalysisState({
    this.analysis,
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  AnalysisState copyWith({
    GoldAnalysis? analysis,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return AnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool get hasData => analysis != null;
  bool get hasError => error != null;
}

// Notifier provider for analysis state management
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AnalysisRepository repository;

  AnalysisNotifier({required this.repository}) : super(const AnalysisState());

  Future<void> loadAnalysis() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final analysis = await repository.analyzeGoldImpact();
      state = state.copyWith(
        analysis: analysis,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshAnalysis() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final analysis = await repository.analyzeGoldImpact();
      state = state.copyWith(
        analysis: analysis,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> validateAnalysis(double actualGoldMove) async {
    if (state.analysis == null) return;

    try {
      final validation = await repository.validatePrediction(state.analysis!, actualGoldMove);
      // Handle validation result - could add to state or show notification
      print('Validation result: $validation');
    } catch (e) {
      print('Validation error: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for the analysis notifier
final analysisNotifierProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final repository = ref.read(analysisRepositoryProvider);
  return AnalysisNotifier(repository: repository);
});

// Provider for just the analysis data (for easy consumption)
final analysisProvider = Provider<GoldAnalysis?>((ref) {
  final state = ref.watch(analysisNotifierProvider);
  return state.analysis;
});

// Provider for loading state
final analysisLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(analysisNotifierProvider);
  return state.isLoading || state.isRefreshing;
});

// Provider for error state
final analysisErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(analysisNotifierProvider);
  return state.error;
});

// Provider for just the analysis (Future provider alternative)
final analysisFutureProvider = FutureProvider<GoldAnalysis>((ref) async {
  final repository = ref.read(analysisRepositoryProvider);
  return await repository.analyzeGoldImpact();
});