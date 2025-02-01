import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

String baseFilePath = "";

// Configure routes.
final _router = Router()
  ..get('/', (req) => Response.ok('Server is running'))
  ..all('/<.*>', _allHandler);

Future<Response> _allHandler(Request request) async {
  var accept = request.headers["Accept"] ?? 'application/json';
  var (extension, contentType) = switch (accept) {
    'text/csv' => ('csv', accept),
    'text/html' => ('html', accept),
    _ => ('json', 'application/json'),
  };

  // var filePath = '${Directory.current.path}/files/${request.url.path}.$extension';
  var filePath = '$baseFilePath/${request.url.path}.$extension';
  var file = File(filePath);

  if (await file.exists()) {
    var fileContent = await file.readAsString();
    return Response.ok(fileContent, headers: {'content-type': contentType});
  }
  return Response.notFound('${request.url.path} could not find $filePath');
}

void main(List<String> args) async {
  baseFilePath = args[0];
  final server = await serve(
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call), // Configure a pipeline that logs requests.
      InternetAddress.anyIPv4, // Use any available host or container IP (usually `0.0.0.0`).
      8081);
  print('Server listening on http://localhost:${server.port}');
}
