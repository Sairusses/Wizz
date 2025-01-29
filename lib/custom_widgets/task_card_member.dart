import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wizz/custom_widgets/task_details_screen.dart';

class TaskCardMember extends StatelessWidget {
  final Map<String, dynamic> task;
  final String taskId;
  final String teamId;

  const TaskCardMember({
    super.key,
    required this.task,
    required this.taskId,
    required this.teamId,
  });

  void markTaskComplete() {
      FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .doc(taskId)
          .update({'status': 'Completed'});
  }

  String formatDueDate(dynamic dueDate) {
    if (dueDate is Timestamp) {
      return DateFormat('MMM d, yyyy').format(dueDate.toDate());
    }
    return dueDate?.toString() ?? "No Date";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(task: task, taskId: taskId, teamId: teamId,),
            ),
          );
        },
        child: Card(
          elevation: 2,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(task["title"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black  )),
                    ),
                    Chip(
                      elevation: 2,
                      label: Text(task["priority"],
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      backgroundColor: task["priority"] == "high"
                          ? Colors.red
                          : Colors.black54,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(task["description"], style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("Due ${formatDueDate(task["due_date"])}",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                    TextButton(
                      onPressed:
                      task['status'] == 'Completed' ? null : markTaskComplete,
                      child: Text(
                          task['status'] == 'Completed'
                              ? "Completed"
                              : "Mark Complete",
                          style: TextStyle(
                              color: task['status'] == 'Completed'
                                  ? Colors.green[900]
                                  : Colors.blueGrey[900])),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
