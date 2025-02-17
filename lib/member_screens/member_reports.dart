import 'package:flutter/material.dart';
import 'package:wizz/services/team_service.dart';

class ReportsMember extends StatefulWidget {
  const ReportsMember({super.key});

  @override
  State<ReportsMember> createState() => _ReportsMemberState();
}

class _ReportsMemberState extends State<ReportsMember> {
  String? tasksJson;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      // Fetch JSON data from Firestore
      String json = await TeamService().getCollectionJson("ZpWOEpGh5qDVb7c6M5Nq");
      setState(() {
        tasksJson = json; // Update the state
      });
    } catch (e) {
      setState(() {
        tasksJson = "Error loading tasks: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports Member"),
        centerTitle: true,
      ),
      body: Center(
        child: tasksJson == null
            ? const CircularProgressIndicator() // Show loading indicator
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(tasksJson!),
        ),
      ),
    );
  }
}
