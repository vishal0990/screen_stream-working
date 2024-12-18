import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _counter = 0; // Counter variable for demonstration

  /// Function to increment the counter
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Function to decrement the counter
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  /// Function to show a custom alert dialog
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Function to navigate to a new screen
  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "New Screen",
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            "Counter: $_counter",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text("Increase"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _decrementCounter,
                child: const Text("Decrease"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAlertDialog("Hello", "This is a custom alert!"),
            child: const Text("Show Alert"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }
}
