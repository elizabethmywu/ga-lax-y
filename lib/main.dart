import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Example"),
        ),
        body: const AIIntegration(),
      ),
    );
  }
}

class AIIntegration extends StatefulWidget {
  const AIIntegration({super.key});

  @override
  State<AIIntegration> createState() => _AIIntegrationState();
}

class _AIIntegrationState extends State<AIIntegration> {
  final Gemini gemini = Gemini.instance;
  String? generatedResponse;
  bool isLoading = false;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            style: const TextStyle(
              fontSize: 18,
            ),
            controller: textEditingController,
          ),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Center(
              child: ElevatedButton(
                onPressed: () {
                  gemini.prompt(parts: [
                    Part.text(textEditingController.text),
                  ]).then((value) {
                    setState(() {
                      generatedResponse = value?.output;
                      isLoading = false;
                    });
                  }).catchError((e) {
                    setState(() {
                      isLoading = false;
                    });
                    print('Error: $e');
                  });
                },
                child: const Text("Generate Content"),
              ),
            ),
          const SizedBox(height: 20),
          if (generatedResponse != null)
            Text(generatedResponse!),
        ],
      ),
    );
  }
}
