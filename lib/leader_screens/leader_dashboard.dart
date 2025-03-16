import 'package:flutter/material.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';
import 'package:wizz/leader_screens/budget_list.dart';
import 'package:wizz/leader_screens/budget_new.dart';
import 'package:wizz/leader_screens/leader_tasks_gallery.dart';
import 'package:wizz/services/budget_service.dart';
import 'package:wizz/services/task_service.dart';
import 'new_task.dart';

class LeaderDashboard extends StatefulWidget {
  final String teamId;
  final List<Map<String, dynamic>> tasks;
  final int teamBudget;
  final int teamBudgetSpent;
  const LeaderDashboard({super.key, required this.teamId, required this.tasks, required this.teamBudget, required this.teamBudgetSpent});

  @override
  LeaderDashboardState createState() => LeaderDashboardState();

}
class LeaderDashboardState extends State<LeaderDashboard> with AutomaticKeepAliveClientMixin<LeaderDashboard>{
  late List<Map<String, dynamic>> tasks;
  late int teamBudget;
  late int teamBudgetSpent;
  late String teamId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tasks = widget.tasks;
    teamBudget = widget.teamBudget;
    teamBudgetSpent = widget.teamBudgetSpent;
    teamId = widget.teamId;
    super.initState();
  }

  Future<void> _refreshData() async {
     List<Map<String, dynamic>> tasks = await TaskService().fetchAllTasks(widget.teamId);
     int teamBudget = await BudgetService().getTeamBudget(widget.teamId);
     int teamBudgetSpent = await BudgetService().getTotalSpentBudget(widget.teamId);
    
    setState(() {
      this.tasks = tasks;
      this.teamBudget = teamBudget;
      this.teamBudgetSpent = teamBudgetSpent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _AppBar(),
      body: Container(
        height: double.infinity,
        color: Colors.grey[50],
        padding: const EdgeInsets.all(20),
        child: RefreshIndicator(
          displacement: 15,
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TasksTitle(teamId: widget.teamId, tasks: tasks),
                SizedBox(height: 8),
                TasksCardLeader(tasks: tasks, height: MediaQuery.of(context).size.height * .25),
                SizedBox(height: 16),
                BudgetTitle(teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent, teamId: teamId,),
                SizedBox(height: 8),
                BudgetOverview(spent: teamBudgetSpent, total: teamBudget),
                SizedBox(height: 8),
              ],
            ),
          ),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class TasksTitle extends StatelessWidget{
  final String? teamId;
  final List<Map<String, dynamic>> tasks;
  const TasksTitle({super.key, required this.teamId, required this.tasks});

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
              showDialog(context: context, builder: (context) => NewTask(teamId: teamId!));
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
                SizedBox(width: 8),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderTasksGallery(teamId: teamId!, tasks: tasks)),
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

class BudgetTitle extends StatelessWidget{
  final int teamBudget;
  final int teamBudgetSpent;
  final String teamId;
  const BudgetTitle({super.key, required this.teamBudget, required this.teamBudgetSpent, required this.teamId});

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
              showDialog(context: context, builder: (context) =>
                BudgetNew(
                  teamBudget: teamBudget,
                  teamBudgetSpent: teamBudgetSpent,
                  teamId: teamId,)
              );
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
                Icon(Icons.attach_money, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Record Expense',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BudgetListScreen(teamId: teamId, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent,)),
                  );
                },
                icon: Icon(Icons.more_horiz, color: Colors.black),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class BudgetOverview extends StatelessWidget {
  final int spent;
  final int total;

  const BudgetOverview({super.key, required this.spent, required this.total,});

  @override
  Widget build(BuildContext context) {
    double progress = (total == 0) ? 100 : spent / total;
    Color progressColor = (spent > total) ? Colors.red.shade700 : Colors.black87;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Budget Overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$$spent spent",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "\$$total total",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            if (spent > total)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Exceeded budget!",
                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
