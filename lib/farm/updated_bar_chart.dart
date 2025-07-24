import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constants/colors.dart'; // Assuming this path is correct

class _BarChart extends StatefulWidget {
  const _BarChart();

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  List<(DateTime, double)>? _sensorValues;
  late TransformationController _transformationController;
  final bool _isPanEnabled = true;
  final bool _isScaleEnabled = true;

  // --- Configuration for initial zoom and label visibility ---
  static const int _totalBars = 96; // Total number of data points
  static const int _desiredVisibleBarsAtStart =
      6; // How many bars to show initially
  static const double _initialScale =
      _totalBars /
      _desiredVisibleBarsAtStart; // Calculated initial zoom factor (16.0)

  // Track the current scale to adjust label density dynamically
  double _currentScale = _initialScale;

  @override
  void initState() {
    _reloadData();
    _transformationController = TransformationController();
    _transformationController.value = Matrix4.identity()
      ..scale(_initialScale, 1.0);
    // Listen for changes in the transformation controller's value
    _transformationController.addListener(_onTransformationChanged);
    super.initState();
  }

  // Listener for TransformationController changes to update _currentScale
  void _onTransformationChanged() {
    // Extract the effective scale from the transformation matrix
    // getMaxScaleOnAxis() returns the maximum scale factor on any axis.
    // Since we only scale horizontally, this gives us our horizontal scale.
    final newScale = _transformationController.value.getMaxScaleOnAxis();

    // Only update state if the scale has significantly changed
    // This prevents excessive widget rebuilds during subtle pan/zoom movements
    if ((newScale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = newScale;
      });
    }
  }

  // Method to load data from JSON asset
  void _reloadData() async {
    try {
      final dataStr = await rootBundle.loadString('assets/farm/test.json');
      if (!mounted) {
        return; // Widget no longer in tree, no need to update state
      }
      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      setState(() {
        _sensorValues = (json['data'] as List).map((item) {
          final timestampString = item[0] as String; // "2024-01-01T00:00:00Z"
          final DateTime dateTime = DateTime.parse(timestampString);

          // Robust conversion for value, handling int, double, or string
          final dynamic rawValue = item[1];
          double value;
          if (rawValue is int) {
            value = rawValue.toDouble();
          } else if (rawValue is double) {
            value = rawValue;
          } else {
            // Attempt to parse if it's a string or other unexpected type
            value = double.tryParse(rawValue.toString()) ?? 0.0;
            if (value == 0.0 && rawValue != 0 && rawValue != 0.0) {
              // Log a warning if parsing failed and the original value wasn't 0
              // print(
              //   'Warning: Failed to parse value: $rawValue (${rawValue.runtimeType}) to double, defaulting to 0.0',
              // );
            }
          }
          return (dateTime, value);
        }).toList();
      });
    } catch (e) {
      // Handle potential errors during data loading or parsing
      print('Error loading or parsing sensor data: $e');
      if (mounted) {
        setState(() {
          _sensorValues = []; // Set to empty list to show empty chart
        });
      }
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load chart data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the maximum Y value dynamically, or keep it fixed
    // double maxY = _sensorValues != null && _sensorValues!.isNotEmpty
    //     ? _sensorValues!.map((e) => e.$2).reduce(max) * 1.2 // 20% padding
    //     : 30.0; // Default if no data

    return BarChart(
      BarChartData(
        barGroups:
            _sensorValues?.asMap().entries.map((e) {
              final index = e.key;
              final value = e.value.$2;

              return BarChartGroupData(
                x: index,
                barRods: [BarChartRodData(toY: value, gradient: _barsGradient)],
                showingTooltipIndicators: [0],
              );
            }).toList() ??
            [],
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 30, // Keeping fixed maxY as per your original code
      ),
      transformationConfig: FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        minScale: 1.0, // Allows zooming out to show all 96 bars
        maxScale: _totalBars
            .toDouble(), // Allows zooming in to see individual bars very clearly (e.g., 96x)
        panEnabled: _isPanEnabled,
        scaleEnabled: _isScaleEnabled,
        transformationController: _transformationController,
      ),
      duration: Duration.zero, // No animation on data updates
    );
  }

  @override
  void dispose() {
    _transformationController.removeListener(
      _onTransformationChanged,
    ); // Remove listener
    _transformationController.dispose();
    super.dispose();
  }

  // --- Bar Touch Data (Tooltips) ---
  BarTouchData get barTouchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) =>
          Colors.transparent, // Transparent background for tooltip
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem:
          (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            // Safety check for tooltip
            if (_sensorValues == null ||
                groupIndex < 0 ||
                groupIndex >= _sensorValues!.length) {
              return null; // Don't show tooltip if data is unavailable or out of bounds
            }
            final date = _sensorValues![groupIndex].$1;
            return BarTooltipItem(
              // Format for tooltip: Value \n HH:MM
              '${rod.toY.round()}',
              TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            );
          },
    ),
  );

  // --- X-Axis Titles (Dynamic Visibility) ---
  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryPurple,
    );

    // Safety checks for sensorValues and index bounds
    if (_sensorValues == null ||
        value.toInt() < 0 ||
        value.toInt() >= _sensorValues!.length) {
      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text('', style: style), // Return empty text to hide label
      );
    }

    final date = _sensorValues![value.toInt()].$1;

    // --- Dynamic Label Logic based on _currentScale ---
    int labelInterval;
    // These thresholds determine how many labels are visible at different zoom levels.
    // Adjust these values based on visual testing to achieve desired density.
    if (_currentScale <= 1.5) {
      // When zoomed out (all 96 bars visible), show every 16th label (96/16 = 6 labels)
      labelInterval = 16;
    } else if (_currentScale <= 4.0) {
      // Slightly zoomed in, show every 8th label
      labelInterval = 8;
    } else if (_currentScale <= 8.0) {
      // More zoomed in, show every 4th label
      labelInterval = 4;
    } else if (_currentScale <= 12.0) {
      // Closer in, show every 2nd label
      labelInterval = 2;
    } else {
      // Highly zoomed in (includes the initial 16x zoom), show every label
      labelInterval = 1;
    }

    // Only render the label if the current bar's index is a multiple of the calculated interval
    if (value.toInt() % labelInterval != 0) {
      return Container(); // Hide the label by returning an empty widget
    }
    // --- End Dynamic Label Logic ---

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}',
        style: style,
      ),
    );
  }

  // --- FlTitlesData (Axis Configuration) ---
  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30, // Space reserved for the titles
        getTitlesWidget: getTitles, // Our custom dynamic title widget
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ), // Hide left labels
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ), // Hide top labels
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ), // Hide right labels
  );

  // --- Border Data ---
  FlBorderData get borderData => FlBorderData(show: false); // No border

  // --- Bar Gradient ---
  LinearGradient get _barsGradient => LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryRed],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // Utility function for two-digit formatting
  String twoDigits(int n) => n.toString().padLeft(2, '0');
}

// This wrapper widget provides the AspectRatio and the decorative container
// It remains largely the same as you provided
class UpdatedBarChart extends StatefulWidget {
  const UpdatedBarChart({super.key});

  @override
  State<StatefulWidget> createState() => UpdatedBarChartState();
}

class UpdatedBarChartState extends State<UpdatedBarChart> {
  @override
  Widget build(BuildContext context) {
    BorderRadius bigRadius = BorderRadius.circular(20.0);
    double blur = 15.0;
    Offset distance = Offset(10, 10);
    final width = MediaQuery.of(context).size.width / 1.11;
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: bigRadius,
        color: AppColors.pageBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: AppColors.bottomShadow,
          ),
        ],
      ),
      child: AspectRatio(aspectRatio: 1.6, child: _BarChart()),
    );
  }
}
