import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_news_analyzer/domain/entities/gold_analysis.dart';
import 'package:gold_news_analyzer/presentation/providers/analysis_provider.dart';

class AnalysisButton extends ConsumerWidget {
  final GoldAnalysis analysis;
  
  const AnalysisButton({super.key, required this.analysis});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(analysisLoadingProvider);
    
    return ElevatedButton(
      onPressed: isLoading 
          ? null 
          : () {
              ref.read(analysisNotifierProvider.notifier).refreshAnalysis();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing analysis...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics),
                SizedBox(width: 8),
                Text(
                  'Analyze Gold Impact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}