import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_ai_cli/core/path_guard.dart';
import 'package:dart_ai_cli/services/file_service.dart';

void main() {
  group('FileService', () {
    late Directory workspace;
    late PathGuard guard;
    late FileService fileService;

    setUp(() async {
      workspace = Directory('${Directory.systemTemp.path}/test_workspace_file');
      if (!await workspace.exists()) {
        await workspace.create();
      }
      guard = PathGuard(workspace);
      fileService = FileService(guard);
    });

    tearDown(() async {
      if (await workspace.exists()) {
        await workspace.delete(recursive: true);
      }
    });

    test('creates and reads file', () async {
      final createRes = await fileService.create('test.txt', 'hello world');
      expect(createRes, contains('File created'));

      final readRes = await fileService.read('test.txt');
      expect(readRes, 'hello world');
    });

    test('updates file', () async {
      await fileService.create('test.txt', 'hello');
      final updateRes = await fileService.update('test.txt', 'world');
      expect(updateRes, contains('File updated'));

      final readRes = await fileService.read('test.txt');
      expect(readRes, 'world');
    });

    test('deletes file', () async {
      await fileService.create('test.txt', 'hello');
      final deleteRes = await fileService.delete('test.txt');
      expect(deleteRes, contains('File deleted'));

      final readRes = await fileService.read('test.txt');
      expect(readRes, 'File not found');
    });
  });
}
