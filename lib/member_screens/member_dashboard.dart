import 'package:flutter/material.dart';
import 'package:wizz/custom_widgets/custom_tab_indicator.dart';
import '../custom_widgets/task_card_member.dart';


class MemberDashboard extends StatefulWidget {
  final String userId;
  final String teamId;
  final List<Map<String, dynamic>> allTasks;
  final List<Map<String, dynamic>> inProgressTasks;
  final List<Map<String, dynamic>> completedTasks;
  final List<Map<String, dynamic>> dueTodayTasks;
  final ScrollController controller;
  const MemberDashboard({super.key, required this.controller, required this.userId, required this.teamId, required this.allTasks, required this.inProgressTasks, required this.completedTasks, required this.dueTodayTasks});

  @override
  MemberDashboardState createState() => MemberDashboardState();
}

class MemberDashboardState extends State<MemberDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xf3f3f3f3),
      appBar: _AppBar(),
      body: _TasksTabView(
        teamId: widget.teamId,
        userId: widget.userId,
        tabController: _tabController,
        scrollController: widget.controller,
        allTasks: widget.allTasks,
        inProgressTasks: widget.inProgressTasks,
        completedTasks: widget.completedTasks,
        dueTodayTasks: widget.dueTodayTasks,
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
  final List<Map<String, dynamic>> tasks;
  final String teamId;

  const _AllTasksList({required this.tasks, required this.teamId,});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks assigned."));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCardMember(
          task: task,
          taskId: task['id'],
          teamId: teamId,
        );
      },
    );
  }
}

class _InProgressTasksList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String teamId;

  const _InProgressTasksList({required this.teamId, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks in progress."));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCardMember(
          task: task,
          taskId: task['id'],
          teamId: teamId,
        );
      },
    );
  }
}

class _CompletedTasksList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String teamId;

  const _CompletedTasksList({required this.teamId, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks completed."));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCardMember(
          task: task,
          taskId: task['id'],
          teamId: teamId,
        );
      },
    );
  }
}

class _DueTodayTasksList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String teamId;

  const _DueTodayTasksList({required this.teamId, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks completed."));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCardMember(
          task: task,
          taskId: task['id'],
          teamId: teamId,
        );
      },
    );
  }
}

class _TasksTabView extends StatelessWidget {
  final String teamId;
  final String userId;
  final TabController tabController;
  final ScrollController scrollController;
  final List<Map<String, dynamic>> allTasks;
  final List<Map<String, dynamic>> inProgressTasks;
  final List<Map<String, dynamic>> completedTasks;
  final List<Map<String, dynamic>> dueTodayTasks;

  const _TasksTabView({
    required this.teamId,
    required this.userId,
    required this.tabController,
    required this.scrollController,
    required this.allTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.dueTodayTasks,
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
            _AllTasksList(tasks: allTasks, teamId: teamId,),
            _InProgressTasksList(tasks: inProgressTasks, teamId: teamId,),
            _CompletedTasksList(tasks: completedTasks, teamId: teamId,),
            _DueTodayTasksList(tasks: dueTodayTasks, teamId: teamId,),
          ],
        ),
      ),
    );
  }
}