import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'calendar_section.dart';
import 'gemini_section.dart';
import 'plant_shelf.dart';

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:Row(
        // Stretch makes the children fill the full vertical height of the screen
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
           // flex: 1 means this takes up 1/3rd of the available width
          Expanded(flex: 2, child: PlantShelf()),
          VerticalDivider(width: 1),
          Expanded(flex: 2, child: CalendarSection()),
          VerticalDivider(width: 1),
          // flex: 2 means this takes up 2/3rds of the available width
          Expanded(flex: 3, child: GeminiSection()),
        ],
      ),
    ));
  }
}
