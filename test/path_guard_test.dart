import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_ai_cli/core/path_guard.dart';

void main() {
  group('PathGuard', () {
    late Directory workspace;
    late PathGuard guard;

    setUp(() async {
      workspace = Directory('${Directory.systemTemp.path}/test_workspace');
      if (!await workspace.exists()) {
        await workspace.create();
      }
      guard = PathGuard(workspace);
    });

    tearDown(() async {
      if (await workspace.exists()) {
        await workspace.delete(recursive: true);
      }
    });

    test('safe returns correct path for valid file', () {
      final safePath = guard.safe('hello.txt');
      expect(safePath, startsWith(workspace.path));
      expect(safePath, endsWith('hello.txt'));
    });

    test('safe throws exception for path outside workspace', () {
      expect(() => guard.safe('../outside.txt'), throwsException);
      expect(() => guard.safe('/etc/passwd'), throwsException);
    });
  });
}
