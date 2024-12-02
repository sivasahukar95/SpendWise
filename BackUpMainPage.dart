import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // List of transactions
  final List<Map<String, dynamic>> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Overview Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOverviewCard('Balance', '₹5,250', Colors.blue),
                _buildOverviewCard('Income', '₹8,000', Colors.green),
                _buildOverviewCard('Expenses', '₹2,750', Colors.red),
              ],
            ),
          ),
          // Recent Transactions Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? Center(
              child: Text(
                'No transactions added yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView(
              children: _buildGroupedTransactionList(),
            ),
          ),
        ],
      ),
      // Floating Action Button for Adding New Transaction
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionForm(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  // Helper Widget: Overview Card
  Widget _buildOverviewCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Function: Group Transactions by Date
  List<Widget> _buildGroupedTransactionList() {
    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date = transaction['date'];
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    List<String> sortedDates = groupedTransactions.keys.toList();
    sortedDates.sort((a, b) => DateFormat('MMM d, yyyy').parse(b).compareTo(
      DateFormat('MMM d, yyyy').parse(a),
    ));

    // Build widgets for each date group
    List<Widget> transactionList = [];
    for (var date in sortedDates) {
      transactionList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      );

      for (var transaction in groupedTransactions[date]!) {
        transactionList.add(
          _buildTransactionTile(
            category: transaction['category'],
            amount: transaction['amount'],
            description: transaction['description'],
          ),
        );
      }
    }

    return transactionList;
  }

  // Helper Widget: Transaction Tile
  Widget _buildTransactionTile({
    required String category,
    required String amount,
    required String description,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(Icons.category, color: Colors.blue),
      ),
      title: Text(
        category,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description),
      trailing: Text(
        amount,
        style: TextStyle(
          fontSize: 20, // Make the amount bigger
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  // Function to Show Add Transaction Form
  void _showAddTransactionForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String amount = '';
    String description = '';
    String category = '';
    DateTime selectedDate = DateTime.now();
    String? amountError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      errorText: amountError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          amountError = 'Amount is mandatory';
                        } else if (double.tryParse(value) == null) {
                          amountError = 'Please enter a valid number';
                        } else {
                          amountError = null;
                          amount = value;
                        }
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      description = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Category'),
                    onSaved: (value) {
                      category = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category is mandatory';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && amountError == null) {
                        _formKey.currentState!.save();
                        setState(() {
                          transactions.add({
                            'amount': '₹$amount',
                            'description': description.isNotEmpty
                                ? description
                                : 'No description',
                            'category': category,
                            'date': DateFormat('MMM d, yyyy').format(selectedDate),
                          });
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add Transaction'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
