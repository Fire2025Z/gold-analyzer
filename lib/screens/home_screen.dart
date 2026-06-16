// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gold_news_analyzer/presentation/providers/analysis_provider.dart';
// import 'package:gold_news_analyzer/screens/report_screen.dart';
// import 'package:gold_news_analyzer/domain/entities/gold_analysis.dart';
// import 'package:gold_news_analyzer/domain/entities/economic_event.dart';
// import 'package:gold_news_analyzer/data/services/gold_price_service.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(analysisNotifierProvider.notifier).loadAnalysis();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final analysisState = ref.watch(analysisNotifierProvider);
//     final isLoading = ref.watch(analysisLoadingProvider);
//     final error = ref.watch(analysisErrorProvider);
    
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       appBar: AppBar(
//         title: const Text('Gold Analyzer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//         backgroundColor: const Color(0xFF1A1A2E),
//         elevation: 0,
//         centerTitle: true,
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back, color: Colors.grey),
//         //   onPressed: () => Navigator.of(context).pop(),
//         // ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.bar_chart, color: Colors.white70),
//             onPressed: () {
//               if (analysisState.hasData && analysisState.analysis != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ReportScreen(analysis: analysisState.analysis!),
//                   ),
//                 );
//               }
//             },
//           ),
//           IconButton(
//             icon: isLoading 
//                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)))
//                 : const Icon(Icons.refresh, color: Colors.white70),
//             onPressed: isLoading ? null : () async {
//               await ref.read(analysisNotifierProvider.notifier).refreshAnalysis();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Data refreshed'),
//                   duration: Duration(seconds: 1),
//                   backgroundColor: Color(0xFF4CAF50),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _buildBody(analysisState, isLoading, error),
//       bottomNavigationBar: Padding(
//     padding: const EdgeInsets.only(bottom: 10, top: 5),
//     child: Text(
//       '© 2026 Developed By Zinar Mizuri',
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         fontSize: 11,
//         color: Colors.white54,
//       ),
//     ),
//   ),
//     );
//   }
  
//   Widget _buildBody(AnalysisState state, bool isLoading, String? error) {
//     if (isLoading && !state.hasData) {
//       return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
//     }
    
//     if (error != null && !state.hasData) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
//             const SizedBox(height: 16),
//             Text(error, style: TextStyle(color: Colors.grey[500])),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => ref.read(analysisNotifierProvider.notifier).loadAnalysis(),
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
//               child: const Text('Try Again', style: TextStyle(color: Color(0xFF1A1A2E))),
//             ),
//           ],
//         ),
//       );
//     }
    
//     if (state.hasData && state.analysis != null) {
//       return HomeContent(analysis: state.analysis!);
//     }
    
//     return Center(child: Text('No data', style: TextStyle(color: Colors.grey[500])));
//   }
// }

// class HomeContent extends StatefulWidget {
//   final GoldAnalysis analysis;
  
//   const HomeContent({super.key, required this.analysis});
  
//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   late double currentPrice;
//   late DateTime lastUpdate;
//   double previousPrice = 0;
//   bool isRefreshing = false;
//   Timer? _priceTimer;
  
//   @override
//   void initState() {
//     super.initState();
//     currentPrice = widget.analysis.currentGoldPrice;
//     previousPrice = currentPrice;
//     lastUpdate = widget.analysis.lastUpdate;
//     _startLiveUpdates();
//   }
  
//   @override
//   void dispose() {
//     _priceTimer?.cancel();
//     super.dispose();
//   }
  
//   void _startLiveUpdates() {
//     // Update price every 10 seconds
//     _priceTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       _refreshPriceOnly();
//     });
//   }
  
//   Future<void> _refreshPriceOnly() async {
//     try {
//       final priceService = GoldPriceService();
//       final newPrice = await priceService.forceRefreshPrice();
      
//       if (mounted) {
//         setState(() {
//           previousPrice = currentPrice;
//           currentPrice = newPrice;
//           lastUpdate = DateTime.now();
//         });
//       }
//     } catch (e) {
//       // Silent fail
//     }
//   }
  
//   Future<void> _manualRefresh() async {
//     setState(() {
//       isRefreshing = true;
//     });
    
//     try {
//       final priceService = GoldPriceService();
//       final newPrice = await priceService.forceRefreshPrice();
      
//       if (mounted) {
//         setState(() {
//           previousPrice = currentPrice;
//           currentPrice = newPrice;
//           lastUpdate = DateTime.now();
//           isRefreshing = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isRefreshing = false;
//         });
//       }
//     }
//   }
  
//   double get priceChange => currentPrice - previousPrice;
//   bool get isPriceUp => priceChange >= 0;
  
//   @override
//   Widget build(BuildContext context) {
//     final isBullish = widget.analysis.bullishProbability > widget.analysis.bearishProbability;
//     final allEvents = widget.analysis.events;
//     final releasedEvents = allEvents.where((e) => e.isReleased).toList();
//     final upcomingEvents = allEvents.where((e) => e.isUpcoming).toList();
    
//     return RefreshIndicator(
//       onRefresh: _manualRefresh,
//       color: const Color(0xFFD4AF37),
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Gold Price Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2D2D44),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text('XAU/USD', style: TextStyle(color: Colors.white70, fontSize: 14)),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4CAF50).withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Text('LIVE', style: TextStyle(fontSize: 9, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: isPriceUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
//                               size: 10,
//                               color: isPriceUp ? Colors.green : Colors.red,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               priceChange.abs().toStringAsFixed(2),
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: isPriceUp ? Colors.green : Colors.red,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     '\$${currentPrice.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFD4AF37),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Updated ${DateFormat('HH:mm:ss').format(lastUpdate)}',
//                     style: const TextStyle(color: Colors.white38, fontSize: 11),
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.touch_app, size: 10, color: Colors.white38),
//                         SizedBox(width: 4),
//                         Text('Pull down to refresh', style: TextStyle(color: Colors.white38, fontSize: 9)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Stats Row - Shows correct counts
//             Row(
//               children: [
//                 _statBox('Released', releasedEvents.length.toString(), allEvents.length.toString(), const Color(0xFF4CAF50)),
//                 _statBox('Upcoming', upcomingEvents.length.toString(), allEvents.length.toString(), const Color(0xFFFF9800)),
//                 _statBox('Bullish', widget.analysis.bullishCount.toString(), '', const Color(0xFF4CAF50)),
//                 _statBox('Bearish', widget.analysis.bearishCount.toString(), '', const Color(0xFFF44336)),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Probability Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2D2D44),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           children: [
//                             Text(
//                               '${widget.analysis.bullishProbability.toStringAsFixed(0)}%',
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF4CAF50),
//                               ),
//                             ),
//                             const Text('Bullish', style: TextStyle(fontSize: 12, color: Colors.white54)),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         width: 1,
//                         color: Colors.white24,
//                       ),
//                       Expanded(
//                         child: Column(
//                           children: [
//                             Text(
//                               '${widget.analysis.bearishProbability.toStringAsFixed(0)}%',
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFFF44336),
//                               ),
//                             ),
//                             const Text('Bearish', style: TextStyle(fontSize: 12, color: Colors.white54)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: LinearProgressIndicator(
//                       value: widget.analysis.bullishProbability / 100,
//                       backgroundColor: const Color(0xFFF44336),
//                       color: const Color(0xFF4CAF50),
//                       minHeight: 6,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isBullish 
//                           ? const Color(0xFF4CAF50).withOpacity(0.1) 
//                           : const Color(0xFFF44336).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           isBullish ? Icons.arrow_upward : Icons.arrow_downward,
//                           size: 14,
//                           color: isBullish ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Expected: ${widget.analysis.expectedDirection}  •  ${widget.analysis.confidenceLevel} Confidence',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isBullish ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Events Section Header - Shows total count
//             Row(
//               children: [
//                 const Text(
//                   'Economic Events (Last 24h / Next 24h)',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD4AF37).withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${allEvents.length} total',
//                     style: const TextStyle(fontSize: 10, color: Color(0xFFD4AF37)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
            
//             // Show ALL events
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: allEvents.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 return _detailedEventCard(allEvents[index]);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _statBox(String label, String value, String total, Color color) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2D2D44),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(
//               total.isEmpty ? value : '$value / $total',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
//             ),
//             const SizedBox(height: 2),
//             Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _detailedEventCard(EconomicEvent event) {
//     final bool isReleased = event.isReleased;
//     final iraqTime = event.eventTime.add(const Duration(hours: 3));
    
//     final impactColor = event.impactType == GoldImpact.bullish 
//         ? const Color(0xFF4CAF50)
//         : event.impactType == GoldImpact.bearish 
//             ? const Color(0xFFF44336) 
//             : Colors.grey;
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 2),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2D2D44),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ExpansionTile(
//         leading: Container(
//           width: 4,
//           height: 30,
//           decoration: BoxDecoration(
//             color: impactColor,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               event.title,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: isReleased 
//                         ? const Color(0xFF4CAF50).withOpacity(0.15) 
//                         : const Color(0xFFFF9800).withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     isReleased ? 'RELEASED' : 'UPCOMING',
//                     style: TextStyle(
//                       fontSize: 8,
//                       fontWeight: FontWeight.bold,
//                       color: isReleased ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(Icons.access_time, size: 10, color: Colors.white38),
//                 const SizedBox(width: 4),
//                 Text(
//                   DateFormat('HH:mm').format(iraqTime),
//                   style: const TextStyle(fontSize: 10, color: Colors.white38),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   event.currency,
//                   style: const TextStyle(fontSize: 10, color: Colors.white38),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isReleased && event.actual != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: impactColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       event.impactType == GoldImpact.bullish ? Icons.arrow_upward : Icons.arrow_downward,
//                       size: 10,
//                       color: impactColor,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       event.impactType == GoldImpact.bullish ? 'BULLISH' : 'BEARISH',
//                       style: TextStyle(
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                         color: impactColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(width: 8),
//             Icon(Icons.expand_more, color: Colors.white38, size: 18),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Values
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A1A2E),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _valueBox('Forecast', event.forecast?.toString() ?? 'N/A'),
//                       _valueBox('Actual', event.actual?.toString() ?? 'Pending', isHighlight: true),
//                       _valueBox('Previous', event.previous?.toString() ?? 'N/A'),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 12),
                
//                 // Impact Explanation
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: impactColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             size: 14,
//                             color: impactColor,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             isReleased ? 'HOW THIS AFFECTED GOLD:' : 'HOW THIS WILL AFFECT GOLD:',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: impactColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _getDetailedImpactExplanation(event, isReleased),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           height: 1.4,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 if (!isReleased) ...[
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFF9800).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.access_time, size: 14, color: Color(0xFFFF9800)),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Release time: ${DateFormat('HH:mm').format(iraqTime)} Iraqi Time',
//                             style: const TextStyle(fontSize: 11, color: Color(0xFFFF9800)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _valueBox(String label, String value, {bool isHighlight = false}) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
//             color: isHighlight ? const Color(0xFFD4AF37) : Colors.white70,
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _getDetailedImpactExplanation(EconomicEvent event, bool isReleased) {
//     final actual = event.actual;
//     final forecast = event.forecast;
    
//     // CPI Event
//     if (event.title.contains('CPI')) {
//       if (isReleased && actual != null && forecast != null) {
//         if (actual < forecast) {
//           return 'CPI came LOWER than expected (${actual}% vs ${forecast}%).\n\n'
//                  '• Lower inflation = Fed LESS likely to raise rates\n'
//                  '• Weaker US Dollar = Gold MORE attractive\n'
//                  '✅ BULLISH for Gold - Price expected to RISE';
//         } else if (actual > forecast) {
//           return 'CPI came HIGHER than expected (${actual}% vs ${forecast}%).\n\n'
//                  '• Higher inflation = Fed MORE likely to raise rates\n'
//                  '• Stronger US Dollar = Gold LESS attractive\n'
//                  '❌ BEARISH for Gold - Price expected to FALL';
//         }
//       } else {
//         return 'CPI measures inflation - KEY event for Gold\n\n'
//                '📊 If ACTUAL < FORECAST: Gold UP (weaker USD)\n'
//                '📊 If ACTUAL > FORECAST: Gold DOWN (stronger USD)\n\n'
//                '⏰ Release: ${DateFormat('HH:mm').format(event.eventTime.add(const Duration(hours: 3)))} Iraqi Time';
//       }
//     }
    
//     // Jobs Data
//     if (event.title.contains('Payrolls') || event.title.contains('Jobless')) {
//       if (isReleased && actual != null && forecast != null) {
//         if (actual < forecast) {
//           return 'Jobs MISSED expectations (${actual}k vs ${forecast}k).\n\n'
//                  '• Weaker job market = Economic concern\n'
//                  '• Fed may pause rate hikes\n'
//                  '• Investors seek safe-haven Gold\n'
//                  '✅ BULLISH for Gold - Price expected to RISE';
//         } else if (actual > forecast) {
//           return 'Jobs BEAT expectations (${actual}k vs ${forecast}k).\n\n'
//                  '• Strong job market = Economic growth\n'
//                  '• Fed may continue rate hikes\n'
//                  '• Investors move to risk assets\n'
//                  '❌ BEARISH for Gold - Price expected to FALL';
//         }
//       } else {
//         return 'Jobs data shows US employment health\n\n'
//                '📊 If ACTUAL < FORECAST: Weak jobs = Gold UP\n'
//                '📊 If ACTUAL > FORECAST: Strong jobs = Gold DOWN\n\n'
//                '⏰ Release: ${DateFormat('HH:mm').format(event.eventTime.add(const Duration(hours: 3)))} Iraqi Time';
//       }
//     }
    
//     // GDP
//     if (event.title.contains('GDP')) {
//       if (isReleased && actual != null && forecast != null) {
//         if (actual < forecast) {
//           return 'GDP MISSED expectations (${actual}% vs ${forecast}%).\n\n'
//                  '• Slower economic growth\n'
//                  '• Recession concerns increase\n'
//                  '• Gold demand rises as safe-haven\n'
//                  '✅ BULLISH for Gold';
//         }
//       } else {
//         return 'GDP measures US economic growth\n\n'
//                '📊 If ACTUAL < FORECAST: Slow growth = Gold UP\n'
//                '📊 If ACTUAL > FORECAST: Strong growth = Gold DOWN\n\n'
//                '⏰ Release: ${DateFormat('HH:mm').format(event.eventTime.add(const Duration(hours: 3)))} Iraqi Time';
//       }
//     }
    
//     // Generic
//     if (isReleased && actual != null && forecast != null) {
//       if (actual < forecast) {
//         return 'Actual (${actual}) BELOW Forecast (${forecast})\n\n'
//                '• Below expectations suggests weakness\n'
//                '• Increases safe-haven demand\n'
//                '✅ BULLISH for Gold';
//       } else if (actual > forecast) {
//         return 'Actual (${actual}) ABOVE Forecast (${forecast})\n\n'
//                '• Above expectations suggests strength\n'
//                '• Reduces safe-haven demand\n'
//                '❌ BEARISH for Gold';
//       }
//     }
    
//     return 'Monitor this economic event for Gold impact\n\n'
//            '📊 Below forecast = Typically BULLISH\n'
//            '📊 Above forecast = Typically BEARISH\n\n'
//            '⏰ Release: ${DateFormat('HH:mm').format(event.eventTime.add(const Duration(hours: 3)))} Iraqi Time';
//   }
// }

// // Add this enum at the bottom
// enum GoldImpact { bullish, bearish, neutral }





// --------- New Version ---------- //
// screens/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_news_analyzer/presentation/providers/analysis_provider.dart';
import 'package:gold_news_analyzer/screens/report_screen.dart';
import 'package:gold_news_analyzer/domain/entities/gold_analysis.dart';
import 'package:gold_news_analyzer/domain/entities/economic_event.dart';
import 'package:gold_news_analyzer/data/services/gold_price_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisNotifierProvider.notifier).loadAnalysis();
    });
    // Auto-refresh every 30 seconds for real-time data
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      ref.read(analysisNotifierProvider.notifier).refreshAnalysis();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisNotifierProvider);
    final isLoading = ref.watch(analysisLoadingProvider);
    final error = ref.watch(analysisErrorProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Gold Analyzer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white70),
            onPressed: () {
              if (analysisState.hasData && analysisState.analysis != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportScreen(analysis: analysisState.analysis!),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)))
                : const Icon(Icons.refresh, color: Colors.white70),
            onPressed: isLoading ? null : () async {
              await ref.read(analysisNotifierProvider.notifier).refreshAnalysis();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data refreshed'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(analysisState, isLoading, error),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: Text(
          '© 2026 Developed By Zinar Mizuri',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBody(AnalysisState state, bool isLoading, String? error) {
    if (isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
    }
    
    if (error != null && !state.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'ERROR FETCHING REAL DATA',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[300], fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(analysisNotifierProvider.notifier).loadAnalysis(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Retry Fetching Data',
                  style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '⚠️ Using fallback data is DISABLED for accuracy',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state.hasData && state.analysis != null) {
      return HomeContent(analysis: state.analysis!);
    }
    
    return Center(child: Text('No data', style: TextStyle(color: Colors.grey[500])));
  }
}

class HomeContent extends StatefulWidget {
  final GoldAnalysis analysis;
  
  const HomeContent({super.key, required this.analysis});
  
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double currentPrice;
  late DateTime lastUpdate;
  double previousPrice = 0;
  bool isRefreshing = false;
  Timer? _priceTimer;
  
  @override
  void initState() {
    super.initState();
    currentPrice = widget.analysis.currentGoldPrice;
    previousPrice = currentPrice;
    lastUpdate = widget.analysis.lastUpdate;
    _startLiveUpdates();
  }
  
  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }
  
  void _startLiveUpdates() {
    _priceTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshPriceOnly();
    });
  }
  
  Future<void> _refreshPriceOnly() async {
    try {
      final priceService = GoldPriceService();
      final newPrice = await priceService.forceRefreshPrice();
      
      if (mounted) {
        setState(() {
          previousPrice = currentPrice;
          currentPrice = newPrice;
          lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      // Silent fail for price updates
    }
  }
  
  Future<void> _manualRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    
    try {
      final priceService = GoldPriceService();
      final newPrice = await priceService.forceRefreshPrice();
      
      if (mounted) {
        setState(() {
          previousPrice = currentPrice;
          currentPrice = newPrice;
          lastUpdate = DateTime.now();
          isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }
  
  double get priceChange => currentPrice - previousPrice;
  bool get isPriceUp => priceChange >= 0;
  
  @override
  Widget build(BuildContext context) {
    final allEvents = widget.analysis.events;
    final now = DateTime.now();
    
    // Card 1: Last 24 hours and next 24 hours
    final last24hEvents = allEvents.where((e) => 
      e.eventTime.isAfter(now.subtract(const Duration(hours: 24))) &&
      e.eventTime.isBefore(now.add(const Duration(hours: 24)))
    ).toList();
    
    last24hEvents.sort((a, b) => a.eventTime.compareTo(b.eventTime));
    
    // Card 2: Gold Impact Events (upcoming only)
    final goldRelatedKeywords = [
  // FOMC Related - Add ALL variations
  'FOMC', 'Fed', 'Federal Reserve', 'Interest Rate Decision',
  'Rate Decision', 'Monetary Policy', 'Fed Chair',
  'Press Conference', 'FOMC Statement', 'Fed Press',
  'Powell', 'Jerome Powell', 'Fed Speech', 'Fed Talk',
  'Central Bank', 'Fed Meeting', 'FOMC Meeting',
  
  // Economic Data
  'CPI', 'Core CPI', 'PCE', 'Core PCE', 'PPI',
  'Non-Farm Payrolls', 'NFP', 'Unemployment', 'Jobless Claims',
  'ADP', 'GDP', 'Retail Sales', 'Consumer Confidence',
  'ISM', 'PMI', 'Industrial Production'
    ];
    
    final upcomingGoldEvents = allEvents.where((e) => 
      e.isUpcoming &&
      goldRelatedKeywords.any((keyword) => 
        e.title.toLowerCase().contains(keyword.toLowerCase())
      )
    ).toList();
    
    upcomingGoldEvents.sort((a, b) => a.eventTime.compareTo(b.eventTime));
    
    // Calculate real-time prediction based on released events in last 24h
    final releasedEvents = last24hEvents.where((e) => e.isReleased).toList();
    final bullishEvents = releasedEvents.where((e) => 
      e.impactType == GoldImpact.bullish
    ).toList();
    final bearishEvents = releasedEvents.where((e) => 
      e.impactType == GoldImpact.bearish
    ).toList();
    
    String prediction = 'NEUTRAL';
    Color predictionColor = Colors.grey;
    String predictionReason = 'No clear signal from recent events';
    
    if (bullishEvents.length > bearishEvents.length) {
      prediction = 'BULLISH';
      predictionColor = const Color(0xFF4CAF50);
      predictionReason = '${bullishEvents.length} bullish vs ${bearishEvents.length} bearish events in last 24h';
    } else if (bearishEvents.length > bullishEvents.length) {
      prediction = 'BEARISH';
      predictionColor = const Color(0xFFF44336);
      predictionReason = '${bearishEvents.length} bearish vs ${bullishEvents.length} bullish events in last 24h';
    } else if (bullishEvents.length > 0 && bearishEvents.length > 0) {
      prediction = 'BALANCED';
      predictionColor = Colors.orange;
      predictionReason = 'Equal bullish and bearish signals';
    }
    
    return RefreshIndicator(
      onRefresh: _manualRefresh,
      color: const Color(0xFFD4AF37),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gold Price Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('XAU/USD', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('LIVE', style: TextStyle(fontSize: 9, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPriceUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 10,
                              color: isPriceUp ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              priceChange.abs().toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 10,
                                color: isPriceUp ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${DateFormat('HH:mm:ss').format(lastUpdate)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, size: 10, color: Colors.white38),
                        SizedBox(width: 4),
                        Text('Pull down to refresh', style: TextStyle(color: Colors.white38, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // REAL-TIME PREDICTION CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: predictionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: predictionColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '📊 REAL-TIME GOLD PREDICTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prediction,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: predictionColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    predictionReason,
                    style: TextStyle(
                      fontSize: 12,
                      color: predictionColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Based on ${releasedEvents.length} released events in last 24h',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Card 1: Last 24 Hours Events
            _buildLast24hCard(last24hEvents),
            
            const SizedBox(height: 16),
            
            // Card 2: Gold Impact Events
            _buildGoldImpactCard(upcomingGoldEvents),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLast24hCard(List<EconomicEvent> events) {
    final released = events.where((e) => e.isReleased).toList();
    final upcoming = events.where((e) => e.isUpcoming).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Last 24 Hours Events',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length} events',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _statChip('Released', released.length, const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                _statChip('Upcoming', upcoming.length, const Color(0xFFFF9800)),
                const Spacer(),
                Text(
                  'Iraq Time (UTC+3)',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          ),
          
          // Events List
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No events in the last/next 24 hours',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                return _compactEventTile(events[index]);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildGoldImpactCard(List<EconomicEvent> events) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFFD4AF37), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Gold Impact Events',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length} upcoming',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                  ),
                ),
              ],
            ),
          ),
          
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'High-impact events affecting XAUUSD',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const Spacer(),
                Text(
                  'Iraq Time (UTC+3)',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          ),
          
          // Events List
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No upcoming gold-impact events',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                return _compactEventTile(events[index]);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
  
  Widget _compactEventTile(EconomicEvent event) {
    final iraqTime = event.eventTime.add(const Duration(hours: 3));
    final isReleased = event.isReleased;
    
    Color impactColor;
    if (event.impact == ImpactLevel.high) {
      impactColor = const Color(0xFFF44336);
    } else if (event.impact == ImpactLevel.medium) {
      impactColor = const Color(0xFFFF9800);
    } else {
      impactColor = const Color(0xFF9E9E9E);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: impactColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isReleased 
                      ? const Color(0xFF4CAF50).withOpacity(0.15) 
                      : const Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isReleased ? 'RELEASED' : 'UPCOMING',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isReleased ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM, HH:mm').format(iraqTime),
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: impactColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event.impact == ImpactLevel.high ? 'HIGH' : 
                  event.impact == ImpactLevel.medium ? 'MED' : 'LOW',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: impactColor,
                  ),
                ),
              ),
              const Spacer(),
              if (isReleased && event.actual != null) ...[
                Text(
                  'Actual: ${event.actual}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: event.impactType == GoldImpact.bullish 
                        ? const Color(0xFF4CAF50) 
                        : event.impactType == GoldImpact.bearish 
                            ? const Color(0xFFF44336) 
                            : const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Forecast: ${event.forecast ?? 'N/A'}',
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
                if (event.previous != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Prev: ${event.previous}',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ] else if (!isReleased && event.forecast != null) ...[
                Text(
                  'Forecast: ${event.forecast}',
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum GoldImpact { bullish, bearish, neutral }