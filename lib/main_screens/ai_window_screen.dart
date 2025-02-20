import 'package:flutter/material.dart';
import 'package:groq/groq.dart';


class AIWindowScreen extends StatefulWidget {
  const AIWindowScreen({super.key});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<AIWindowScreen> with AutomaticKeepAliveClientMixin{
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final ScrollController _scrollController = ScrollController();
  final String instruction = '''
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

**Example Response to Non-Business Questions**:
- "I specialize in business-related topics and cannot assist with this question. Please let me know if you have any business-related inquiries!"
''';

  final _groq = Groq(
    apiKey: "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",
    model: "llama-3.3-70b-versatile", // Set a different model
  );
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _groq.startChat();
    _groq.setCustomInstructionsWith(instruction);
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
      appBar: AppBar(
        title: const Text('Gabby AI'),
        actions: [_buildClearChatButton()],
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
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
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

      ChatMessage responseMessage = ChatMessage(
        text: response.choices.first.message.content,
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
    final ThemeData theme = Theme.of(context);
    final CrossAxisAlignment crossAxisAlignment =
    isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUserMessage
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.tertiaryContainer,
            borderRadius: isUserMessage
                ? const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(0.0),
            )
                : const BorderRadius.only(
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