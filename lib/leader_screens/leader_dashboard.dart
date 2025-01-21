import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';

import '../services/firestore_service.dart';

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
                onPressed: () {  },
              ),
            ],
          ),

        ],
      ),
    );
  }

}
