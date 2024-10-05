import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AirQuality extends StatefulWidget {
  @override
  _AirQualityState createState() => _AirQualityState();
}

class _AirQualityState extends State<AirQuality> {
  DateTime? selectedDate;
  double airQualityValue = 0.0; // لتخزين قيمة جودة الهواء
  List<FlSpot> airQualityData = []; // لتخزين بيانات الرسم البياني

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await fetchAirQualityData(selectedDate!);
    }
  }

  Future<void> fetchAirQualityData(DateTime date) async {
    final jsonDate = jsonEncode({'date': date.toIso8601String().split('T')[0]});
    print('JSON Date: $jsonDate'); // للتصحيح

    try {
      final response = await http.post(
        Uri.parse('https://flaskappproject-production.up.railway.app/predict-air-quality'),
        headers: {'Content-Type': 'application/json'},
        body: jsonDate,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // استخراج القيمة المتوقعة
        final predicted = jsonData['Predicted'] as Map<String, dynamic>;
        final double predictedValue = predicted.values.first.toDouble();

        // استخراج بيانات PM2 التاريخية
        final List<dynamic> data = jsonData['data'];

        // تجهيز بيانات جودة الهواء للرسم البياني
        setState(() {
          airQualityValue = predictedValue;
          airQualityData = data.asMap().entries.map((entry) {
            int index = entry.key;
            double value = double.tryParse(entry.value['PM2'].toString()) ?? 0.0;
            return FlSpot(index.toDouble(), value);
          }).toList();
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedDate != null) ...[
              Text(
                'Date: ${selectedDate!.toIso8601String().split('T').first}',
                style: const TextStyle(fontSize: 20,color: Colors.white),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: const Text('pick date'),
            ),
            const SizedBox(height: 20),
            if (airQualityData.isNotEmpty) ...[
              Text(
                'Predicted Air Quality: ${airQualityValue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20,color: Colors.white),
              ),
              const SizedBox(height: 20),
              Container(
                height: 300, // الاحتفاظ بالارتفاع الأصلي
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
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    // احصل على أكبر قيمة من البيانات التاريخية
    double maxHistoricalValue = airQualityData.isNotEmpty
        ? airQualityData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // احسب الحد الأقصى للقيمة على محور Y
    double maxY = airQualityValue > maxHistoricalValue ? airQualityValue + 5 : maxHistoricalValue + 5;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
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
            interval: 1, // يمكنك تعديل الفاصل إذا رغبت في تقليل الأرقام
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              if (value % 1 == 0) {
                return Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white));
              }
              return Container();
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // إزالة الحدود
      ),
      minX: 0,
      maxX: airQualityData.isNotEmpty ? airQualityData.length.toDouble() : 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // نقاط البيانات التاريخية باللون الأزرق
        LineChartBarData(
          spots: airQualityData,
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, x, y, isCurved) => FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
            ),
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
        // القيمة المتوقعة كنقطة حمراء
        LineChartBarData(
          spots: [FlSpot(airQualityData.length.toDouble(), airQualityValue)],
          isCurved: false,
          color: Colors.red,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, x, y, isCurved) => FlDotCirclePainter(
              radius: 6,
              color: Colors.red,
            ),
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

    if (value.toInt() < airQualityData.length) {
      return Text((value.toInt() + 1).toString(), style: style);
    }
    return const Text('pre', style: style);
  }
}
