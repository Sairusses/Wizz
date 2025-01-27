import 'package:flutter/material.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TasksTitle(teamId: teamId,),
              SizedBox(height: 8,),
              TasksCardLeader(tasks: tasks),
            ],
          ),
        ),
      );
    }
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget{

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (context) => NewTask(teamId: widget.teamId!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'New Task',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Sort action
                },
                icon: Icon(Icons.sort, color: Colors.black),
              ),
              IconButton(
                onPressed: () {
                  // Gallery action
                },
                icon: Icon(Icons.grid_view_rounded, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


