import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:nasaspaceapps/models/colors.dart';

class Droughtchart extends StatefulWidget {
  const Droughtchart({super.key});

  @override
  State<Droughtchart> createState() => _DroughtchartState();
}

class _DroughtchartState extends State<Droughtchart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  double predictedDrought = 0.0;
  List<FlSpot> droughtData = [];

  @override
  void initState() {
    super.initState();
    fetchDroughtData();
  }

  Future<void> fetchDroughtData() async {
    try {
      final response = await http.post(
        Uri.parse('https://flaskappproject-production.up.railway.app/predict-drought'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      // Debugging output
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final double predictedValue = double.tryParse(jsonData['Predicted']["2024-10-08 00:00:00"].toString()) ?? 0.0;

        // Process drought data
        final List<dynamic> data = jsonData['data'];
        droughtData = data.asMap().entries
            .where((entry) {
              final value = double.tryParse(entry.value['Date'].toString());
              return value != null && !value.isNaN; // Only include valid, non-NaN values
            })
            .map((entry) {
              int index = entry.key;
              double value = double.tryParse(entry.value['Date'].toString()) ?? 0.0;
              return FlSpot(index.toDouble(), value);
            })
            .toList();

        // Assign predicted value
        setState(() {
          predictedDrought = predictedValue.isNaN ? 0.0 : predictedValue;
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load drought data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  String getDroughtCategory(double index) {
    if (index < 0.10) return 'No Drought';
    if (index < 0.20) return 'Mild Drought';
    if (index < 0.30) return 'Moderate Drought';
    if (index < 0.40) return 'Severe Drought';
    return 'Extreme Drought';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drought Data Prediction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Predicted Drought Index for next week:',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              predictedDrought.toStringAsFixed(2),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${getDroughtCategory(predictedDrought)}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    double minY = droughtData.isNotEmpty ? droughtData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) : 0;
    double maxY = droughtData.isNotEmpty ? droughtData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0.5;

    // Adjust maxY to account for predicted drought if it's higher than historical data
    maxY = predictedDrought > maxY ? predictedDrought : maxY;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (maxY - minY) / 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blueGrey,
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY - minY) / 5,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: droughtData.isNotEmpty ? 10.0 : 1,  // Adjusted maxX to support red point placement near 10
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: droughtData,
          isCurved: true,
          color: Colors.blue,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
        LineChartBarData(
          spots: [FlSpot(10, predictedDrought)],  // Red point near number 10
          isCurved: false,
          color: Colors.red,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
      backgroundColor: Colors.transparent,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,
    );

    if (value.toInt() < droughtData.length) {
      return Text((value.toInt() + 1).toString(), style: style);
    }
    return const Text('NW', style: style);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.white,
    );
    return Text(value.toStringAsFixed(2), style: style, textAlign: TextAlign.left);
  }
}
