import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskLinearGraph extends StatelessWidget {
  final List<TaskData> taskData;

  const TaskLinearGraph({super.key, required this.taskData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  // titlesData: FlTitlesData(
                  //   leftTitles: SideTitles(showTitles: true),
                  //   bottomTitles: SideTitles(
                  //     showTitles: true,
                  //     getTitlesWidget: (value, _) => Text(
                  //       _formatDate(value.toInt()),
                  //       style: const TextStyle(fontSize: 10),
                  //     ),
                  //   ),
                  // ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: taskData.length.toDouble() - 1,
                  minY: 0,
                  maxY: taskData.map((e) => e.completed).reduce((a, b) => a > b ? a : b).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                      color: Colors.blue,
                      barWidth: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return taskData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.completed.toDouble()))
        .toList();
  }

  String _formatDate(int index) {
    final date = taskData[index].date;
    return '${date.day}/${date.month}';
  }
}

class TaskData {
  final DateTime date;
  final int completed;

  TaskData({required this.date, required this.completed});
}
