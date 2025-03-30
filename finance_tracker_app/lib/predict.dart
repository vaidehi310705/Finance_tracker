import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

void main() {
  runApp(
    MaterialApp(
      home: Predict(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}

class Predict extends StatefulWidget {
  const Predict({super.key});

  @override
  PredictState createState() => PredictState();
}

class PredictState extends State<Predict> {
  String expense = "";
  String amount = "";
  String date = "";
  String message = "";
  bool isPredicting = false;
  final Logger logger = Logger();

  Future<void> predictAndSaveExpense(String expense) async {
    try {
      if (expense.isEmpty || amount.isEmpty || date.isEmpty) {
        setState(() {
          message = "Please fill all the fields.";
        });
        logger.i("Incomplete input data.");
        return;
      }

      setState(() {
        isPredicting = true;
        message = "Predicting...";
      });

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/predict/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "item_description": expense,
          "amount": double.tryParse(amount) ?? 0.0,
          "date": date,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String predictedCategory = data['category'];

        // Check if the expense already exists before saving
        bool isDuplicate = await isExpenseDuplicate(expense, amount, date);
        if (!isDuplicate) {
          await addExpense(expense, amount, date, predictedCategory);
        } else {
          setState(() {
            message = "This expense already exists!";
          });
          logger.i("Duplicate expense detected.");
        }
      } else {
        setState(() {
          message =
              "Error: Unable to predict. Status Code: ${response.statusCode}";
        });
        logger.i("Prediction Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        message = "Error: ${e.toString()}";
      });
      logger.i("Prediction Exception: ${e.toString()}");
    } finally {
      setState(() {
        isPredicting = false;
        // Reset the input fields after prediction and saving
        expense = "";
        amount = "";
        date = "";
      });
    }
  }

  Future<void> addExpense(
    String itemDescription,
    String amount,
    String date,
    String category,
  ) async {
    try {
      logger.i(
        "Adding Expense -> Item: $itemDescription, Amount: $amount, Date: $date, Category: $category",
      );

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/expenses/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "item_description": itemDescription,
          "amount": double.tryParse(amount) ?? 0.0,
          "date": date,
          "category": category,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          message = "Expense saved successfully!";
        });
      } else {
        setState(() {
          message = "Error saving expense.";
        });
        logger.i("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        message = "Error: ${e.toString()}";
      });
      logger.i("Exception: ${e.toString()}");
    }
  }

  Future<bool> isExpenseDuplicate(
    String itemDescription,
    String amount,
    String date,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/expenses/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Check if any expense has the same description, amount, and date
        for (var expense in data) {
          if (expense['item_description'] == itemDescription &&
              expense['amount'].toString() == amount &&
              expense['date'] == date) {
            return true; // Duplicate found
          }
        }
      } else {
        logger.i("Error fetching expenses: ${response.statusCode}");
      }
    } catch (e) {
      logger.i("Exception: ${e.toString()}");
    }
    return false; // No duplicate found
  }

  Widget _buildTextField(
    String labelText,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(65, 0, 0, 0),
            const Color.fromARGB(65, 0, 0, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text("Expense Tracker", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Enter Expense", (value) => expense = value),
            SizedBox(height: 16),
            _buildTextField(
              "Enter Amount",
              (value) => amount = value,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildTextField("Date (YYYY-MM-DD)", (value) => date = value),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  isPredicting ? null : () => predictAndSaveExpense(expense),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadowColor: const Color.fromARGB(255, 40, 40, 40),
                elevation: 10,
              ),
              child:
                  isPredicting
                      ? CircularProgressIndicator()
                      : Text(
                        "Predict & Save",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
            ),
            SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _ExpenseListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadowColor: const Color.fromARGB(255, 41, 41, 41),
                elevation: 10,
              ),
              child: Text(
                "View Saved Expenses",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListPage extends StatefulWidget {
  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<_ExpenseListPage> {
  List<dynamic> _expenseList = [];

  // Fetch the expenses from the backend database
  Future<void> fetchExpenses() async {
    final Logger logger = Logger();
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/expenses/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Remove duplicates based on the item_description, amount, and date
        final Set<String> expenseSet = {};
        final uniqueExpenses =
            data.where((expense) {
              String uniqueKey =
                  '${expense['item_description']}_${expense['amount']}_${expense['date']}';
              if (expenseSet.contains(uniqueKey)) {
                return false; // Duplicate found, don't include it
              } else {
                expenseSet.add(uniqueKey); // Add to the set to track
                return true; // Unique expense
              }
            }).toList();

        setState(() {
          _expenseList = uniqueExpenses;
        });
      } else {
        logger.i("Error: ${response.statusCode}");
      }
    } catch (e) {
      logger.i("Exception: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses(); // Load the expenses when the page is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense List", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 255, 255, 255),
          onPressed: () {
            // Navigate back to the home page
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _expenseList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _expenseList.length,
                  itemBuilder: (context, index) {
                    final expense = _expenseList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      color: const Color.fromARGB(222, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: ListTile(
                        title: Text(
                          expense['item_description'],
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Amount: ${expense['amount']} | Date: ${expense['date']} | Category: ${expense['category']}',
                          style: TextStyle(
                            color: const Color.fromARGB(217, 224, 222, 222),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
