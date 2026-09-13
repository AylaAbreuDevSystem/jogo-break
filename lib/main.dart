import 'package:flutter/material.dart';

void main() {
  runApp(const JogoBreakApp());
}

class JogoBreakApp extends StatelessWidget {
  const JogoBreakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo Break',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const JogoBreakScreen(),
    );
  }
}

class JogoBreakScreen extends StatefulWidget {
  const JogoBreakScreen({Key? key}) : super(key: key);

  @override
  State<JogoBreakScreen> createState() => _JogoBreakScreenState();
}

class _JogoBreakScreenState extends State<JogoBreakScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo Break'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao Jogo Break!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Iniciar jogo
              },
              child: const Text('Iniciar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}
