import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_state.dart';
import '../widgets/game_painter.dart';
import '../services/audio_manager.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  late Timer gameTimer;
  bool esquerdaPressionada = false;
  bool direitaPressionada = false;
  final AudioManager audioManager = AudioManager();
  bool audioAtivado = true;
  late Size screenSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarJogo();
    });
  }

  void _inicializarJogo() {
    screenSize = MediaQuery.of(context).size;
    final gameHeight = screenSize.height - 100;
    
    gameState = GameState(
      screenWidth: screenSize.width,
      screenHeight: gameHeight,
    );
    setState(() {});

    // Timer para atualizar o jogo em tempo real (60 FPS)
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      
      // Movimento contínuo da raquete
      if (esquerdaPressionada) {
        gameState.moverRaqueteEsquerda();
      }
      if (direitaPressionada) {
        gameState.moverRaqueteDireita();
      }

      int blocoAntes = gameState.blocosDestruidos;
      gameState.atualizar();
      
      // Som quando bloco é destruído
      if (gameState.blocosDestruidos > blocoAntes) {
        audioManager.tocarSomBlocoDestruido();
      }

      setState(() {});

      // Verificar condições de fim de jogo
      if (gameState.estado == EstadoJogo.gameOver) {
        audioManager.tocarSomGameOver();
        _mostrarGameOver();
      }
    });
  }

  void _mostrarGameOver() {
    gameTimer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pontuação Final: ${gameState.pontos}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Nível: ${gameState.nivel}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Blocos Destruídos: ${gameState.blocosDestruidos}/${gameState.totalBlocos}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameState.reiniciar();
              _inicializarJogo();
              setState(() {});
            },
            child: const Text('Jogar Novamente'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer.cancel();
    audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    bool isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brick Breaker - Em Tempo Real'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(audioAtivado ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                audioAtivado = !audioAtivado;
                audioManager.setAudioAtivado(audioAtivado);
              });
            },
          ),
          if (gameState.estado == EstadoJogo.jogando)
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () {
                gameState.pausarJogo();
                setState(() {});
              },
            ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < -5) {
            gameState.moverRaqueteEsquerda();
          } else if (details.delta.dx > 5) {
            gameState.moverRaqueteDireita();
          }
          setState(() {});
        },
        child: Stack(
          children: [
            // Canvas do jogo responsivo
            CustomPaint(
              painter: GamePainter(gameState, screenSize),
              size: Size.infinite,
            ),
            // Overlay de pausa
            if (gameState.estado == EstadoJogo.pausa)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PAUSADO',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      ElevatedButton(
                        onPressed: () {
                          gameState.pausarJogo();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.1,
                            vertical: screenSize.height * 0.03,
                          ),
                        ),
                        child: Text(
                          'Continuar',
                          style: TextStyle(fontSize: screenSize.width * 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Menu inicial
            if (gameState.estado == EstadoJogo.menu)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Brick Breaker',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.15,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      ElevatedButton(
                        onPressed: () {
                          gameState.iniciarJogo();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.12,
                            vertical: screenSize.height * 0.03,
                          ),
                          backgroundColor: Colors.cyan,
                        ),
                        child: Text(
                          'Iniciar Jogo',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // Botões responsivos no rodapé
      bottomNavigationBar: gameState.estado == EstadoJogo.jogando
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        esquerdaPressionada = true;
                      },
                      onLongPress: () {
                        esquerdaPressionada = false;
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Esquerda'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.015,
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.05),
                    ElevatedButton.icon(
                      onPressed: () {
                        direitaPressionada = true;
                      },
                      onLongPress: () {
                        direitaPressionada = false;
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Direita'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05,
                          vertical: screenSize.height * 0.015,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
