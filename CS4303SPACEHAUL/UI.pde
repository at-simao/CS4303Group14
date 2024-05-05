class UI{
  private float heightUIOffset = 0;
  private Timer timer;
  private Timer newWaveMessageTimer;
  private color  destinationPlanetColour;
  private ArrayList<Integer> pickupPlanetColours;
  private ArrayList<Integer> planetOutlines;
  private boolean missionType = true;  //true for cargo false for escort
  private float lastTargetScore = 0;

  UI(float heightUIOffset){
    this.heightUIOffset = heightUIOffset;
    timer = new Timer(60000, new PVector(width*0.5,heightUIOffset*0.5), 35);
    newWaveMessageTimer = new Timer(1500, new PVector(width*0.5,heightUIOffset*0.5), 35);
    pickupPlanetColours = new ArrayList<Integer>();
    planetOutlines = new ArrayList<Integer>();
  }

  //public void removeMissionDisplay(int id) {
  //  missionDisplays.removeIf(mission -> mission.id == id);
  //}
  //public void setMissionColours(ArrayList<Planet> pickupPlanets, color destinationColour, boolean type, int id) {
  //  removeMissionDisplay(id);  // Remove existing display with the same ID if it exists
  //  missionDisplays.add(new MissionDisplay(pickupPlanets, destinationColour, type, id));
  //}
  
  // Change colour for mission indicator to show delivered
  public color getFadedColor(color originalColor) {
    // Slightly fade colour 
    float r = red(originalColor) * 0.8;
    float g = green(originalColor) * 0.8;
    float b = blue(originalColor) * 0.8;
    return color(r, g, b);
  }

  // Update delivered missions
  public void updateCargo(color colour) {
    int index = pickupPlanetColours.indexOf(Integer.valueOf((int)colour)); // Find the index of the original colour to keep ordering same
    if (index != -1) {
        pickupPlanetColours.remove(index); // Remove the original colour at that index
        pickupPlanetColours.add(index, Integer.valueOf((int)getFadedColor(colour))); // Add the faded colour at the same index
    }
  }
  void draw() {
    fill(0);
    noStroke();
    rect(0, 0, width, heightUIOffset);
    float xStart = 0.01 * width;
    float yStart = heightUIOffset - 10;
    float spacingY = heightUIOffset / 3; // 
    if(CS4303SPACEHAUL.restartAnimationFlag){
      return;
    }
    for (Mission mission : missionManager.getActiveMissions()) {
      String typeText = mission.getType() ? "CARGO" : "ESCORT";
      fill(250);
      textSize(heightUIOffset / 4 - 10);
      textAlign(LEFT);
      text(typeText, xStart, yStart);

      ArrayList<Planet> pickupPlanets = mission.getPickupPlanets();
      float x = xStart + textWidth(typeText) + 20;

      for (Planet planet : pickupPlanets) {
        fill(planet.getColour());
        stroke(255);
        ellipse(x, yStart - textAscent() / 2, heightUIOffset * 0.2, heightUIOffset * 0.2); // 
        x += heightUIOffset * 0.2; // Space between planets
      }
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
      text("PAUSED!", 0.25*width, height*0.45); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.25*width, height*0.5); //paused text display
      textSize(60);
      text("PAUSED!", 0.75*width, height*0.45); //paused text display
      textSize(50);
      text("Press [SPACE] to continue!", 0.75*width, height*0.5); //paused text display
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
