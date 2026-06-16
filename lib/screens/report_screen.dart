import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gold_news_analyzer/domain/entities/gold_analysis.dart';
import 'package:gold_news_analyzer/domain/entities/economic_event.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatelessWidget {
  final GoldAnalysis analysis;
  
  const ReportScreen({super.key, required this.analysis});
  
  @override
  Widget build(BuildContext context) {
    final isBullish = analysis.bullishProbability > analysis.bearishProbability;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Full Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
         leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.grey),
    onPressed: () => Navigator.of(context).pop(),
  ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isBullish ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'GOLD OUTLOOK',
                    style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.expectedDirection,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${analysis.confidenceLevel} Confidence • ${analysis.confidence.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Scores Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${analysis.bullishScore}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BULLISH SCORE',
                          style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${analysis.bearishScore}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF44336),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BEARISH SCORE',
                          style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chart Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EVENT DISTRIBUTION',
                    style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: analysis.bullishCount.toDouble(),
                                  title: analysis.bullishCount.toString(),
                                  color: const Color(0xFF4CAF50),
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: analysis.bearishCount.toDouble(),
                                  title: analysis.bearishCount.toString(),
                                  color: const Color(0xFFF44336),
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: analysis.neutralCount.toDouble(),
                                  title: analysis.neutralCount.toString(),
                                  color: Colors.grey[600]!,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 35,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legendItem(const Color(0xFF4CAF50), 'Bullish', analysis.bullishCount),
                              const SizedBox(height: 12),
                              _legendItem(const Color(0xFFF44336), 'Bearish', analysis.bearishCount),
                              const SizedBox(height: 12),
                              _legendItem(Colors.grey[600]!, 'Neutral', analysis.neutralCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Events List
            const Text(
              'ALL EVENTS',
              style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analysis.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _eventTile(analysis.events[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ($count)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
  
  Widget _eventTile(EconomicEvent event) {
    final impactColor = event.impactType == GoldImpact.bullish 
        ? const Color(0xFF4CAF50)
        : event.impactType == GoldImpact.bearish 
            ? const Color(0xFFF44336) 
            : Colors.grey[600]!;
    
    final bool isReleased = event.isReleased;
    final iraqTime = event.eventTime.add(const Duration(hours: 3));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 20, color: impactColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isReleased 
                      ? const Color(0xFF4CAF50).withOpacity(0.15) 
                      : const Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isReleased ? 'RELEASED' : 'UPCOMING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isReleased ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Time Row
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('HH:mm').format(iraqTime)} Iraqi Time',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(width: 16),
              Text(
                '${event.currency} • ${_getImpactLevel(event.impact)}',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          
          if (isReleased && event.actual != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoBox('Forecast', event.forecast?.toString() ?? 'N/A'),
                  _infoBox('Actual', event.actual.toString(), isHighlight: true),
                  _infoBox('Previous', event.previous?.toString() ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: impactColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDetailedImpact(event),
                style: TextStyle(fontSize: 11, color: impactColor, height: 1.4),
              ),
            ),
          ] else if (!isReleased) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Color(0xFFFF9800)),
                  const SizedBox(width: 8),
                  Text(
                    'Scheduled for ${DateFormat('HH:mm').format(iraqTime)} Iraqi time',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFFF9800)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _infoBox(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? const Color(0xFFD4AF37) : Colors.white70,
          ),
        ),
      ],
    );
  }
  
  String _getImpactLevel(ImpactLevel level) {
    switch (level) {
      case ImpactLevel.high: return 'HIGH IMPACT';
      case ImpactLevel.medium: return 'MEDIUM IMPACT';
      case ImpactLevel.low: return 'LOW IMPACT';
    }
  }
  
  String _getDetailedImpact(EconomicEvent event) {
    if (event.title.contains('CPI')) {
      if (event.actual! < event.forecast!) {
        return '📉 CPI came LOWER than forecast (${event.actual}% vs ${event.forecast}%)\n→ Less inflation pressure → Weaker USD\n→ Gold expected to RISE 📈';
      } else if (event.actual! > event.forecast!) {
        return '📈 CPI came HIGHER than forecast (${event.actual}% vs ${event.forecast}%)\n→ More inflation pressure → Stronger USD\n→ Gold expected to FALL 📉';
      }
    }
    
    if (event.title.contains('Non-Farm Payrolls') || event.title.contains('Jobless')) {
      if (event.actual! < event.forecast!) {
        return '📉 Jobs MISSED forecast (${event.actual}k vs ${event.forecast}k)\n→ Weaker economy → Safe-haven demand\n→ Gold expected to RISE 📈';
      } else if (event.actual! > event.forecast!) {
        return '📈 Jobs BEAT forecast (${event.actual}k vs ${event.forecast}k)\n→ Stronger economy → Risk-on sentiment\n→ Gold expected to FALL 📉';
      }
    }
    
    if (event.title.contains('GDP')) {
      if (event.actual! < event.forecast!) {
        return '📉 GDP MISSED forecast (${event.actual}% vs ${event.forecast}%)\n→ Economic slowdown\n→ Gold expected to RISE 📈';
      }
    }
    
    if (event.actual! < event.forecast!) {
      return '📉 Actual (${event.actual}) BELOW Forecast (${event.forecast})\n→ Below expectations\n→ Gold expected to RISE 📈';
    } else {
      return '📈 Actual (${event.actual}) ABOVE Forecast (${event.forecast})\n→ Above expectations\n→ Gold expected to FALL 📉';
    }
  }
}

enum GoldImpact { bullish, bearish, neutral }