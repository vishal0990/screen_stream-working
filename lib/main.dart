import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import 'homescreen.dart';

ScreenshotController screenshotController = ScreenshotController();

void main() {
  runApp(Screenshot(controller: screenshotController, child: ScreenShareApp()));
}

class ScreenShareApp extends StatelessWidget {
  const ScreenShareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenShareScreen(),
    );
  }
}

class ScreenShareScreen extends StatefulWidget {
  @override
  _ScreenShareScreenState createState() => _ScreenShareScreenState();
}

class _ScreenShareScreenState extends State<ScreenShareScreen> {
  String? localIp;
  late Stream<Uint8List?> _screenCaptureStream;
  HttpServer? server;

  @override
  void initState() {
    super.initState();
    _startLocalServer();
    _screenCaptureStream = _createScreenCaptureStream().asBroadcastStream();
  }

  /// Create a stream to periodically capture the screen
  Stream<Uint8List?> _createScreenCaptureStream() async* {
    while (true) {
      await Future.delayed(
          Duration(microseconds: 1)); // Adjust interval as needed
      try {
        Uint8List? image = await screenshotController.capture(
            delay: Duration(microseconds: 1));
        debugPrint("image:-$image");
        yield image;
      } catch (e) {
        debugPrint("Error capturing screenshot: $e");
        yield null;
      }
    }
  }

  /// Start the HTTP server
  Future<void> _startLocalServer() async {
    // Get the local IP address
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          setState(() {
            localIp = addr.address;
          });
          break;
        }
      }
    }

    // Start the HTTP server
    server = await HttpServer.bind(localIp, 8080, shared: true);
    debugPrint('Server running on http://$localIp:8080');

    server?.listen((HttpRequest request) async {
      if (request.uri.path == '/stream') {
        // Set up MJPEG headers
        const boundary = "boundaryImage";
        request.response.headers.contentType = ContentType(
            "multipart", "x-mixed-replace",
            parameters: {"boundary": boundary});

        // Write the boundary to the response
        try {
          await for (var jpegBytes in _screenCaptureStream) {
            if (jpegBytes != null) {
              // Write the boundary
              request.response
                ..writeln("--$boundary")
                ..writeln("Content-Type: image/jpeg")
                ..writeln("Content-Length: ${jpegBytes.length}")
                ..writeln()
                ..add(jpegBytes)
                ..writeln();

              // Flush the response to send the frame immediately
              await request.response.flush();
              await Future.delayed(Duration(microseconds: 1)); // ~10 FPS
            }
          }
        } catch (e) {
          debugPrint("Client disconnected: $e");
        } finally {
          await request.response.close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      }
    });
  }

  int _counter = 0; // Initialize the counter variable

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localIp == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increase',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10), // Add spacing between buttons
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrease',
            child: Icon(Icons.remove),
          ),
        ],
      ),
      appBar: AppBar(title: const Text('Screen Share')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homescreen()));
                  });
                },
                child: Text("Next Screen")),
            Text(
              'Counter: $_counter',
              style: TextStyle(fontSize: 24),
            ),
            Text('Server running on http://$localIp:8080'),
            const SizedBox(height: 10),
            const Text('Scan the QR Code to Connect:'),
            QrImageView(
              data: 'http://$localIp:8080/stream',
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }
}
