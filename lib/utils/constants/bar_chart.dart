import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class _BarChart extends StatelessWidget {
  final List<int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem:
          (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            );
          },
    ),
  );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryPurple,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Te';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Tu';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get borderData => FlBorderData(show: false);

  LinearGradient get _barsGradient => LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryRed],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups => List.generate(
    data.length,
    (index) => BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(toY: data[index].toDouble(), gradient: _barsGradient),
      ],
      showingTooltipIndicators: [0],
    ),
  );
}

class SensorBarChart extends StatefulWidget {
  final List<int> data;
  const SensorBarChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => SensorBarChartState();
}

class SensorBarChartState extends State<SensorBarChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1.6, child: _BarChart(data: widget.data));
  }
}
