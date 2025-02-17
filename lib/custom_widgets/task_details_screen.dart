import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  final String taskId;
  final String teamId;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.taskId,
    required this.teamId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Task Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Due Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['status'] ?? "In Progress",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    "Due ${task['dueDate'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Task Title & Assignees
              Text(
                task['title'] ?? "Task Title",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.people, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "${task['assignees'] ?? 0} assignees",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                task['description'] ?? "No description provided.",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Attachments Section
              const Text(
                "Attachments",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: (task['attachments'] as List<dynamic>?)?.map((file) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file, size: 30, color: Colors.black54),
                    title: Text(file['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text("${file['size']} MB", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    onTap: () {}, // TODO: Implement file opening logic
                  );
                }).toList() ??
                    [const Text("No attachments available.")],
              ),
              const SizedBox(height: 20),

              // Comments Section
              const Text(
                "Comments",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: (task['comments'] as List<dynamic>?)?.map((comment) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(comment['profilePic'] ?? ""),
                      radius: 20,
                    ),
                    title: Text(comment['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment['message'], style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(comment['time'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }).toList() ??
                    [const Text("No comments yet.")],
              ),
              const SizedBox(height: 10),

              // Add Comment Input
              TextField(
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {}, // TODO: Implement track time function
              icon: const Icon(Icons.timer, size: 18, color: Colors.black,),
              label: const Text("Track Time"),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, // Prevent closing while loading
                  builder: (context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  await FirebaseFirestore.instance
                      .collection('teams')
                      .doc(teamId)
                      .collection('tasks')
                      .doc(taskId)
                      .update({'status': 'completed'});

                  // Close loading dialog
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task marked as completed!")),
                  );

                  // Close the task details screen
                  Navigator.pop(context);
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Mark Complete", style: TextStyle(color: Colors.white)),
            ),

          ],
        ),
      ),
    );
  }
}
