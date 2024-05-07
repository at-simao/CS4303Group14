class UI{
  private float heightUIOffset = 0; //offset needed from the top of the screen to draw UI element.
  private Timer timer; //timer for measuring length of wave
  private float lastTargetScore = 0; 
  private Timer newWaveMessageTimer;
  UI(float heightUIOffset){
    this.heightUIOffset = heightUIOffset;
    timer = new Timer(60000, new PVector(width*0.5,heightUIOffset*0.5), 35);
    newWaveMessageTimer = new Timer(1500, new PVector(width*0.5,heightUIOffset*0.5), 35);
  }
  
  void draw() {
    fill(0);
    stroke(255);
    rect(0, 0, width*0.999, heightUIOffset);
    float xStart = 0.01 * width;
    float yStart = heightUIOffset - 10;
    float spacingY = heightUIOffset / 3; // 
    if(CS4303SPACEHAUL.restartAnimationFlag){
      return;
    }
    noStroke();
    for (Mission mission : missionManager.getActiveMissions()) {
      String typeText = mission.getType() ? "CARGO" : "ESCORT";
      fill(215, 219, 220);
      textSize(heightUIOffset / 4 - 10);
      textAlign(LEFT);
      text(typeText, xStart, yStart);
      
      ArrayList<Integer> pickupPlanets = mission.getUiPlanets();
      ArrayList<Integer> destinationPlanets = mission.getUiDPlanets();
      float x = xStart + textWidth(typeText) + 20;

      for (Integer planet : pickupPlanets) {
        fill(planet);
        ellipse(x, yStart - textAscent() / 2, heightUIOffset * 0.2, heightUIOffset * 0.2); // 
        x += heightUIOffset * 0.2; // Space between planets
      }
      fill(215, 219, 220);
      String deliverText = "DELIVER TO";
      text(deliverText, x, yStart);
      x += textWidth(deliverText) + 20;
      for (Integer planet : destinationPlanets) {
        fill(planet);
        if(planet == color(193,183,183)) {
          rect(x - heightUIOffset * 0.1, yStart - textAscent() /2 -  (heightUIOffset * 0.1),heightUIOffset * 0.2,heightUIOffset * 0.2);
        } else {
         ellipse(x, yStart - textAscent() / 2, heightUIOffset * 0.2, heightUIOffset * 0.2); 
        }
        x += heightUIOffset * 0.2; // Space between planets
      }
      fill(215, 219, 220);
      text("POINTS: " + mission.getScore(), x, yStart);
      yStart -= spacingY; // Spacing between mission displays
    }
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
      text("PAUSED!", 0.25*width, height*0.2); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.25*width, height*0.25); //paused text display
      textSize(60);
      text("PAUSED!", 0.75*width, height*0.2); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.75*width, height*0.25); //paused text display
    }
    if(CS4303SPACEHAUL.newWave){
      if(newWaveMessageTimer.outOfTime()){
        newWaveMessageTimer = new Timer(1500, new PVector(width*0.5,heightUIOffset*0.5), 35);
        CS4303SPACEHAUL.newWave = false;
      } else {
        newWaveMessageTimer.updateTimer();
        stroke(0);
        textSize(60);
        text("NEW WAVE!", 0.25*width, height*0.45); //new wave text display
        text("NEW WAVE!", 0.75*width, height*0.45); //new wave text display
      }
    }
    if(CS4303SPACEHAUL.gameOver){
      stroke(0);
      textSize(60);
      text("GAME OVER!", 0.25*width, height*0.45); //paused text display
      textSize(50);
      text("Press [R] to restart in a new solar system.", 0.25*width, height*0.5); //game over text display
      textSize(60);
      text("GAME OVER!", 0.75*width, height*0.45); //paused text display
      textSize(50);
      text("Press [R] to restart in a new solar system.", 0.75*width, height*0.5);  //game over text display
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
    if(!CS4303SPACEHAUL.restartAnimationFlag){
      timer.updateTimer();
    }
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
