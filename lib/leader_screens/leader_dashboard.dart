import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wizz/custom_widgets/custom_text_form_field.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';
import 'package:wizz/services/auth_service.dart';

import '../services/firestore_service.dart';
import 'new_task.dart';

class LeaderDashboard extends StatefulWidget {
  const LeaderDashboard({super.key});

  @override
  LeaderDashboardState createState() => LeaderDashboardState();

}
class LeaderDashboardState extends State<LeaderDashboard> {

  String? teamId;
  bool isLoading = true;
  List<Map<String, dynamic>> tasks = [];

  @override
  initState() {
    super.initState();
    _initializeTeamId();
  }

  void _initializeTeamId() async {
    try {
      String? team = await FirestoreService().getUserTeam();
      setState(() {
        teamId = team;
      });
      _fetchInProgressTasks();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching team: $error");
    }
  }
  void _fetchInProgressTasks() async {
    try {
      if (teamId != null) {
        List<Map<String, dynamic>> fetchedTasks = await FirestoreService().fetchInProgressTasks(teamId!);
        setState(() {
          tasks = fetchedTasks;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching tasks: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Scaffold(
        appBar: _AppBar(),
        body: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(color: Colors.black54),
          )
        ),
      );
    }else{
      return Scaffold(
        appBar: _AppBar(),
        body: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TasksTitle(teamId: teamId,),
              TasksCardLeader(tasks: tasks),
            ],
          ),
        ),
      );
    }
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class TasksTitle extends StatefulWidget{
  final String? teamId;
  const TasksTitle({super.key, required this.teamId});

  @override
  TasksTitleState createState() => TasksTitleState();
}

class TasksTitleState extends State<TasksTitle>{

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
                  showDialog(context: context, builder: (context) => NewTask(teamId: widget.teamId!));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


