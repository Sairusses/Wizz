import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wizz/custom_widgets/custom_text_form_field.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';

import '../services/firestore_service.dart';
import 'new_task.dart';

class LeaderDashboard extends StatefulWidget {
  const LeaderDashboard({super.key});

  @override
  LeaderDashboardState createState() => LeaderDashboardState();

}
class LeaderDashboardState extends State<LeaderDashboard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TasksList()
          ],
        ),
      ),
    );
  }

}

class _AppBar extends StatelessWidget implements PreferredSizeWidget{
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black54,
            height: .5,
          )
      ),
      backgroundColor: Colors.white,
      title: Text('Dashboard',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {},
        ),
        const CircleAvatar(
          backgroundColor: Colors.black12,
          child: Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class TasksList extends StatelessWidget{
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 20,),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                ),
                color: Colors.black87,
                onPressed: () {
                  showDialog(context: context, builder: (context) => NewTask());
                },
              ),
            ],
          ),


        ],
      ),
    );
  }
}

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({super.key});

  @override
  NewTaskDialogState createState() => NewTaskDialogState();
}

class NewTaskDialogState extends State<NewTaskDialog>{
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedPriority; // Selected value for dropdown
  final List<String> priorities = ['Low', 'Medium', 'High']; // Dropdown items

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Task",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                  controller: titleController,
                  labelText: 'Task Title',
                  hint: 'Enter task title'
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextFormField(
                  controller: descriptionController,
                  labelText: 'Description',
                  maxLines: 4,
                  hint: 'Add task details'),
              const SizedBox(height: 16),
              // Priority and Due Date
              Row(
                children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPriority,
                      hint: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.black),
                          SizedBox(width: 8.0),
                          Text('Priority', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      isExpanded: true,
                      items: priorities.map((String priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // Handle due date
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Due Date"),
                  ),
                ),
                ],
              ),
              const SizedBox(height: 16),

              // Assignees
              const Text(
                "Assignees",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Handle add people
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Add people"),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Assignees' avatars (mock data)
              Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Create Task Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Fluttertoast.showToast(msg: selectedPriority!);
                  },
                  child: const Text(
                    "Create Task",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

