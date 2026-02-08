import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/widgets/legend.dart';

class SaleChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> salesTrend;
  final bool isLoading;
  final String selectedFilter; 
  

  const SaleChartWidget({
    super.key,
    required this.salesTrend,
    this.isLoading = false,
    required this.selectedFilter,
  });

  @override
  State<SaleChartWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SaleChartWidget> {
  @override
  Widget build(BuildContext context) {

if (widget.selectedFilter == 'Today') {
    debugPrint('Sales Trend Data for Today: ${widget.salesTrend}');
    if (widget.salesTrend.isNotEmpty) {
      debugPrint('First date sample: ${widget.salesTrend[0]['date']}');
    }
  }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendItem(
              color: Color.fromARGB(255, 14, 68, 161),
              text: 'Revenue',
            ),
            SizedBox(width: 16),
            LegendItem(
              color: Color.fromARGB(255, 255, 152, 0),
              text: 'Sales',
            ),
          ],
        ),

        const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();

                        if (index >= 0 && index < widget.salesTrend.length) {
                          final dateTime = DateTime.parse(widget.salesTrend[index]['date']);
                          
                          if (widget.selectedFilter == 'Today') {
                           
                            final hour = DateFormat('ha').format(dateTime); 
                            return Text(hour, style: TextStyle(fontSize: 10));
                          } else {
                           
                            final date = DateFormat('MM/dd').format(dateTime);
                            return Text(date, style: TextStyle(fontSize: 10));
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        
                        if (touchedSpot.barIndex == 0) {
                          final index = touchedSpot.spotIndex;
                           final dateTime = DateTime.parse(widget.salesTrend[index]['date']);

                          final label =  widget.selectedFilter == 'Today'
                            ? DateFormat('ha').format(dateTime) 
                            : DateFormat('MM/dd').format(dateTime);

                          final revenue = widget.salesTrend[index]['revenue'] as double;
                          final totalSales = widget.salesTrend[index]['totalSales'];
            
                          return LineTooltipItem(
                            '$label\nRevenue: ₱${revenue.toStringAsFixed(2)}\nSales: $totalSales',
                            TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } 
                        return null;
                        
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      widget.salesTrend.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        widget.salesTrend[index]['revenue'] as double,
                      ),
                    ),
                    isCurved: true,
                    color: const Color.fromARGB(255, 14, 68, 161),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromARGB(
                        100,
                        14,
                        68,
                        161,
                      ), // color with opacity
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(150, 14, 68, 161), // top color
                          Color.fromARGB(0, 14, 68, 161), // bottom color (fade)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      widget.salesTrend.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        (widget.salesTrend[index]['totalSales'] ?? 0).toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: const Color.fromARGB(255, 255, 152, 0),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromARGB(
                        100,
                        255,
                        153,
                        0,
                      ), // color with opacity
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(160, 255, 153, 0), // top color
                          Color.fromARGB(0, 255, 153, 0), // bottom color (fade)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
