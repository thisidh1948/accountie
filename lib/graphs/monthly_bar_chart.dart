import 'dart:math';

import 'package:accountie/models/monthy_data.dart';
import 'package:accountie/util/calculator.dart';
import 'package:accountie/util/number_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyData> monthlyDataList;
  final bool isLoading;

  const MonthlyBarChart({
    Key? key,
    required this.monthlyDataList,
    this.isLoading = false,
  }) : super(key: key);


  List<BarChartGroupData> buildGroupedBarChart(List<MonthlyData> data) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < data.length; i++) {
      final month = data[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: month.income,
                color: Colors.green,
                width: 8,
                borderRadius: BorderRadius.circular(4)),
            BarChartRodData(
                toY: month.expense,
                color: Colors.red,
                width: 8,
                borderRadius: BorderRadius.circular(4)),
          ],
          barsSpace: 4,
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {

    double _maxValue = getMaxValue(monthlyDataList);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (monthlyDataList.isEmpty) {
      return Container(
        height: 300, // Set a fixed height or adjust as needed
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Monthly Overview',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Flexible(
          child: SizedBox(
            height: 350,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: max(MediaQuery.of(context).size.width,
                    monthlyDataList.length * 60),
                child: BarChart(
                  BarChartData(
                    maxY: _maxValue,
                    minY: 0,
                    barGroups: buildGroupedBarChart(monthlyDataList),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _maxValue / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < monthlyDataList.length) {
                              final income = monthlyDataList[index].income;
                              final expense = monthlyDataList[index].expense;
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          40), // Adjust the maxHeight as needed
                                  child: Column(
                                    children: [
                                      Text(
                                        NumberFormatter.formatIndianNumber(
                                            income),
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.green.shade400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        NumberFormatter.formatIndianNumber(
                                            expense),
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.red.shade400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            String monthYear = monthlyDataList[value.toInt()].monthYear;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                monthYear,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              NumberFormatter.formatIndianNumber(value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String label = rodIndex == 0 ? 'Income' : 'Expense';
                          return BarTooltipItem(
                            '$label: ${NumberFormatter.formatIndianNumber(rod.toY)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
