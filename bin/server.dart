// ignore_for_file: avoid_print

import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_docker_shutdown/shelf_docker_shutdown.dart';
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final host = Platform.environment['HOST'] ?? 'localhost';

  final handler = createStaticHandler(
    'build/web',
    defaultDocument: 'index.html',
  );

  final server = await io.serve(handler, host, port);
  print('Serving at http://${server.address.host}:${server.port}');
  await server.closeOnTermSignal();
}
