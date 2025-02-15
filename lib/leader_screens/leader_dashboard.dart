import 'package:flutter/material.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';
import 'package:wizz/leader_screens/leader_tasks_gallery.dart';
import 'new_task.dart';

class LeaderDashboard extends StatefulWidget {
  final String teamId;
  final List<Map<String, dynamic>> tasks;
  const LeaderDashboard({super.key, required this.teamId, required this.tasks});

  @override
  LeaderDashboardState createState() => LeaderDashboardState();

}
class LeaderDashboardState extends State<LeaderDashboard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TasksTitle(teamId: widget.teamId, tasks: widget.tasks, ),
            SizedBox(height: 8,),
            TasksCardLeader(tasks: widget.tasks, height: MediaQuery.of(context).size.height * .25,),
          ],
        ),
      ),
    );
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
  final List<Map<String, dynamic>> tasks;
  const TasksTitle({super.key, required this.teamId, required this.tasks});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderTasksGallery(teamId: widget.teamId!, tasks: widget.tasks)),
                  );
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


