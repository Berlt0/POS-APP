import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/widgets/legend.dart';

class RcogspChartWidget extends StatefulWidget {

  final List<Map<String, dynamic>> rcogsp;
  final bool isLoading;

  const RcogspChartWidget({
    super.key,
    required this.rcogsp,
    this.isLoading = false
    
    });

  @override
  State<RcogspChartWidget> createState() => _RcogspState();
}

class _RcogspState extends State<RcogspChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 20, 8, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              LegendItem(color: Colors.blue, text: 'Revenue'),
              SizedBox(width: 12),
              LegendItem(color: Colors.red, text: 'COGS'),
              SizedBox(width: 12),
              LegendItem(color: Colors.green, text: 'Profit'),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: List.generate(widget.rcogsp.length, (index) {
                final item = widget.rcogsp[index];
            
            return BarChartGroupData(
                  x: index,
                  barRods: [
                    
                    BarChartRodData(
                      toY: item['revenue'],
                      width: 8,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
            
                    
                    BarChartRodData(
                      toY: item['cogs'],
                      width: 8,
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
            
                    
                    BarChartRodData(
                      toY: item['profit'],
                      width: 8,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('₱${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
            
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= widget.rcogsp.length) {
                        return const SizedBox.shrink();
                      }
            
                      final date = DateFormat('MM/dd')
                          .format(DateTime.parse(widget.rcogsp[index]['date']));
            
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(date, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
            
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
                ),
          ),
        ],
      )


    );
  }
}