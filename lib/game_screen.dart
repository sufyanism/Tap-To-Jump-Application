import 'dart:async';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  double playerY = 1;

  double velocity = 0;
  double gravity = -4.9;
  double jumpPower = 2.5;

  double obstacleX = 1.2;

  bool gameStarted = false;
  bool gameOver = false;

  Timer? gameLoopTimer;


  void startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      playerY = 1;
      obstacleX = 1.2;
      velocity = 0;
    });

    // Game loop updates every 30ms
    gameLoopTimer?.cancel();
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      applyPhysics();
      moveObstacle();

      if (checkCollision()) {
        timer.cancel();
        gameOver = true;
        showGameOverDialog();
      }

      setState(() {});
    });
  }


  void jump() {
    if (!gameStarted) {
      startGame();
    } else {
      velocity = jumpPower;
    }
  }


  void applyPhysics() {
    velocity += gravity * 0.03;
    playerY -= velocity;

    if (playerY > 1) {
      playerY = 1;
      velocity = 0;
    }
  }


  void moveObstacle() {
    obstacleX -= 0.02;

    if (obstacleX < -1.2) {
      obstacleX = 1.2;
    }
  }


  bool checkCollision() {
    // Check horizontal collision
    bool collideX = (obstacleX - 0.2).abs() < 0.1;

    // Check vertical collision (player near ground)
    bool collideY = playerY > 0.85;

    return collideX && collideY;
  }


  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over!"),
        content: const Text("You hit the obstacle!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame(); // restart
            },
            child: const Text("Restart"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏃 Tap-to-Jump Runner"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: jump,
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, playerY),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),

            Align(
              alignment: Alignment(obstacleX, 1),
              child: Container(
                width: 40,
                height: 40,
                color: Colors.red,
              ),
            ),

            if (!gameStarted && !gameOver)
              const Center(
                child: Text(
                  "TAP TO START",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
