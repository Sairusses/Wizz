import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'package:intl/intl.dart';


class AIWindowScreen extends StatefulWidget {
  final List<Map<String, dynamic>> budgetList;
  final List<Map<String, dynamic>> allTasks;
  final Map<String, String> userMap;
  final int teamBudget;
  final int teamBudgetSpent;
  const AIWindowScreen({super.key, required this.budgetList, required this.allTasks, required this.teamBudget, required this.teamBudgetSpent, required this.userMap});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<AIWindowScreen> with AutomaticKeepAliveClientMixin{
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final ScrollController _scrollController = ScrollController();
  final String instruction = ('''
You are a highly specialized business assistant. Your sole purpose is to respond to **business-related questions**. This includes topics such as: 

- Finance and accounting
- Marketing and sales strategies
- Management and leadership
- Business development
- Entrepreneurship
- Human resources
- Operations and logistics
- Business technology and software
- Industry-specific practices and trends

**Guidelines**:
1. Politely decline to answer any question that is not related to business, providing a brief explanation.
2. Maintain a professional tone and prioritize clarity, accuracy, and practicality in your responses.
3. Focus on providing actionable insights and avoiding overly theoretical or speculative answers.
4. If a question has legal or region-specific implications, suggest consulting a qualified expert while providing general guidance if applicable.
5. Do not use hashtags (#) or asterisks (*) for bolding texts since the project does not support it
6. Keep the text minimal (up to 50 words max) while still providing powerful answers.

**Example Response to Non-Business Questions**:
- "I specialize in business-related topics and cannot assist with this question. Please let me know if you have any business-related inquiries!"
**User info about the project: **\n
''');

  get budgetList => widget.budgetList;
  get allTasks => widget.allTasks;
  get userMap => widget.userMap;
  get teamBudget => widget.teamBudget;
  get teamBudgetSpent => widget.teamBudgetSpent;

  final _groq = Groq(
    apiKey: "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",
    model: "deepSeek-r1-distill-llama-70b",
  );

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _groq.startChat();
    String budgetString = formatBudget(budgetList, teamBudget, teamBudgetSpent);
    String taskString = formatTasks(allTasks);
    _groq.setCustomInstructionsWith(instruction + budgetString + taskString);
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

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true,
    );
    setState(() {
      _messages.add(message);
    });

    _scrollToBottomWithDelay(
      const Duration(milliseconds: 200),
    );

    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image(
              image: AssetImage("assets/ai_icon.png"),
              width: 40,
              height: 40,
            ),
            SizedBox(width: 15,),
            Text('Wizz AI Assistant',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20
              ),
            ),
          ],
        ),
        scrolledUnderElevation: 0,
        actions: [
          _buildClearChatButton(),
          SizedBox(width: 20,)
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black54,
              height: .5,
            )
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (_, int index) => _messages[index],
              ),
            ),
            const Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .1,)
          ],
        ),
      ),
    );
  }

  Widget _buildClearChatButton() {
    return IconButton(
      onPressed: () {
        _groq.clearChat();
      },
      icon: const Icon(Icons.delete),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Send a message',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  _scrollToBottomWithDelay(Duration delay) async {
    await Future.delayed(delay);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  _sendMessage(String text) async {
    try {
      GroqResponse response = await _groq.sendMessage(text);

      final regex = RegExp(r'<think>.*?<\/think>', dotAll: true);
      final String removedThinkTags =  response.choices.first.message.content.replaceAll(regex, '');

      ChatMessage responseMessage = ChatMessage(
        text: removedThinkTags.trimLeft(),
        isUserMessage: false,
      );


      setState(() {
        _messages.add(responseMessage);
      });

    } on GroqException catch (error) {
      ErrorMessage errorMessage = ErrorMessage(
        text: error.message,
      );

      setState(() {
        _messages.add(errorMessage);
      });
    }
    _scrollToBottomWithDelay(
      const Duration(milliseconds: 300),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  const ChatMessage(
      {super.key, required this.text, this.isUserMessage = false});

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment crossAxisAlignment =
    isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
            color: isUserMessage
                ? Colors.blueAccent
                : Colors.white,
            borderRadius: isUserMessage
                ? const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(0.0),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(12.0),
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUserMessage ? Colors.white : Colors.black
            ),
          ),
        ),
      ],
    );
  }
}

class ErrorMessage extends ChatMessage {
  const ErrorMessage({super.key, required super.text});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}