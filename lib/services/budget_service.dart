

import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalSpentBudget(String teamId) async {
    int totalSpent = 0;

    try {
      QuerySnapshot taskSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .get();

      Set<String> uniqueTitles = {};

      for (var taskDoc in taskSnapshot.docs) {
        Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
        if (taskData.containsKey('title') && taskData.containsKey('budget')) {
          String title = taskData['title'];
          var budgetValue = taskData['budget'];
          int budget = budgetValue.toInt();

          if (!uniqueTitles.contains(title)) {
            uniqueTitles.add(title);
            totalSpent += budget;
          }
        }
      }

      QuerySnapshot expenseSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('expenses')
          .get();

      for (var expensesDoc in expenseSnapshot.docs){
        Map<String, dynamic> expenseData = expensesDoc.data() as Map<String, dynamic>;
        var amountValue = expenseData['amount'];
        int amount = amountValue.toInt();
        totalSpent += amount;
      }

      return totalSpent;
    } catch (e) {
      print("Error fetching total spent budget: $e");
      return 0;
    }
  }

  Future<void> setTeamBudget(String teamId, int budget) async {
    try {
      await _firestore.collection('teams').doc(teamId).set(
        {'budget': budget},
      );
    } catch (e) {
      print("Error setting budget: $e");
    }
  }

  Future<int> getTeamBudget(String teamId) async {
    try {
      DocumentSnapshot teamDoc = await _firestore.collection('teams').doc(teamId).get();

      if (teamDoc.exists) {
        return teamDoc['budget'] ?? 0;
      } else {
        print("Team not found: $teamId");
        return 0;
      }
    } catch (e) {
      print("Error fetching budget: $e");
      return 0;
    }
  }

  Future<void> addExpense({
    required String title,
    required String description,
    required double amount,
    required Timestamp date,
    required String teamId
  }) async {
    try {
      CollectionReference expensesCollection = FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('expenses');

      await expensesCollection.add({
        'title': title,
        'description': description,
        'amount': amount,
        'date': date,
      });
    } catch (e) {
      AuthService().showToast('Error: $e');
    }
  }
}
