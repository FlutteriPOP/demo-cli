import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_ai_cli/commands/command_handler.dart';
import 'package:dart_ai_cli/core/path_guard.dart';
import 'package:dart_ai_cli/services/ai_services.dart';
import 'package:dart_ai_cli/services/file_service.dart';
import 'package:dart_ai_cli/ui/cli.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mason_logger/mason_logger.dart';

Future<void> main(List<String> arguments) async {
  final logger = Logger();

  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Show detailed logging.');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    logger.err(e.toString());
    printUsage(parser, logger);
    exit(1);
  }

  if (argResults['help'] as bool) {
    printUsage(parser, logger);
    exit(0);
  }

  if (argResults['verbose'] as bool) {
    logger.level = Level.verbose;
  }

  final env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    logger.err('GEMINI_API_KEY is not set in .env file');
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
    logger: logger,
  );

  await app.run();
}

void printUsage(ArgParser parser, Logger logger) {
  logger.info('\nUsage: dart run bin/dart_ai_cli.dart [arguments]');
  logger.info(parser.usage);
}
