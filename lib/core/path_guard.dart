import 'dart:io';
import 'package:path/path.dart' as p;

class PathGuard {
  final Directory workspace;

  PathGuard(this.workspace);

  String safe(String path) {
    final fullPath = p.normalize(p.join(workspace.absolute.path, path));

    if (!fullPath.startsWith(workspace.absolute.path)) {
      throw Exception('Access denied');
    }

    return fullPath;
  }
}
