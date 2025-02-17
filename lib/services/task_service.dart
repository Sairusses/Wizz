import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class TaskService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllTasks(String teamId) async {
    try {
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .get();

      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return tasks;
    } catch (e) {
      AuthService().showToast('Error fetching in-progress tasks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllTasksAssignedToUser(String userId, String teamId) async {
    try {
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .where('assigned_to', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return tasks;
    } catch (e) {
      AuthService().showToast('Error fetching tasks: $e');
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> fetchInProgressTasksAssignedTo(String userId, String teamId) async {
    try {
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .where('assigned_to', isEqualTo: userId)
          .where('status', isEqualTo:  'In Progress')
          .get();

      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return tasks;
    } catch (e) {
      AuthService().showToast('Error fetching in progress tasks: $e');
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> fetchCompletedTasksAssignedTo(String userId, String teamId) async {
    try {
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .where('assigned_to', isEqualTo: userId)
          .where('status', isEqualTo: 'Completed')
          .get();

      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return tasks;
    } catch (e) {
      AuthService().showToast('Error fetching completed tasks: $e');
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> fetchDueTodayTasksAssignedTo(String userId, String teamId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59, 59, 59);

      QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .where('assigned_to', isEqualTo: userId)
          .orderBy('due_date')
          .where('due_date', isGreaterThanOrEqualTo:  Timestamp.fromDate(startOfDay))
          .where('due_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return tasks;
    } catch (e) {
      AuthService().showToast('Error fetching due today tasks: $e');
      return [];
    }
  }
}