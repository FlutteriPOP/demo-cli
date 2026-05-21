import 'dart:io';

import 'package:dart_ai_cli/core/path_guard.dart';

class FileService {
  final PathGuard guard;

  FileService(this.guard);

  Future<String> create(String path, String content) async {
    final file = File(guard.safe(path));
    await file.create(recursive: true);
    await file.writeAsString(content);
    return 'File created: $path';
  }

  Future<String> read(String path) async {
    final file = File(guard.safe(path));

    if (!await file.exists()) return 'File not found';

    return file.readAsString();
  }

  Future<String> update(String path, String content) async {
    final file = File(guard.safe(path));

    if (!await file.exists()) return 'File not found';

    await file.writeAsString(content);
    return 'File updated: $path';
  }

  Future<String> append(String path, String content) async {
    final file = File(guard.safe(path));

    if (!await file.exists()) return 'File not found';

    await file.writeAsString(content, mode: FileMode.append);
    return 'Appended to file: $path';
  }

  Future<String> delete(String path) async {
    final file = File(guard.safe(path));

    if (await file.exists()) {
      await file.delete();
      return 'File deleted: $path';
    }

    return 'File not found';
  }

  Future<String> list(String path) async {
    final dir = Directory(guard.safe(path));

    if (!await dir.exists()) return 'Directory not found';

    final entities = await dir.list().toList();
    final names = entities
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .join(', ');
    return 'Contents of $path: $names';
  }

  Future<String> rename(String oldPath, String newPath) async {
    final file = File(guard.safe(oldPath));
    final newFile = guard.safe(newPath);

    if (await file.exists()) {
      await file.rename(newFile);
      return 'Renamed $oldPath to $newPath';
    }

    return 'File not found';
  }
}
