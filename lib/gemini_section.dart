import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiSection extends StatefulWidget {
  const GeminiSection({super.key});

  @override
  State<GeminiSection> createState() => _GeminiSectionState();
}

class _GeminiSectionState extends State<GeminiSection> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  // Retrieves the key injected at build time via secrets.json
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<void> _queryGemini() async {
    if (_controller.text.isEmpty) return;
    if (_apiKey.isEmpty) {
      setState(() => _response = 'Error: API Key not found. Check secrets.json');
      return;
    }

    setState(() => _loading = true);

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final content = [Content.text(_controller.text)];
      final response = await model.generateContent(content);
      
      setState(() {
        _response = response.text ?? 'No response returned.';
      });
    } catch (e) {
      setState(() {
        _response = 'Error occurred: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Ask Gemini something...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _queryGemini,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (_loading) const CircularProgressIndicator(),
          if (!_loading && _response.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}