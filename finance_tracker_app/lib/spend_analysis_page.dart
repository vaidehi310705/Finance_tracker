import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart'; // Animation package

class SpendAnalysisPage extends StatefulWidget {
  const SpendAnalysisPage({super.key}); // Ensure correct constructor

  @override
  SpendAnalysisPageState createState() => SpendAnalysisPageState();
}

class SpendAnalysisPageState extends State<SpendAnalysisPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, double> userBudget = {
    'Food': 150,
    'Groceries': 200,
    'Health': 100,
    'Shopping': 250,
    'Transport': 120,
  };

  final Map<String, double> actualSpending = {
    'Food': 160,
    'Groceries': 180,
    'Health': 50,
    'Shopping': 300,
    'Transport': 100,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text(
          'Spend Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.blueGrey.shade800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: LinearGradient(colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255),]),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.blueGrey.shade800,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: "Spend Analysis"),
            Tab(icon: Icon(Icons.warning_amber_rounded), text: "Alerts"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            FadeInUp(child: buildBarChart()),
            FadeInLeft(child: buildBudgetAlerts()),
          ],
        ),
      ),
    );
  }

  Widget buildBarChart() {
    return Card(
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 350,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    List<String> categories = userBudget.keys.toList();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(categories[value.toInt()],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: userBudget.keys.toList().asMap().entries.map((entry) {
              int index = entry.key;
              String category = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: userBudget[category]!,
                    color: Colors.cyanAccent,
                    width: 15,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: actualSpending[category]!,
                    color: const Color.fromARGB(255, 255, 64, 64),
                    width: 15,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList(),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.white24, strokeWidth: 1),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "₹${rod.toY}",
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
              enabled: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBudgetAlerts() {
    return ListView(
      children: userBudget.entries.map((entry) {
        String category = entry.key;
        double budget = entry.value;
        double actual = actualSpending[category] ?? 0;

        if (actual > budget) {
          return SlideInRight(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade400, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                title: Text(
                  "Over budget in $category",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "₹${(actual - budget).toStringAsFixed(2)} over budget",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      }).toList(),
    );
  }
}
