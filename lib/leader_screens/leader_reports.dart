import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groq/groq.dart';
import 'package:intl/intl.dart';

class ReportsLeader extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Map<String, String> userMap;
  final int teamBudget;
  final int teamBudgetSpent;
  const ReportsLeader({super.key, required this.tasks, required this.userMap, required this.teamBudget, required this.teamBudgetSpent});

  @override
  ReportsLeaderState createState() => ReportsLeaderState();
}

class ReportsLeaderState extends State<ReportsLeader> with AutomaticKeepAliveClientMixin{
  get tasks => widget.tasks;
  get userMap => widget.userMap;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tasks Prediction", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            SizedBox(
              height: 160,
              child: TasksPrediction(tasks: tasks, userMap: userMap),
            )
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
      title: Text('Reports',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20
        ),
      ),
    );
  }
}

class TasksPrediction extends StatefulWidget{
  final List<Map<String, dynamic>> tasks;
  final Map<String, String> userMap;
  const TasksPrediction({super.key, required this.tasks, required this.userMap});

  @override
  TasksPredictionState createState() => TasksPredictionState();
}

class TasksPredictionState extends State<TasksPrediction>{
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

*** Important *** Example AI Response:
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
Add ONLY (emphasis on ONLY) the number followed by a colon (colon is VERY IMPORTANT for splitting strings) before each recommendations/predictions to categorize. Here are the numbers representing each category:
1 : Task Completion Predictions
2 : Team Performance & Workload Analysis
3 : Risk & Delay Detection
4 : Trend & Pattern Recognition
5 : AI-Driven Recommendations
(Emphasis on this) )You can disregard a category if not applicable nor relevant. 
(Emphasis on this) The predictions should always sorted by importance, not the number.
Use only 5-15 words per prediction.
always add the <think> </think> tags when thinking so i can remove them for abstraction
''';
  late List<Map<String, dynamic>> predictions = [];
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
    String responseMessage = response.choices.first.message.content;
    int retries = 0;
    if(retries > 3){
      setState(() {
        predictions = [{"number": "0", "message": "Failed to load AI predictions."}];
      });
      return;
    }
    if(!responseMessage.contains(r"</think>") && !responseMessage.contains(r"</think>") && !responseMessage.contains(":")){
      _sendMessage();
      retries += 1;
    }
    else{
      setState(() {
        aiPredictions = removeThinkTags(responseMessage);
        predictions = parsePredictions(aiPredictions);
      });
    }
  }

  String removeThinkTags(String input) {
    final regex = RegExp(r'<think>.*?<\/think>', dotAll: true);
    final String removedThinkTags = input.replaceAll(regex, '');
    return removedThinkTags;
  }

  List<Map<String, dynamic>> parsePredictions(String response) {
    List<Map<String, dynamic>> predictions = [];
    List<String> lines = response.trim().split("\n");

    for (String line in lines) {
      RegExp regex = RegExp(r'(\d+): (.+)');
      Match? match = regex.firstMatch(line);

      if (match != null) {
        int number = int.parse(match.group(1)!);
        String message = match.group(2)!;

        predictions.add({"number": number, "message": message});
      }
    }
    return predictions;
  }

  IconData getIcon(int number) {
    switch (number) {
      case 1:
        return Icons.access_time ;
      case 2:
        return Icons.emoji_events ;
      case 3:
        return Icons.trending_up ;
      case 4:
        return Icons.warning ;
      case 5:
        return Icons.lightbulb;
      default:
        return Icons.help_outline;
    }
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
    return predictions.isEmpty
      ? SpinKitThreeInOut(color: Colors.blueGrey, size: 30,)
      : ListView.builder(
      itemExtent: 80,
      shrinkWrap: true,
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.all(4),
          child: ListTile(
            leading: Icon(getIcon(prediction["number"]), size: 30, color: Colors.black),
            title: Text(prediction["message"], style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
        );
      },
    );
  }
}

class BudgetForecast extends StatefulWidget{
  final int teamBudget;
  final int teamBudgetSpent;
  const BudgetForecast({super.key, required this.teamBudget, required this.teamBudgetSpent});

  @override
  BudgetForecastState createState() => BudgetForecastState();
}

class BudgetForecastState extends State<BudgetForecast>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

}