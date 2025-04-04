import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavingGoalsScreen extends StatefulWidget {
  @override
  _SavingGoalsScreenState createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();
  String? predictionResult;
  bool isLoading = false;

  Future<void> predictSavings() async {
    final double? income = double.tryParse(incomeController.text);
    final double? expenses = double.tryParse(expensesController.text);

    if (income == null || expenses == null) {
      setState(() {
        predictionResult = "⚠️ Please enter valid numbers.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      predictionResult = null; // Clear previous result
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/predict_savings"), // Make sure Django is running
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"income": income, "expenses": expenses}),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          predictionResult = "💰 Predicted Savings: ₹${responseData["predicted_savings"]}";
        });
      } else {
        setState(() {
          predictionResult = "❌ Server error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "⚠️ Failed to connect to server.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: Text("Saving Goals Predictor"),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Your Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Income",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: expensesController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Expenses",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: predictSavings,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Predict Savings", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            if (predictionResult != null)
              Text(
                predictionResult!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
