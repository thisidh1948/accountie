import 'package:accountie/models/monthy_data.dart';
import 'package:accountie/util/number_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MontlyLineChart extends StatelessWidget {
  final List<MonthlyData> monthlyData;
  const MontlyLineChart({Key? key, required this.monthlyData}) : super(key: key);

  String _monthShortName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return names[month];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    final List<String> xLabels = [];
    for (int i = 0; i < monthlyData.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), monthlyData[i].income));
      expenseSpots.add(FlSpot(i.toDouble(), monthlyData[i].expense));
      final monthStr = _monthShortName(monthlyData[i].month);
      final yearStr = monthlyData[i].year.toString().substring(2);
      xLabels.add('$monthStr$yearStr');
    }

    final double maxY = [
      ...monthlyData.map((d) => d.income),
      ...monthlyData.map((d) => d.expense)
    ].fold<double>(0, (prev, e) => e > prev ? e : prev);

    // Calculate width: 80px per month, min 350
    final double chartWidth = (monthlyData.length * 80).toDouble().clamp(350, 99999);

    return SizedBox(
            width: chartWidth,
            height: 450,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY == 0 ? 1000 : maxY * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.red,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < xLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(xLabels[idx],
                                  style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY > 0 ? maxY / 5 : 200,
                        getTitlesWidget: (value, _) => Text(NumberFormatter.formatIndianNumber(value), style: const TextStyle(fontSize: 8)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          );
  }
}
