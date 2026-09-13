class GameState {
  int score = 0;
  int level = 1;
  bool isGameOver = false;
  bool isPaused = false;
  int lives = 3;

  void reset() {
    score = 0;
    level = 1;
    isGameOver = false;
    isPaused = false;
    lives = 3;
  }

  void updateScore(int points) {
    score += points;
  }

  void nextLevel() {
    level++;
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      isGameOver = true;
    }
  }
}
