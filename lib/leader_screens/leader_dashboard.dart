import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'package:intl/intl.dart';
import 'package:wizz/custom_widgets/task_card_leader.dart';
import 'package:wizz/leader_screens/budget_new.dart';
import 'package:wizz/leader_screens/leader_tasks_gallery.dart';
import 'package:wizz/main_screens/ai_window_screen.dart';
import 'package:wizz/services/budget_service.dart';
import 'package:wizz/services/task_service.dart';
import 'dart:convert';
import 'new_task.dart';

class LeaderDashboard extends StatefulWidget {
  final String teamId;
  final List<Map<String, dynamic>> tasks;
  final int teamBudget;
  final int teamBudgetSpent;
  final Map<String, String> userMap;
  const LeaderDashboard({super.key, required this.teamId, required this.tasks, required this.teamBudget, required this.teamBudgetSpent, required this.userMap});

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
                AIPrediction(tasks: tasks, userMap: widget.userMap,),

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
              showDialog(context: context, builder: (context) => BudgetNew(
                teamBudget: teamBudget,
                teamBudgetSpent: teamBudgetSpent,
                teamId: teamId,));
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
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => budgetpage,
                  // );
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

class AIPrediction extends StatefulWidget{
  final List<Map<String, dynamic>> tasks;
  final Map<String, String> userMap;
  const AIPrediction({super.key, required this.tasks, required this.userMap});

  @override
  AIPredictionState createState() => AIPredictionState();
}

class AIPredictionState extends State<AIPrediction>{
  get tasks => widget.tasks;
  get userMap => widget.userMap;
  final _groq = Groq(
    apiKey: "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",
    model: "deepSeek-r1-distill-llama-70b",
  );
  final String instruction = '''
You are an AI assistant specializing in task management foresight, risk assessment, and workflow optimization. Your role is to analyze structured task data, predict potential outcomes, and provide actionable insights to improve productivity and efficiency.
You will receive a structured list of tasks in JSON format, where each task contains:
[
  {
    "title": "Task Title",
    "description": "Brief details about the task",
    "assignedTo": "UserID",
    "dueDate": "YYYY-MM-DD",
    "status": "pending | in-progress | completed",
    "priority": "low | medium | high",
    "category": "development | design | analysis | etc."
  }
]
Additional fields may be included for better analysis.

You will analyze the given tasks and generate the following:
1. Task Completion Predictions
Evaluate if tasks are likely to be completed on time based on their current status, priority, and past trends.
Identify at-risk tasks and recommend priority adjustments
2. Team Performance & Workload Analysis
Assess workload distribution across team members.
Identify potential bottlenecks, overburdened members, or underutilized resources.
3. Risk & Delay Detection
Flag tasks that are overdue or frequently delayed.
Suggest workflow optimizations to reduce risk.
4. Trend & Pattern Recognition
Detect recurring issues, such as specific task categories taking longer than expected.
Provide recommendations for improving efficiency based on historical data.
5. AI-Driven Recommendations
Propose task redistributions if workload imbalance is detected.
Suggest automation or AI-powered enhancements for repetitive tasks.
Provide improvement suggestions for vague or ambiguous task descriptions.

** Constraints & Rules **:
Be data-driven and concise – prioritize insights over generic statements.
Ensure objectivity – avoid assumptions beyond the given data.
Adapt dynamically – respond intelligently to new data and evolving workflows.
Respect privacy – do not expose or infer confidential user information.

Example AI Response:
Input:
Date Now: MM/DD/YYYY
[
  {"title": "Bug Fix: Login Issues", "assignedTo": "userA", "dueDate": "2025-02-26", "status": "in-progress", "priority": "high", "category": "development"},
  {"title": "UI Redesign for Dashboard", "assignedTo": "userB", "dueDate": "2025-03-01", "status": "pending", "priority": "medium", "category": "design"},
  {"title": "Market Research Report", "assignedTo": "userC", "dueDate": "2025-02-25", "status": "pending", "priority": "high", "category": "analysis"}
]
Output:
UserA’s high-priority bug fix is in progress – ensure it’s completed before the deadline to avoid further issues.
Market Research Report is at risk – it is due tomorrow but remains pending. Assign additional support or adjust the deadline.
UI redesign has a low urgency – but pending tasks should be tracked to prevent last-minute delays.


!!!Important!!!
No asterisks and titles when displaying output. Keep the output minimal.
No numbering for each recommendation 1. 2. 3. ....
Use only 5-15 words per prediction.
always add the <think> </think> tags when thinking so i can remove them for abstraction
''';
  late String formattedTasks;
  String aiPredictions = "Loading predictions...";

  String formatTasks(List<Map<String, dynamic>> tasks) {

    var formattedTasks = tasks.map((task) {
      return task.map((key, value) {
        if (key == 'due_date' || key == 'created_at') {
          DateTime dateTime;
          if (value is Timestamp) {
            dateTime = value.toDate();
          } else if (value is String) {
            dateTime = DateTime.parse(value);
          } else {
            return MapEntry(key, value);
          }
          return MapEntry(key, DateFormat('MM/dd/yyyy').format(dateTime));
        } else if (key == 'assigned_to' && userMap.containsKey(value)) {
          return MapEntry(key, userMap[value]);
        }
        return MapEntry(key, value);
      });
    }).toList();

    String jsonString = jsonEncode(formattedTasks);

    String formattedString = jsonString
        .replaceAll('{', '{\n  ')
        .replaceAll('}', '\n}')
        .replaceAll('[', '[\n')
        .replaceAll(']', '\n]')
        .replaceAll(',', ',\n  ');

    return formattedString;
  }

  Future<void> _sendMessage() async {
    GroqResponse response = await _groq.sendMessage("Date Now: ${DateTime.now()}\n$formattedTasks");
    ChatMessage responseMessage = ChatMessage(
      text: response.choices.first.message.content,
    );
    if(!responseMessage.text.contains(r"</think>")){
      _sendMessage();
    }
    else{
      setState(() {
        aiPredictions = removeThinkTags(responseMessage.text);
      });
    }
  }

  String removeThinkTags(String input) {
    final regex = RegExp(r'<think>.*?<\/think>', dotAll: true);
    final String removedThinkTags = input.replaceAll(regex, '');
    return removedThinkTags.replaceAll(".", ".\n");
  }
  @override
  void initState() {
    _groq.startChat();
    _groq.setCustomInstructionsWith(instruction);
    formattedTasks = formatTasks(tasks);
    _sendMessage();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Text(aiPredictions);
  }


}
