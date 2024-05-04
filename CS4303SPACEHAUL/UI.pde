class UI{
  private float heightUIOffset = 0;
  private Timer timer;
  private float missionsDisplayed = 0;
  private float lastTargetScore = 0;
  
  UI(float heightUIOffset){
    this.heightUIOffset = heightUIOffset;
    timer = new Timer(60000, new PVector(width*0.5,heightUIOffset*0.5), 35);
  }
  
  void draw() {
    stroke(180);
    fill(0);
    noStroke();
    rect(0, 0, width, heightUIOffset);
    fill(250);
    textSize(70);
    textAlign(LEFT);
    text("MISSIONS: []", 0.01*width, 0.70*heightUIOffset); //to be filled in when we have missions object ready.
    textAlign(CENTER);
    if(!timer.outOfTime()){
      PVector timeRemaining = timer.getMinAndSecFromTimer();
      //text("TIME: ", 0.5*width - textWidth(floor(timeRemaining.x) + ":" + String.format("%02d", floor(timeRemaining.y))), 0.7*heightUIOffset); //wave timer display
      color downToTheWireCol = lerpColor(color(200,0,0), color(200,200,200), min(timer.getCurrTime()/timer.getMaxTime(), 1.0));
      fill(downToTheWireCol);
      textSize(100);
      text(floor(timeRemaining.x) + ":" + String.format("%02d", floor(timeRemaining.y)), 0.5*width, 0.7*heightUIOffset); //wave timer display
    }
    fill(250);
    if(CS4303SPACEHAUL.isPaused){
      stroke(0);
      textSize(60);
      text("PAUSED!", 0.25*width, height*0.45); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.25*width, height*0.5); //paused text display
      textSize(60);
      text("PAUSED!", 0.75*width, height*0.45); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.75*width, height*0.5); //paused text display
    }
    if(CS4303SPACEHAUL.newWave){
      stroke(0);
      textSize(60);
      text("NEW WAVE!", 0.25*width, height*0.45); //new wave text display
      text("NEW WAVE!", 0.75*width, height*0.45); //new wave text display
    }
    textAlign(RIGHT);
    textSize(40);
    String scoreNeededText = CS4303SPACEHAUL.scoreNeeded + "";
    String scoreText = CS4303SPACEHAUL.score + "";
    text("SCORE : ", 0.98*width - textWidth(scoreNeededText), 0.4*heightUIOffset); //current score display, aligned to the length of the scoreNeeded length for a clean visual.
    color currScoreCol = lerpColor(color(200,0,0), color(0,200,0), min((CS4303SPACEHAUL.score-lastTargetScore)/(CS4303SPACEHAUL.scoreNeeded-lastTargetScore), 1.0));
    fill(currScoreCol);
    text(scoreText, 0.98*width, 0.4*heightUIOffset); //score value.
    fill(250);
    text("TARGET: " + scoreNeededText, 0.98*width, 0.8*heightUIOffset); //target score to enter next wave display
    timer.updateTimer();
    //timer.draw();
  }
  
  public Timer getTimer(){
    return timer;
  }
  
  public void setNewWaveTimer(int minutes, int seconds){
    timer.setTimer(minutes, seconds);
  }
  
  public void updateOldScoreTarget(float oldTarget){
    lastTargetScore = oldTarget;
  }
  
  
}
