import 'package:groq/groq.dart';

class GroqService{
  final groq = Groq(
    apiKey: "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",
    model: "llama-3.3-70b-versatile", // Optional: specify a model
  );
  
}