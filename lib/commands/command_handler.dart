import 'dart:io';

import 'package:dart_ai_cli/services/file_service.dart';

class CommandHandler {
  CommandHandler(this.service, this.workspacePath);
  final FileService service;
  final String workspacePath;

  Future<String> handle(Map<String, dynamic> cmd) async {
    switch (cmd['action']) {
      case 'create':
        return service.create(
          cmd['path']?.toString() ?? '',
          cmd['content']?.toString() ?? '',
        );

      case 'read':
        return service.read(cmd['path']?.toString() ?? '');

      case 'update':
        return service.update(
          cmd['path']?.toString() ?? '',
          cmd['content']?.toString() ?? '',
        );

      case 'append':
        return service.append(
          cmd['path']?.toString() ?? '',
          cmd['content']?.toString() ?? '',
        );

      case 'delete':
        return service.delete(cmd['path']?.toString() ?? '');

      case 'list':
        return service.list(cmd['path']?.toString() ?? '');

      case 'rename':
        return service.rename(
          cmd['path']?.toString() ?? '',
          cmd['content']?.toString() ?? '',
        );

      case 'run':
        try {
          final process = await Process.run('sh', [
            '-c',
            cmd['content']?.toString() ?? '',
          ], workingDirectory: workspacePath);
          final out = process.stdout.toString().trim();
          final err = process.stderr.toString().trim();
          final res = StringBuffer('Executed: ${cmd['content']}');
          if (out.isNotEmpty) res.write('\nStdout:\n$out');
          if (err.isNotEmpty) res.write('\nStderr:\n$err');
          return res.toString();
        } catch (e) {
          return 'Failed to execute: $e';
        }

      case 'chat':
      default:
        return cmd['message']?.toString() ?? '';
    }
  }
}
