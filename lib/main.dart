import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Snake Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int gridSize = 20;
  static const double cellSize = 20.0;
  List<Offset> snake = [Offset(10, 10)];
  Offset food = Offset(Random().nextInt(gridSize).toDouble(), Random().nextInt(gridSize).toDouble());
  Direction direction = Direction.right;
  Timer? gameLoop;
  int score = 0;  // Score variable

  void startGame() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      moveSnake();
      checkCollision();
      checkFood();
      setState(() {});
    });
  }

  void moveSnake() {
    Offset newHead = snake.last;
    switch (direction) {
      case Direction.left:
        newHead = Offset(newHead.dx - 1, newHead.dy);
        break;
      case Direction.right:
        newHead = Offset(newHead.dx + 1, newHead.dy);
        break;
      case Direction.up:
        newHead = Offset(newHead.dx, newHead.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(newHead.dx, newHead.dy + 1);
        break;
    }

    if (newHead.dx >= 0 &&
        newHead.dy >= 0 &&
        newHead.dx < gridSize &&
        newHead.dy < gridSize) {
      snake.add(newHead);
      snake.removeAt(0);
    } else {
      gameLoop?.cancel();
      showGameOverDialog();
    }
  }

  void checkCollision() {
    if (snake.sublist(0, snake.length - 1).contains(snake.last)) {
      gameLoop?.cancel();
      showGameOverDialog();
    }
  }

  void checkFood() {
    if (snake.last == food) {
      snake.insert(0, snake.first);
      food = Offset(Random().nextInt(gridSize).toDouble(), Random().nextInt(gridSize).toDouble());
      score++;  // Increase score when food is eaten
    }
  }

  void changeDirection(Direction newDirection) {
    if ((direction == Direction.left && newDirection != Direction.right) ||
        (direction == Direction.right && newDirection != Direction.left) ||
        (direction == Direction.up && newDirection != Direction.down) ||
        (direction == Direction.down && newDirection != Direction.up)) {
      direction = newDirection;
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('You scored $score points!'),  // Show score on game over
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      snake = [Offset(10, 10)];
      food = Offset(Random().nextInt(gridSize).toDouble(), Random().nextInt(gridSize).toDouble());
      direction = Direction.right;
      score = 0;  // Reset score
    });
    startGame();
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snake Game - Score: $score')),  // Display score in AppBar
      backgroundColor: Colors.purpleAccent[300],
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            changeDirection(Direction.up);
          } else if (details.delta.dy > 0) {
            changeDirection(Direction.down);
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0) {
            changeDirection(Direction.left);
          } else if (details.delta.dx > 0) {
            changeDirection(Direction.right);
          }
        },
        child: Center(
          child: CustomPaint(
            size: Size(gridSize * cellSize, gridSize * cellSize),
            painter: SnakePainter(snake, food),
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;

  SnakePainter(this.snake, this.food);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final foodPaint = Paint()..color = Colors.red;

    for (Offset point in snake) {
      canvas.drawRect(Rect.fromLTWH(point.dx * _MyHomePageState.cellSize, point.dy * _MyHomePageState.cellSize, _MyHomePageState.cellSize, _MyHomePageState.cellSize), paint);
    }

    canvas.drawRect(Rect.fromLTWH(food.dx * _MyHomePageState.cellSize, food.dy * _MyHomePageState.cellSize, _MyHomePageState.cellSize, _MyHomePageState.cellSize), foodPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum Direction { left, right, up, down }
