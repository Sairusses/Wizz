import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksCardLeader extends StatelessWidget {
  final double height;
  final List<Map<String, dynamic>> tasks;

  const TasksCardLeader({super.key, required this.tasks, required this.height});

  String formatDueDate(dynamic dueDate) {
    if (dueDate is Timestamp) {
      return DateFormat('MMM d, yyyy').format(dueDate.toDate());
    }
    return dueDate?.toString() ?? "No Date";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: tasks.isNotEmpty
          ? ListView.builder(
        itemCount: tasks.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Priority Label
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task['priority'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: task['progress'] / 100, // Assuming 0-100
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black54,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Due Date
                  Text(
                    'Due: ${formatDueDate(task['due_date'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          'No tasks available',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
