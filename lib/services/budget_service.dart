

import 'package:cloud_firestore/cloud_firestore.dart';

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
          int budget = taskData['budget'] ?? 0;

          if (!uniqueTitles.contains(title)) {
            uniqueTitles.add(title);
            totalSpent += budget;
          }
        }
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
}
