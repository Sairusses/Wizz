import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wizz/custom_widgets/custom_tab_indicator.dart';
import 'package:wizz/services/firestore_service.dart';
import '../custom_widgets/task_card.dart';


class MemberDashboard extends StatefulWidget {
  final ScrollController controller;
  const MemberDashboard({super.key, required this.controller});

  @override
  MemberDashboardState createState() => MemberDashboardState();
}

class MemberDashboardState extends State<MemberDashboard> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  String? teamId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserTeam();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> _loadUserTeam() async {
    String? fetchedTeamId = await FirestoreService().getUserTeam();
    setState(() {
      teamId = fetchedTeamId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot?>.value(
      value: teamId != null
          ? _firestore.collection('teams').doc(teamId).collection('tasks').snapshots()
          : null,
      initialData: null,
      child: Scaffold(
        backgroundColor: Color(0xf3f3f3f3),
        appBar: _AppBar(),
        body: _TasksTabView(
          teamId: teamId,
          userId: userId,
          tabController: _tabController,
          scrollController: widget.controller,
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
      title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
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

class _AllTasksList extends StatelessWidget {
  final String? teamId;
  final String? userId;

  const _AllTasksList({required this.teamId, required this.userId,});

  @override
  Widget build(BuildContext context) {
    final tasksSnapshot = Provider.of<QuerySnapshot?>(context);

    if (tasksSnapshot == null) {
      return Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
    }

    final tasks = tasksSnapshot.docs.where((doc) => doc['assigned_to'] == userId).toList();

    if (tasks.isEmpty) {
      return Center(child: Text("No tasks available."));
    }

    return ListView(
      children: tasks.map((doc) {
        Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
        return TaskCard(task: task, taskId: doc.id, teamId: teamId!);
      }).toList(),
    );
  }
}

class _InProgressTasksList extends StatelessWidget {
  final String? userId;
  final String? teamId;

  const _InProgressTasksList({required this.teamId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final tasksSnapshot = Provider.of<QuerySnapshot?>(context);

    if (tasksSnapshot == null) {
      return Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
    }

    final tasks = tasksSnapshot.docs
        .where((doc) => doc['assigned_to'] == userId && doc['status'] == 'in progress')
        .toList();

    if (tasks.isEmpty) {
      return Center(child: Text("No tasks in progress."));
    }

    return ListView(
      children: tasks.map((doc) {
        Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
        return TaskCard(task: task, taskId: doc.id, teamId: teamId!);
      }).toList(),
    );
  }
}

class _CompletedTasksList extends StatelessWidget {
  final String? userId;
  final String? teamId;

  const _CompletedTasksList({required this.teamId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final tasksSnapshot = Provider.of<QuerySnapshot?>(context);

    if (tasksSnapshot == null) {
      return Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
    }

    final tasks = tasksSnapshot.docs
        .where((doc) => doc['assigned_to'] == userId && doc['status'] == 'completed')
        .toList();

    if (tasks.isEmpty) {
      return Center(child: Text("No completed tasks."));
    }

    return ListView(
      children: tasks.map((doc) {
        Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
        return TaskCard(task: task, taskId: doc.id, teamId: teamId!);
      }).toList(),
    );
  }
}

class _DueTodayTasksList extends StatelessWidget {
  final String? userId;
  final String? teamId;

  const _DueTodayTasksList({required this.teamId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final tasksSnapshot = Provider.of<QuerySnapshot?>(context);

    if (tasksSnapshot == null) {
      return Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
    }

    DateTime today = DateTime.now();
    Timestamp startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day, 0, 0, 0));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day, 23, 59, 59));

    final tasks = tasksSnapshot.docs
        .where((doc) =>
    doc['assigned_to'] == userId &&
        doc['due_date'] is Timestamp &&
        (doc['due_date'] as Timestamp).compareTo(startOfDay) >= 0 &&
        (doc['due_date'] as Timestamp).compareTo(endOfDay) <= 0)
        .toList();

    if (tasks.isEmpty) {
      return Center(child: Text("No tasks due today."));
    }

    return ListView(
      children: tasks.map((doc) {
        Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
        return TaskCard(task: task, taskId: doc.id, teamId: teamId!);
      }).toList(),
    );
  }
}

class _TasksTabView extends StatelessWidget {
  final String? teamId;
  final String? userId;
  final TabController tabController;
  final ScrollController scrollController; // Accept scroll controller

  const _TasksTabView({
    required this.teamId,
    required this.userId,
    required this.tabController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NestedScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.grey[200],
            title: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: tabController,
                indicator: CustomTabIndicator(),
                labelColor: Colors.white,
                labelStyle: TextStyle(fontSize: 11.8, fontWeight: FontWeight.w500),
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'All Tasks'),
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Due Today'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _AllTasksList(teamId: teamId, userId: userId,),
            _InProgressTasksList(teamId: teamId, userId: userId,),
            _CompletedTasksList(teamId: teamId, userId: userId,),
            _DueTodayTasksList(teamId: teamId, userId: userId,),
          ],
        ),
      ),
    );
  }
}