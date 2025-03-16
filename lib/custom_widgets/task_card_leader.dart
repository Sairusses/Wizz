import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksCardLeader extends StatelessWidget {
  final double height;
  final List<Map<String, dynamic>> tasks;
  final String teamId;

  const TasksCardLeader({
    super.key,
    required this.tasks,
    required this.height,
    required this.teamId,
  });

  String formatDueDate(dynamic dueDate) {
    if (dueDate is Timestamp) {
      return DateFormat('MMM d, yyyy').format(dueDate.toDate());
    }
    return dueDate?.toString() ?? "No Date";
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
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
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title Row with Delete Button
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
                      Row(
                        children: [
                          // Priority Label
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
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
                          const SizedBox(width: 8),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.black),
                            onPressed: () => _showDeleteDialog(
                              context,
                              task['id'],
                            ),
                          ),
                        ],
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
                      valueColor: const AlwaysStoppedAnimation<Color>(
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

  // Show confirmation dialog before deleting
  void _showDeleteDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteTask(context, taskId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}