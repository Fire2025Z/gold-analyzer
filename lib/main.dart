import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_news_analyzer/screens/home_screen.dart';
import 'package:gold_news_analyzer/core/themes/app_theme.dart';
import 'package:gold_news_analyzer/presentation/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: GoldNewsAnalyzerApp()));
}

class GoldNewsAnalyzerApp extends ConsumerWidget {
  const GoldNewsAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Gold News Analyzer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}