import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: Text('Graj'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RulesScreen()),
                );
              },
              child: Text('Zasady'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Offset> enemies = [];
  Offset player = Offset(0, 0);
  int playerLives = 3;
  int enemiesDestroyed = 0;
  bool gameOver = false;
  double enemySpeed = 1.0;
  final double speedIncrement = 0.5;

  @override
  void initState() {
    super.initState();
    startEnemySpawner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                if (!gameOver) {
                  removeEnemy(details.localPosition);
                }
              },
              child: Center(
                child: Stack(
                  children: [
                    for (var enemy in enemies)
                      Positioned(
                        left: enemy.dx - 15,
                        top: enemy.dy - 15,
                        child: GestureDetector(
                          onTapDown: (details) {
                            if (!gameOver) {
                              removeEnemy(details.localPosition);
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    Positioned(
                      left: player.dx - 25,
                      top: player.dy - 25,
                      child: GestureDetector(
                        onTapDown: (details) {
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Text(
              'Życia: $playerLives',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Text(
              'Punkty: $enemiesDestroyed',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void startEnemySpawner() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!gameOver) {
        generateEnemy();
      }
    });
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!gameOver) {
        moveEnemies();
      }
    });
  }

  void generateEnemy() {
    Random random = Random();
    double x = 0;
    double y = 0;
    if (random.nextBool()) {
      if (random.nextBool()) {
        x = 0;
        y = random.nextDouble() * MediaQuery.of(context).size.height;
      } else {
        x = MediaQuery.of(context).size.width;
        y = random.nextDouble() * MediaQuery.of(context).size.height;
      }
    } else {
      if (random.nextBool()) {
        x = random.nextDouble() * MediaQuery.of(context).size.width;
        y = 0;
      } else {
        x = random.nextDouble() * MediaQuery.of(context).size.width;
        y = MediaQuery.of(context).size.height;
      }
    }
    setState(() {
      enemies.add(Offset(x, y));
    });
  }

  void moveEnemies() {
    setState(() {
      for (int i = 0; i < enemies.length; i++) {
        double distanceX = player.dx - enemies[i].dx;
        double distanceY = player.dy - enemies[i].dy;
        double distance = sqrt(distanceX * distanceX + distanceY * distanceY);
        double directionX = distanceX / distance;
        double directionY = distanceY / distance;
        enemies[i] = Offset(enemies[i].dx + directionX * (enemySpeed + enemiesDestroyed/10), enemies[i].dy + directionY * (enemySpeed + enemiesDestroyed/10));
      }
      List<Offset> enemiesToRemove = [];
      for (var enemy in enemies) {
        double distanceX = player.dx - enemy.dx;
        double distanceY = player.dy - enemy.dy;
        double distance = sqrt(distanceX * distanceX + distanceY * distanceY);
        if (distance < 30) {
          playerLives--;
          if (playerLives <= 0) {
            showGameOverScreen();
            gameOver = true;
          }
          enemiesToRemove.add(enemy);
          enemiesDestroyed++;
        }
      }
      for (var enemy in enemiesToRemove) {
        enemies.remove(enemy);
      }
    });
  }

  void removeEnemy(Offset target) {
    setState(() {
      List<Offset> enemiesToRemove = [];
      for (var enemy in enemies) {
        double distanceX = target.dx - enemy.dx;
        double distanceY = target.dy - enemy.dy;
        double distance = sqrt(distanceX * distanceX + distanceY * distanceY);
        if (distance < 15) {
          enemiesToRemove.add(enemy);
          enemiesDestroyed++;
        }
      }
      for (var enemy in enemiesToRemove) {
        enemies.remove(enemy);
      }
    });
  }

  void showGameOverScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Punkty: $enemiesDestroyed "),
          actions: [
            TextButton(
              child: Text("Zagraj ponownie"),
              onPressed: () {
                setState(() {
                  playerLives = 3;
                  enemiesDestroyed = 0;
                  enemies.clear();
                  gameOver = false;
                  enemySpeed = 1.0;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Powrót do menu"),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    player = Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class RulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zasady'),
      ),
      body: Center(
        child: Text('Gracz (Niebieski kwadrat) przytrzymuje ekran na przeciwnikach (Czerwone kwadraty) aby zdobywać punkty. Kiedy przeciwnicy wejdą w kontakt z graczem, traci on 1 życie. Strać wszystkie życia i game over. Ilość punktów zwiększa prędkość przeciwników. \n Powodzenia! \n\n Twórca: Adrian Pluto',textAlign: TextAlign.center,),
      ),
    );
  }
}
