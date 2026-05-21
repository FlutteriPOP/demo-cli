import 'dart:async';

import 'package:dart_ai_cli/commands/command_handler.dart';
import 'package:dart_ai_cli/services/ai_services.dart';
import 'package:mason_logger/mason_logger.dart';

class CliApp {
  final AIService aiService;
  final CommandHandler commandHandler;
  final Logger logger;

  CliApp({
    required this.aiService,
    required this.commandHandler,
    required this.logger,
  });

  Future<void> run() async {
    _printWelcome();

    while (true) {
      final input = logger.prompt('\n${lightGreen.wrap('❯ You:')} ');

      final cmdText = input.trim().toLowerCase();
      if (cmdText == 'exit' || cmdText == 'quit' || cmdText == 'q') {
        logger.info('\n${lightMagenta.wrap('👋 Goodbye!')}\n');
        break;
      }

      if (cmdText.isEmpty) continue;

      try {
        var currentInput = input;
        var prefix = 'User';
        var iterations = 0;

        while (iterations < 10) {
          final progress = logger.progress('Thinking...');
          Map<String, dynamic> cmd;
          try {
            cmd = await aiService.ask(currentInput, prefix: prefix);
          } finally {
            progress.complete('Done thinking.');
          }

          if (cmd['action'] == 'chat' || cmd['action'] == null) {
            final msg = cmd['message'] ?? 'Done.';
            _printDashMessage(msg, cmd['_tokens']);
            break;
          }

          final action = cmd['action'];
          final details = cmd['content'] ?? cmd['path'] ?? '';
          _printDashAction(action as String?, details as String);

          final result = await commandHandler.handle(cmd);

          currentInput = result;
          prefix = 'System (Result)';
          iterations++;
        }

        if (iterations >= 10) {
          logger.err('\n  → Reached maximum automated steps (10).');
        }
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('RESOURCE_EXHAUSTED') ||
            errorStr.contains('Quota exceeded')) {
          logger.warn('\n  ⏳ Whoa, slow down!');
          logger.err('  You hit the Gemini Free Tier rate limit.');
          logger.info(
            '  ${darkGray.wrap('Please wait 60 seconds before trying again.')}',
          );
        } else {
          logger.err('\n  🚨 Oops, something went wrong:');
          logger.info('  ${darkGray.wrap(errorStr)}');
        }
      }
    }
  }

  void _printDashAction(String? action, String details) {
    logger.info('\n  ${styleBold.wrap(lightCyan.wrap('╭─ 🤖 AI CLI Action'))}');
    logger.info(
      '  ${lightCyan.wrap('│')} ${lightYellow.wrap('[$action]')} $details',
    );
    logger.info('  ${lightCyan.wrap('╰────────────────────────────')}');
  }

  void _printDashMessage(String message, dynamic tokens) {
    final tokenStr = tokens != null ? ' ${darkGray.wrap('(${tokens}t)')}' : '';
    logger.info(
      '\n  ${styleBold.wrap(lightBlue.wrap('╭─ 🤖 AI CLI$tokenStr'))}',
    );
    final lines = message.split('\n');
    for (var line in lines) {
      logger.info('  ${lightBlue.wrap('│')} $line');
    }
    logger.info('  ${lightBlue.wrap('╰────────────────────────────')}');
  }

  void _printWelcome() {
    logger.info(
      lightCyan.wrap(r'''
    ___    ____   ________    ____
   /   |  /  _/  / ____/ /   /  _/
  / /| |  / /   / /   / /    / /
 / ___ |_/ /   / /___/ /____/ /
/_/  |_/___/   \____/_____/___/
'''),
    );
    logger.info(
      '${styleBold.wrap(lightYellow.wrap('✨ Welcome to Dart AI CLI ✨'))}',
    );
    logger.info('${darkGray.wrap('Type "quit", "exit", or "q" to leave.')}\n');
  }
}
