import 'dart:async';
import 'dart:io';

import 'package:demo/commands/command_handler.dart';
import 'package:demo/services/ai_services.dart';

class CliApp {
  final AIService aiService;
  final CommandHandler commandHandler;

  CliApp({required this.aiService, required this.commandHandler});

  Timer _showSpinner() {
    const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var i = 0;
    return Timer.periodic(const Duration(milliseconds: 80), (timer) {
      stdout.write(
        '\r\x1B[36m${frames[i++ % frames.length]} Thinking...\x1B[0m',
      );
    });
  }

  Future<void> run() async {
    _printBanner();

    while (true) {
      stdout.write('\x1B[32m💡 You: \x1B[0m');
      final input = stdin.readLineSync();

      if (input == null) break;

      final cmdText = input.trim().toLowerCase();
      if (cmdText == 'exit' || cmdText == 'quit' || cmdText == 'q') {
        print('\n\x1B[35m👋 Goodbye!\x1B[0m\n');
        break;
      }

      if (cmdText.isEmpty) continue;

      try {
        var currentInput = input;
        var prefix = 'User';
        var iterations = 0;

        while (iterations < 10) {
          final spinner = _showSpinner();
          Map<String, dynamic> cmd;
          try {
            cmd = await aiService.ask(currentInput, prefix: prefix);
          } finally {
            spinner.cancel();
            stdout.write('\r\x1B[K'); // Clear the spinner line
          }

          if (cmd['action'] == 'chat' || cmd['action'] == null) {
            final msg = cmd['message'] ?? 'Done.';
            print('\x1B[34m→ $msg\x1B[0m');
            if (cmd['_tokens'] != null) {
              print('\x1B[90m(Tokens used: ${cmd['_tokens']})\x1B[0m\n');
            } else {
              print('');
            }
            break;
          }

          final result = await commandHandler.handle(cmd);
          var output =
              '\x1B[33m[Action: ${cmd['action']}]\x1B[36m → $result\x1B[0m';
          if (cmd['_tokens'] != null) {
            output += ' \x1B[90m(${cmd['_tokens']} tokens)\x1B[0m';
          }
          print(output);

          currentInput = result;
          prefix = 'System (Result)';
          iterations++;
        }

        if (iterations >= 10) {
          print('\x1B[31m→ Reached maximum automated steps (10).\x1B[0m\n');
        }
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('RESOURCE_EXHAUSTED') ||
            errorStr.contains('Quota exceeded')) {
          print('\n\x1B[33m⏳ Whoa, slow down!\x1B[0m');
          print(
            '\x1B[31mYou have hit the Google Gemini Free Tier rate limit.\x1B[0m',
          );
          print(
            '\x1B[90mThe Agentic Loop can process many requests very quickly. Please wait about 60 seconds before trying again.\x1B[0m\n',
          );
        } else {
          print('\n\x1B[31m🚨 Oops, something went wrong:\x1B[0m');
          print('\x1B[90m$errorStr\x1B[0m\n');
        }
      }
    }
  }

  void _printBanner() {
    print(
      '\x1B[36m'
      r'''
    ___    ____   ________    ____
   /   |  /  _/  / ____/ /   /  _/
  / /| |  / /   / /   / /    / /
 / ___ |_/ /   / /___/ /____/ /
/_/  |_/___/   \____/_____/___/

'''
      '\x1B[0m',
    );
    print('\x1B[33m✨ Welcome to the AI Workspace CLI ✨\x1B[0m');
    print('\x1B[90mType "quit", "exit", or "q" to leave.\x1B[0m\n');
  }
}
