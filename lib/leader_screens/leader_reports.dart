import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groq/groq.dart';
import 'package:intl/intl.dart';

class ReportsLeader extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Map<String, String> userMap;
  final int teamBudget;
  final int teamBudgetSpent;
  final List<Map<String, dynamic>> budgetList;
  const ReportsLeader({super.key, required this.tasks, required this.userMap, required this.teamBudget, required this.teamBudgetSpent, required this.budgetList});

  @override
  ReportsLeaderState createState() => ReportsLeaderState();
}

class ReportsLeaderState extends State<ReportsLeader> with AutomaticKeepAliveClientMixin{
  get tasks => widget.tasks;
  get userMap => widget.userMap;
  get budgetList => widget.budgetList;
  get teamBudget => widget.teamBudget;
  get teamBudgetSpent => widget.teamBudgetSpent;

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
            Text("AI Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            TasksPrediction(tasks: tasks, userMap: userMap),
            SizedBox(height: 10,),
            Text("Budget Forecast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            SizedBox(height: 10,),
            BudgetChart(teamBudget: teamBudget, budgetList: budgetList),
            SizedBox(height: 10,),
            BudgetForecast(budgetList: budgetList, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent)
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
(Emphasis on this) The predictions should always sort by importance, not the number.
Use ONLY 5-10 words per prediction, you can concatenate to another task category.
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
      : SizedBox(
        height: 170,
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

class BudgetChart extends StatefulWidget{
  final int teamBudget;
  final List<Map<String, dynamic>> budgetList;
  const BudgetChart({super.key, required this.teamBudget,  required this.budgetList});

  @override
  BudgetChartState createState() => BudgetChartState();
}

class BudgetChartState extends State<BudgetChart>{
  get budgetList => widget.budgetList;
  get teamBudget => widget.teamBudget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('MM/dd/yyyy');

    List<Map<String, dynamic>> sortedData = List.from(budgetList);
    sortedData.sort((a, b) => dateFormat.parse(a['created_at']).compareTo(dateFormat.parse(b['created_at'])));

    List<FlSpot> spots = sortedData.asMap().entries.map((entry) {
      int index = entry.key;
      double budget = (entry.value['budget'] as int).toDouble();
      return FlSpot(index.toDouble(), budget);
    }).toList();

    return AspectRatio(
      aspectRatio: 2.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 100 == 0) {
                    return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                  }
                  return Container();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sortedData.length) {
                    return Text(
                      DateFormat('MM/dd').format(dateFormat.parse(sortedData[index]['created_at'])),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              preventCurveOverShooting: true,
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
            )
          ],
        ),
      ),
    );
  }

}

class BudgetForecast extends StatefulWidget{
  final List<Map<String, dynamic>> budgetList;
  final int teamBudget;
  final int teamBudgetSpent;
  const BudgetForecast({super.key, required this.budgetList, required this.teamBudget, required this.teamBudgetSpent});
  @override
  BudgetForecastState createState() => BudgetForecastState();
}

class BudgetForecastState extends State<BudgetForecast>{
  final _groq = Groq(
    apiKey: "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",
    model: "deepSeek-r1-distill-llama-70b",
  );
  final String instructions =
  ''' 
Objective:
The AI Agent will analyze budget allocation and spending trends based on the provided data. It will generate insights in a concise paragraph (10-25 words).

Response Format:

Keep the response between 15-30 words.
Provide a high-level insight into budget distribution, spending trends, or potential concerns.
Example Insight:
The budget is nearly exhausted, with large allocations for the project deadline and UI design. Future expenses should be carefully planned within the remaining budget.
''';

  get budgetList => widget.budgetList;
  get teamBudget => widget.teamBudget;
  get teamBudgetSpent => widget.teamBudgetSpent;

  late String formattedBudget;
  String aiForecast = "Loading budget forecast...";

  Future<void> _sendMessage() async {
    GroqResponse response = await _groq.sendMessage(formattedBudget);
    String responseMessage = response.choices.first.message.content;
    int retries = 0;
    if(retries > 3){
      aiForecast = "Failed fetching AI Budget Forecast,";
      return;
    }
    if(!responseMessage.contains(r"</think>") && !responseMessage.contains(r"</think>") && !responseMessage.contains(":")){
      _sendMessage();
      retries += 1;
    }
    else{
      setState(() {
        aiForecast = removeThinkTags(responseMessage);
        aiForecast.trimLeft();
      });
    }
  }

  String formatBudget(List<Map<String, dynamic>> budgetList, int teamBudget, int teamBudgetSpent){
    int remainingBudget = teamBudget - teamBudgetSpent;

    String jsonString = jsonEncode(budgetList);
    String formattedString = jsonString
        .replaceAll('{', '{\n  ')
        .replaceAll('}', '\n}')
        .replaceAll('[', '[\n')
        .replaceAll(']', '\n]')
        .replaceAll(',', ',\n  ');

    String returnString = '''
total budget: $teamBudget
spent budget: $teamBudgetSpent
remaining budget: $remainingBudget
    
budget data:
$formattedString
    ''';

    return returnString;
  }

  String removeThinkTags(String input) {
    final regex = RegExp(r'<think>.*?<\/think>', dotAll: true);
    final String removedThinkTags = input.replaceAll(regex, '');
    return removedThinkTags;
  }

  @override
  void initState() {
    super.initState();
    formattedBudget = formatBudget(budgetList, teamBudget, teamBudgetSpent);
    _groq.startChat();
    _groq.setCustomInstructionsWith(instructions);
    _sendMessage();
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '      ${aiForecast.trimLeft()}',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w400
        ),
      ),
    );
  }

}