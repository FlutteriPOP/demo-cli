import 'dart:io';

import 'package:demo/core/path_guard.dart';
import 'package:demo/services/ai_services.dart';
import 'package:demo/services/file_service.dart';
import 'package:demo/commands/command_handler.dart';
import 'package:demo/ui/cli.dart';
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['GEMINI_API_KEY'];
  
  if (apiKey == null || apiKey.isEmpty) {
    print('\x1B[31mError: GEMINI_API_KEY is not set in .env file\x1B[0m');
    exit(1);
  }

  final workspace = Directory('${Directory.current.path}/workspace');

  if (!await workspace.exists()) {
    await workspace.create(recursive: true);
  }

  final guard = PathGuard(workspace);
  final fileService = FileService(guard);
  final ai = AIService(apiKey);
  final commandHandler = CommandHandler(fileService, workspace.path);

  final app = CliApp(
    aiService: ai,
    commandHandler: commandHandler,
  );

  await app.run();
}

