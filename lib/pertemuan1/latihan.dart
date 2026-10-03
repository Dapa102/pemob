import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pertemuan 1',
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({
    super.key,
    this.appBarTitle = 'Counter Saya',
  });

  final String appBarTitle;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Counter Saya'),
        backgroundColor: const Color.fromARGB(255, 247, 175, 67),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Flutter
            const Icon(Icons.flutter_dash,size: 80,color: Colors.blue,),

            const SizedBox(height: 16),

            // Nama
            const Text('Halo, nama saya Dafa',style: TextStyle(fontSize: 24,)),

            // NIM
            const Text('NIM: 20240801157',style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),

            // Counter
            Text('$_count',style: const TextStyle(fontSize: 48,),
            ),
          ],
        ),
      ),

      // Tombol - dan +
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol -
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count--;
                });
              },
              backgroundColor: const Color.fromARGB(255,247,175,67,),
              child: const Icon(Icons.remove),
            ),

            const SizedBox(width: 10),

            // Tombol Reset
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count = 0;
                });
              },
              backgroundColor: const Color.fromARGB(255,247,175,67,),
              child: const Icon(Icons.refresh),
            ),

            const SizedBox(width: 10),

            // Tombol +
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count++;
                });
              },
              backgroundColor: const Color.fromARGB(255,247,175,67,),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}