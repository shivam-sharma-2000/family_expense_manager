import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseBarChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final String categoryCase;

  final List<Color> incomeColors = [
    const Color(0xFF006400), // Dark Green
    const Color(0xFF008000),
    const Color(0xFF228B22),
    const Color(0xFF32CD32),
    const Color(0xFF90EE90), // Light Green
  ];

  final List<Color> expenseColors = [
    const Color(0xFF8B0000), // Dark Red
    const Color(0xFFA50000),
    const Color(0xFFB22222),
    const Color(0xFFDC143C),
    const Color(0xFFFF6347), // Light Red / Tomato
  ];

  ExpenseBarChart({
    Key? key,
    required this.categoryTotals,
    required this.categoryCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top5 = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,

        /// Built-in legend
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),

        /// X Axis (no grid)
        primaryXAxis: const CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(size: 0),
          axisLine: AxisLine(width: 0),
        ),

        /// Y Axis (no grid)
        primaryYAxis: const NumericAxis(
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(size: 0),
          axisLine: AxisLine(width: 0),
        ),

        series: <CartesianSeries>[
          ColumnSeries<MapEntry<String, double>, String>(
            dataSource: top5.take(5).toList(),
            xValueMapper: (e, _) => e.key,
            yValueMapper: (e, _) => e.value.abs(),
            name: categoryCase == 'expense' ? 'Top Expenses' : "Top Incomes",
            pointColorMapper: (e, index) => categoryCase == 'expense'
                ? expenseColors[index % expenseColors.length]
                : incomeColors[index % incomeColors.length],
            borderRadius: BorderRadius.circular(6),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
