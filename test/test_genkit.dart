import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['GEMINI_API_KEY'];
  if (apiKey == null) return;
  
  final ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);
  final res = await ai.generate(
    model: googleAI.gemini('gemini-flash-latest'),
    prompt: 'say hi',
  );
  
  print(res.text);
  // Let's try to inspect res
  print('Has usage?');
  try {
    print(res.usage);
  } catch(e) {
    print('No usage property');
  }
}
