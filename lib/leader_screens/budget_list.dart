import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wizz/leader_screens/budget_new.dart';

class BudgetListScreen extends StatefulWidget {
  final int teamBudget;
  final int teamBudgetSpent;
  final String teamId;

  const BudgetListScreen({super.key, required this.teamId, required this.teamBudget, required this.teamBudgetSpent});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  late Future<List<Map<String, dynamic>>> _budgetItemsFuture;

  @override
  void initState() {
    super.initState();
    _budgetItemsFuture = _fetchAllBudgets(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget List', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black54,
              height: .5,
            )),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _budgetItemsFuture,
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: SpinKitThreeInOut(color: Colors.blueAccent, size: 30));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No budget items found'));
                }

                var budgetItems = snapshot.data!;

                return ListView.builder(
                  itemCount: budgetItems.length,
                  itemBuilder: (context, index) {
                    var item = budgetItems[index];
                    return ListTile(
                      title: Text(item['name'] ?? item['title'].toString() ?? 'Unnamed Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('\$${item['amount'] ?? item['budget'] ?? 0}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () => _confirmDeleteBudgetItem(item['id'], item['source']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => BudgetNew(
            teamBudget: widget.teamBudget,
            teamBudgetSpent: widget.teamBudgetSpent,
            teamId: widget.teamId,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllBudgets(String teamId) async {
    List<Map<String, dynamic>> allBudgets = [];

    QuerySnapshot taskSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).collection('tasks').get();

    for (var doc in taskSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      allBudgets.add({'title': data['title'] ?? 'Untitled Task', 'budget': data['budget'] ?? 0, 'id': doc.id, 'source': 'tasks'});
    }

    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).collection('expenses').get();

    for (var doc in expenseSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      allBudgets.add({'title': data['title'] ?? 'Unnamed Expense', 'amount': data['budget'] ?? 0, 'id': doc.id, 'source': 'expenses'});
    }

    return allBudgets;
  }

  Future<void> _confirmDeleteBudgetItem(String itemId, String source) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Budget Item'),
          content: const Text('Are you sure you want to delete this budget item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).collection(source).doc(itemId).delete();
      setState(() {
        _budgetItemsFuture = _fetchAllBudgets(widget.teamId);
      });
    }
  }
}
