import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:nasaspaceapps/models/colors.dart';

class Soilchart extends StatefulWidget {
  const Soilchart({super.key});

  @override
  State<Soilchart> createState() => _SoilchartState();
}

class _SoilchartState extends State<Soilchart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  double predictedData = 0.0;
  List<FlSpot> historicalData = [];

  @override
  void initState() {
    super.initState();
    fetchSoilData();
  }

  Future<void> fetchSoilData() async {
    try {
      final response = await http.post(
        Uri.parse('https://flaskappproject-production.up.railway.app/predict-soil'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      // Debugging output
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final double predictedValue = double.tryParse(jsonData['Predicted'].toString()) ?? 0.0;

        // Process historical data
        final List<dynamic> data = jsonData['data'];
        // Update state to refresh the UI with both predicted and historical data
        setState(() {
          predictedData = predictedValue;
          historicalData = data.asMap().entries.map((entry) {
            int index = entry.key;
            double value = double.tryParse(entry.value['Soil_Moisture'].toString()) ?? 0.0;
            return FlSpot(index.toDouble(), value);
          }).toList();
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load soil data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  String getSoilMoistureCategory(double moisture) {
    if (moisture < 0.10) return 'Very Dry';
    if (moisture < 0.18) return 'Dry';
    if (moisture < 0.27) return 'Moderate';
    if (moisture < 0.40) return 'Wet';
    return 'Very Wet';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Data Prediction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Predicted Soil Moisture for Tomorrow:',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              predictedData.toStringAsFixed(2),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${getSoilMoistureCategory(predictedData)}',
              style: const TextStyle(fontSize: 20, color: Colors.red),
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
    double maxY = predictedData + 0.1; // Set the max y value based on predictedData
    double minY = (predictedData - 0.1).clamp(0.0, double.infinity); // Set min y to avoid negative values

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 0.05,
        verticalInterval: 0.05,
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
            interval: 0.05,
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
      maxX: historicalData.isNotEmpty ? (historicalData.length).toDouble() : 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: historicalData,
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
          spots: [FlSpot(historicalData.length.toDouble(), predictedData)],
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

    if (value.toInt() < historicalData.length) {
      return Text((value.toInt() + 1).toString(), style: style);
    }
    return const Text('TM', style: style);
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
