

import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalSpentBudget(String teamId) async {
    int totalSpent = 0;

    try {
      // Reference to the tasks subcollection under a specific team
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .get();

      for (var task in tasksSnapshot.docs) {
        int taskBudget = (task.data() as Map<String, dynamic>)['budget'] ?? 0.0;
        totalSpent += taskBudget;
      }
    } catch (e) {
      print("Error fetching budget: $e");
    }

    return totalSpent;
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
}
