import 'package:flutter/material.dart';
import 'spend_analysis_page.dart';
import 'predict.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

@override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,

      // ✅ AppBar with Top Navigation
      appBar: AppBar(
        title: const Text(
          "Finance Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey.shade800,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 📊 Spend Analysis Button
              TextButton.icon(
                onPressed: () => _navigateToPage(SpendAnalysisPage()),
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.amber),
                label: const Text("Spend", style: TextStyle(color: Colors.white)),
              ),
              
              // 📈 Predict Page Button
              TextButton.icon(
                onPressed: () => _navigateToPage(Predict()),
                icon: const Icon(Icons.trending_up_rounded, color: Colors.amber),
                label: const Text("Predict", style: TextStyle(color: Colors.white)),
              ),

              // ⚙️ Settings Page Button (Placeholder)
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚙️ Settings Page Coming Soon!")),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.amber),
                label: const Text("Settings", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),

      // ✅ Home Screen Content
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "📊 Master Your Finances with AI! 🚀",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          
         
            
          
        ],
      ),
    );
  }
}
