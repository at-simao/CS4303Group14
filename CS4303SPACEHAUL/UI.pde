class UI{
  private float heightUIOffset = 0;
  private Timer timer;
  
  UI(float heightUIOffset){
    this.heightUIOffset = heightUIOffset;
    timer = new Timer(60000);
  }
  
  void draw() {
    stroke(180);
    fill(0);
    noStroke();
    rect(0, 0, width, heightUIOffset);
    fill(0,150,0);
    textSize(70);
    textAlign(LEFT);
    text("MISSIONS: []", 0.01*width, 0.70*heightUIOffset); //to be filled in when we have missions object ready.
    textAlign(CENTER);
    if(!timer.outOfTime()){
      PVector timeRemaining = timer.getMinAndSecFromTimer();
      text("TIME: " + floor(timeRemaining.x) + ":" + String.format("%02d", floor(timeRemaining.y)), 0.5*width, 0.7*heightUIOffset); //wave timer display
    }
    textAlign(RIGHT);
    textSize(40);
    String scoreNeededText = CS4303SPACEHAUL.scoreNeeded + "";
    String scoreText = CS4303SPACEHAUL.score + "";
    text("SCORE : ", 0.98*width - textWidth(scoreNeededText), 0.4*heightUIOffset); //current score display, aligned to the length of the scoreNeeded length for a clean visual.
    text(scoreText, 0.98*width, 0.4*heightUIOffset); //score value.
    text("TARGET: " + scoreNeededText, 0.98*width, 0.8*heightUIOffset); //target score to enter next wave display
    timer.updateTimer();
  }
  
  public Timer getTimer(){
    return timer;
  }
  
  public void setNewWaveTimer(int minutes, int seconds){
    timer.setTimer(minutes, seconds);
  }
}
