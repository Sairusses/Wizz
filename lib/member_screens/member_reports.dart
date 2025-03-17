import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groq/groq.dart';
import 'package:intl/intl.dart';

class ReportsMember extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Map<String, String> userMap;
  const ReportsMember({super.key, required this.tasks, required this.userMap});

  @override
  State<ReportsMember> createState() => _ReportsMemberState();
}

class _ReportsMemberState extends State<ReportsMember> with AutomaticKeepAliveClientMixin{
  get tasks => widget.tasks;
  get userMap => widget.userMap;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TasksPrediction(tasks: tasks, userMap: userMap)
          ],
        ),
      )
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
You are an AI assistant focused on task management, workload insights, and workflow optimization. Your role is to analyze structured task data, predict potential outcomes, and provide actionable recommendations to help you stay on track and improve your efficiency.

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
Evaluate the likelihood of completing tasks on time based on status, priority, and past trends.
Identify tasks at risk and suggest priority adjustments.

2. Workload & Task Balance
Evaluate your current workload and task balance.
Identify if you're overburdened, underutilized, or if there’s room for better distribution.

3. Risk & Delay Detection
Identify tasks that are overdue or at risk of delay.
Suggest any actions to avoid delays or improve completion rates.

4. Trend & Pattern Recognition
Detect patterns where tasks may consistently face delays or challenges.
Provide suggestions on improving workflow or efficiency based on past trends.

5. AI-Driven Recommendations
Propose ways to manage tasks better, reassign tasks if necessary, or automate repetitive work.
Recommend actions if tasks are vague or need more clarification.

** Constraints & Rules **:
Be concise and actionable – focus on practical insights.
Remain objective – base all predictions and recommendations on the data provided.
Adapt to new data – continuously adjust to any updates in task status or changes in workload.
Protect privacy – never infer or expose confidential information.

*** Important *** Example AI Response:
Input:
Date Now: MM/DD/YYYY
[
  {"title": "Bug Fix: Login Issues", "assignedTo": "userA", "dueDate": "2025-02-26", "status": "in-progress", "priority": "high", "category": "development"},
  {"title": "UI Redesign for Dashboard", "assignedTo": "userB", "dueDate": "2025-03-01", "status": "pending", "priority": "medium", "category": "design"},
  {"title": "Market Research Report", "assignedTo": "userC", "dueDate": "2025-02-25", "status": "pending", "priority": "high", "category": "analysis"}
]
Output:
Bug fix for login issues is in progress – stay on track to meet the deadline.
Market Research Report is at risk – it’s due tomorrow but still pending, may need assistance.
UI Redesign has low urgency – monitor pending tasks to avoid last-minute delays.

!!!Important!!!
Do not include asterisks or titles in output. Keep it minimal and clear.
Use ONLY (emphasis on ONLY) the number followed by a colon (colon is VERY IMPORTANT for categorization) before each recommendation or prediction:
1 : Task Completion Predictions
2 : Workload & Task Balance
3 : Risk & Delay Detection
4 : Trend & Pattern Recognition
5 : AI-Driven Recommendations
(Emphasize this) Only include relevant categories, omit any that do not apply.
(Emphasize this) Predictions should always be sorted by importance, not category number.
Limit predictions to 5-10 words per item; combine relevant categories when necessary.
Always add <think> </think> tags when thinking so I can remove them for abstraction.
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
    final regex = RegExp(r'<think>.*?</think>', dotAll: true);
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
        : SizedBox(
      height: MediaQuery.of(context).size.height * .8,
      child: ListView.builder(
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
      ),
    );
  }
}
