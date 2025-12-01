import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Definisi Bentuk Tetris (Tetromino)
enum Tetromino { L, J, I, O, S, Z, T }

class BookTetrisScreen extends StatefulWidget {
  const BookTetrisScreen({super.key});

  @override
  State<BookTetrisScreen> createState() => _BookTetrisScreenState();
}

class _BookTetrisScreenState extends State<BookTetrisScreen> {
  // --- KONFIGURASI GRID ---
  final int rowLength = 10;
  final int colLength = 15;

  // Grid Game: null = kosong, Tetromino = ada isinya
  late List<List<Tetromino?>> gameBoard;

  // --- STATE PERMAINAN ---
  Tetromino? currentPiece;
  int currentRotation = 0; 
  List<int> currentPosition = []; 
  
  int score = 0;
  bool isGameOver = false;
  bool isPlaying = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(rowLength, (j) => null),
    );
    score = 0;
    isGameOver = false;
    currentPiece = null;
  }

  void _startGame() {
    _initGame();
    setState(() {
      isPlaying = true;
      _spawnNewPiece();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _gameLoop();
    });
  }

  void _spawnNewPiece() {
    Random rand = Random();
    Tetromino type = Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = type;
    currentRotation = 0;

    switch (type) {
      case Tetromino.L: currentPosition = [-10, 0, 10, 11]; break;
      case Tetromino.J: currentPosition = [-9, 1, 11, 10]; break;
      case Tetromino.I: currentPosition = [-10, 0, 10, 20]; break;
      case Tetromino.O: currentPosition = [0, 1, 10, 11]; break;
      case Tetromino.S: currentPosition = [-9, 1, 0, 10]; break;
      case Tetromino.Z: currentPosition = [-11, -1, 0, 10]; break;
      case Tetromino.T: currentPosition = [-10, -1, 0, 1]; break;
    }

    for (int i = 0; i < currentPosition.length; i++) {
      currentPosition[i] += 4; 
    }

    if (_checkCollision(currentPosition)) {
      _gameOver();
    }
  }

  void _gameLoop() {
    List<int> nextPosition = [];
    for (int pixel in currentPosition) {
      nextPosition.add(pixel + rowLength);
    }

    if (_checkCollision(nextPosition)) {
      _landPiece();
    } else {
      setState(() {
        currentPosition = nextPosition;
      });
    }
  }

  bool _checkCollision(List<int> positions) {
    for (int pos in positions) {
      int row = (pos / rowLength).floor();
      int col = pos % rowLength;

      if (row >= colLength) return true;

      if (row >= 0 && col >= 0) {
        if (gameBoard[row][col] != null) return true;
      }
    }
    return false;
  }

  void _landPiece() {
    for (int i = 0; i < currentPosition.length; i++) {
      int row = (currentPosition[i] / rowLength).floor();
      int col = currentPosition[i] % rowLength;
      
      if (row >= 0 && col >= 0) {
        gameBoard[row][col] = currentPiece;
      }
    }

    _clearLines();
    _spawnNewPiece();
  }

  void _clearLines() {
    int linesCleared = 0;
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(rowLength, (index) => null);
        
        linesCleared++;
        row++; 
      }
    }

    if (linesCleared > 0) {
      setState(() {
        score += linesCleared * 100;
      });
    }
  }

  void _moveLeft() {
    if (!isPlaying || isGameOver) return;
    List<int> nextPosition = [];
    for (int pixel in currentPosition) {
      if (pixel % rowLength == 0) return; 
      nextPosition.add(pixel - 1);
    }
    if (!_checkCollision(nextPosition)) {
      setState(() { currentPosition = nextPosition; });
    }
  }

  void _moveRight() {
    if (!isPlaying || isGameOver) return;
    List<int> nextPosition = [];
    for (int pixel in currentPosition) {
      if ((pixel + 1) % rowLength == 0) return; 
      nextPosition.add(pixel + 1);
    }
    if (!_checkCollision(nextPosition)) {
      setState(() { currentPosition = nextPosition; });
    }
  }

  void _rotate() {
    if (!isPlaying || isGameOver) return;
    int pivot = currentPosition[1]; 
    int pivotRow = (pivot / rowLength).floor();
    int pivotCol = pivot % rowLength;

    List<int> nextPosition = [];
    for (int pos in currentPosition) {
      int row = (pos / rowLength).floor();
      int col = pos % rowLength;

      int relativeRow = row - pivotRow;
      int relativeCol = col - pivotCol;

      int newRow = pivotRow + relativeCol;
      int newCol = pivotCol - relativeRow;

      nextPosition.add(newRow * rowLength + newCol);
    }

    if (!_checkCollision(nextPosition)) {
      bool isWrap = false;
      for (int pos in nextPosition) {
        int col = pos % rowLength;
        if ((col - pivotCol).abs() > 4) isWrap = true; 
      }
      if (!isWrap) {
        setState(() { currentPosition = nextPosition; });
      }
    }
  }

  void _gameOver() {
    gameTimer?.cancel();
    setState(() {
      isGameOver = true;
      isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Skor Akhir: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startGame();
            },
            child: const Text("Main Lagi"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Keluar"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Tetris Buku", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Skor
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Score: $score", 
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ),

          // Grid Tetris
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: rowLength / colLength, // 10:15
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // Latar belakang grid hitam pekat
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rowLength * colLength,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength,
                    ),
                    itemBuilder: (context, index) {
                      int row = (index / rowLength).floor();
                      int col = index % rowLength;

                      bool isPiece = false;
                      
                      if (currentPosition.contains(index)) {
                        isPiece = true;
                      } 
                      else if (gameBoard[row][col] != null) {
                        isPiece = true;
                      }

                      if (isPiece) {
                        // --- BALOK BUKU HITAM PUTIH ---
                        return Container(
                          margin: const EdgeInsets.all(1), // Jarak antar balok
                          decoration: BoxDecoration(
                            color: Colors.white, // Warna balok PUTIH
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.black54), // Border balok
                          ),
                          child: const Center(
                            // Ikon diperbesar & warna HITAM
                            child: FittedBox( 
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.menu_book, color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // --- KOTAK KOSONG (GRID) ---
                        return Container(
                          margin: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            // Border tipis abu-abu agar grid terlihat
                            border: Border.all(color: Colors.grey[800]!, width: 0.5),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // Kontrol
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(Icons.arrow_back, _moveLeft),
                _controlButton(Icons.rotate_right, _rotate), // Tombol Putar
                _controlButton(Icons.arrow_forward, _moveRight),
              ],
            ),
          ),
          
          if (!isPlaying && !isGameOver)
             Padding(
               padding: const EdgeInsets.only(bottom: 20.0),
               child: ElevatedButton(
                 onPressed: _startGame, 
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                 ),
                 child: const Text("MULAI GAME", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
               ),
             )
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800], 
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white38)
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}