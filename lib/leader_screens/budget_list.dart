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
  int totalSpent = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget List'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black54,
              height: .5,
            )
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _fetchAllBudgets(widget.teamId),
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SpinKitThreeInOut(color: Colors.blueGrey, size: 30,));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No budget items found'));
                }

                var budgetItems = snapshot.data!;

                return ListView.builder(
                  itemCount: budgetItems.length,
                  itemBuilder: (context, index) {
                    var item = budgetItems[index];
                    return ListTile(
                      title: Text(item['name'] ?? item['title'].toString() ?? 'Unnamed Item', style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text('Amount: \$${item['amount'] ?? item['budget'] ?? 0}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteBudgetItem(item['id'], item['source']),
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
        onPressed: () => showDialog(context: context, builder: (context) =>
            BudgetNew(teamBudget: widget.teamBudget, teamBudgetSpent: widget.teamBudgetSpent, teamId: widget.teamId),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllBudgets(String teamId) async {
    List<Map<String, dynamic>> allBudgets = [];

    QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .get();

    for (var doc in taskSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      allBudgets.add({'title': data['title'] ?? 'Untitled Task', 'budget': data['budget'] ?? 0, 'id': doc.id, 'source': 'tasks'});
    }

    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .collection('expenses')
        .get();

    for (var doc in expenseSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      allBudgets.add({'title': data['title'] ?? 'Unnamed Expense', 'amount': data['budget'] ?? 0, 'id': doc.id, 'source': 'expenses'});
    }

    return allBudgets;
  }

  void _deleteBudgetItem(String itemId, String source) async {
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(widget.teamId)
        .collection(source)
        .doc(itemId)
        .delete();
  }
}