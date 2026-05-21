import 'dart:convert';
import 'dart:io';

import 'package:demo/core/config.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

class AIService {
  final Genkit _ai;
  final List<String> _history = [];

  AIService(String apiKey) : _ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);

  Future<Map<String, dynamic>> ask(
    String prompt, {
    String prefix = 'User',
  }) async {
    _history.add('$prefix: $prompt');

    // Parse for [image: /path/to/image.png]
    final imageRegex = RegExp(r'\[image:\s*(.+?)\]');
    final match = imageRegex.firstMatch(prompt);

    final contentParts = <Part>[TextPart(text: _prompt())];

    if (match != null) {
      final imagePath = match.group(1)!;
      final file = File(imagePath);
      if (await file.exists()) {
        final ext = imagePath.split('.').last.toLowerCase();
        final mimeType = ext == 'jpg' || ext == 'jpeg'
            ? 'image/jpeg'
            : 'image/png';
        final base64Image = base64Encode(await file.readAsBytes());
        contentParts.add(
          MediaPart(
            media: Media(
              url: 'data:$mimeType;base64,$base64Image',
              contentType: mimeType,
            ),
          ),
        );
      }
    }

    final res = await _ai.generate(
      model: googleAI.gemini(AppConfig.model),
      messages: [Message(role: Role.user, content: contentParts)],
    );

    var raw = res.text;
    _history.add('Assistant: $raw');

    var cleanText = raw.trim();
    if (cleanText.startsWith('```')) {
      cleanText = cleanText.replaceAll(
        RegExp(r'^```(json)?\n?', multiLine: false),
        '',
      );
      cleanText = cleanText.replaceAll(
        RegExp(r'\n?```$', multiLine: false),
        '',
      );
    }

    try {
      final jsonResponse = jsonDecode(cleanText);
      if (jsonResponse is Map<String, dynamic>) {
        if (res.usage != null) {
          jsonResponse['_tokens'] = res.usage?.totalTokens ?? 0;
        }
        return jsonResponse;
      }
      return {'action': 'chat', 'message': 'Invalid JSON format: $raw'};
    } catch (e) {
      return {
        'action': 'chat',
        'message': 'Failed to parse JSON: $e. Raw: $raw',
      };
    }
  }

  String _prompt() =>
      '''
You are a helpful AI CLI assistant managing a workspace.
Return JSON only matching this exact structure:

{
 "action": "create|read|update|append|delete|list|rename|run|chat",
 "path": "target path",
 "content": "file content (create/update/append), or command (run), or new path (rename)",
 "message": "message to user"
}

If you receive a 'System' message with the result of a previous action, evaluate if you need to take another action to fulfill the User's original request.
If you are finished with all steps, return action: "chat" and your final message.

History:
${_history.join('\n')}

Based on the history above, respond to the latest User message with the appropriate JSON action.
Assistant:''';
}
