import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('127.0.0.1', 7277,);

  print('Local server listening on port 8080');

  await for (HttpRequest request in server) {
    if (request.method == 'GET') {
      // Handle GET request
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({'message': 'Hello, local server!'}))
        ..close();
    } else {
      // Handle other request methods if needed
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Method not allowed')
        ..close();
    }
  }
}
