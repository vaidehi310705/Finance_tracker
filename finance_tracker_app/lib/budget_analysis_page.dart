import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetAnalysisPage extends StatelessWidget {
  final List<Map<String, dynamic>> insights = [
    {"Category": "Food", "Amount": 200, "Spending Category": "Moderate Spending"},
    {"Category": "Transport", "Amount": 100, "Spending Category": "Low Spending"},
    {"Category": "Rent", "Amount": 1000, "Spending Category": "High Spending"},
    {"Category": "Entertainment", "Amount": 150, "Spending Category": "Low Spending"},
    {"Category": "Utilities", "Amount": 300, "Spending Category": "Moderate Spending"},
    {"Category": "Shopping", "Amount": 400, "Spending Category": "Moderate Spending"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text("Budget Analysis"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: insights.map((data) {
                    return PieChartSectionData(
                      value: data["Amount"].toDouble(),
                      title: data["Category"],
                      color: _getCategoryColor(data["Spending Category"]),
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            // List View for Insights
            Expanded(
              child: ListView.builder(
                itemCount: insights.length,
                itemBuilder: (context, index) {
                  final item = insights[index];
                  return Card(
                    color: Colors.blueGrey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        item["Category"],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "₹${item["Amount"]} - ${item["Spending Category"]}",
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      leading: Icon(Icons.category, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String spendingCategory) {
    switch (spendingCategory) {
      case "Low Spending":
        return Colors.greenAccent;
      case "Moderate Spending":
        return Colors.amberAccent;
      case "High Spending":
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }
}
