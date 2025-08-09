import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BookingLineChart extends StatelessWidget {
  final List<double> timeStamps = [1.01, 1.02, 1.03, 1.04, 1.05, 1.06];
  final List<int> bookings = [20, 15, 20, 50, 10, 100];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(timeStamps.length, (i) =>
                  FlSpot(timeStamps[i], bookings[i].toDouble())),
                isCurved: true,
                barWidth: 3,
                color: Colors.blueAccent,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blueAccent.withOpacity(0.3),
                ),
                dotData: FlDotData(show: true),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.01,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
