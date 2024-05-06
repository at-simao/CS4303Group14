//DEBUG VARIABLES
boolean player1ZoomOut = false;
boolean player2ZoomOut = false;
final float ZOOM_OUT_VALUE = 0.1;
// WAVE & SCORE & GAME OVER
static int wave = 1;
static int score = 0;
static final int FIRST_SCORE_NEEDED = 1000;
static int scoreNeeded = FIRST_SCORE_NEEDED;
static boolean gameOver = false;
static boolean restartAnimationFlag = true;
static boolean restartAnimationHalfWayFlag = false;
private final int RESTART_LENGTH = 1500;
private Timer restartAnimationTimer = new Timer(RESTART_LENGTH, new PVector(0,0), 35);
private boolean justStarted = true;
private boolean justStartedTransition = true;
private int currentSlide = 0;
private final int MAX_SLIDES = 3;
// UI
static boolean isPaused = false;
static boolean pausePressedDrawOnce = false;
static boolean newWave = false;
float heightUIOffset;
UI ui;


ForceRegistry forceRegistry;

Player player1;
Player player2;

ArrayList<FriendlyAI> aiList = new ArrayList<FriendlyAI>(); //arraylist storing all currently active escort-mission friendly ai.
ArrayList<EnemyAI> enemyAIList = new ArrayList<EnemyAI>(); //arraylist storing all currently active patroling enemy ai.
MissionManager missionManager;
Camera camera1;
Camera camera2;
final float MAX_ZOOM_OUT = 3;

static Map map;

PImage player1Screen = null;
PImage player2Screen = null;

Hazards hazards = new Hazards(); //Hazards class keeps track of all meteors currently rendered and existing. Spawn as player gets near (procedurally), despawn as player moves away.
BackgroundStars stars = new BackgroundStars();
 
static public PGraphics offScreenBuffer; //to refer to the buffer outside of this class, use CS4303SPACEHAUL.offScreenBuffer, use this when performing any draw methods (e.g. CS4303SPACEHAUL.offScreenBuffer.line(...))
//This is used to render to an offscreen image, which we later draw when displaying the split-screen.

void setup() {
  offScreenBuffer = createGraphics(width, height);
  frameRate(120);
  fullScreen();
  noSmooth();
  heightUIOffset = height*0.15;
  ui = new UI(heightUIOffset);
  ui.setNewWaveTimer(2, 0); //DEMO TIMER, this is meant to be changed when we actually implement a wave system.
  
  // set up two cameras, one for each player.
  camera1 = new Camera(0, 0, 3.0f, heightUIOffset, 1);
  camera2 = new Camera(0, 0, 3.0f, heightUIOffset, 2);
  player1 = new Player(new PVector(650,0), 1);
  player2 = new Player(new PVector(0,650), 2);
  //TO BE REMOVED
  map = new Map();
  missionManager = new MissionManager();
  int numPlanets = (int) random(3, 7);
  map.generate(numPlanets);

  forceRegistry = new ForceRegistry();
  for (Planet planet : map.planets) {
    Gravity planetGravity = new Gravity(planet);
    forceRegistry.add(player1, planetGravity);
    forceRegistry.add(player2, planetGravity);
  }
  
  // temp first mission
  ArrayList<Planet> randomPlanets = new ArrayList<Planet>();
  ArrayList<Planet> randomPlanets2 = new ArrayList<Planet>();
  randomPlanets.add(map.planets.get(1));
  randomPlanets2.add(map.planets.get(0));
  missionManager.addMission(new CargoMission(randomPlanets, randomPlanets2));
  
}

void keyPressed() {
  if(gameOver){
    if(key == 'r' || key == 'R'){
      gameOver = false;
      restartAnimationFlag = true;
    }
    return; //no inputs allowed except restart
  }
  if(key == ' ' && !restartAnimationFlag){
    isPaused = !isPaused;
    if(isPaused && !pausePressedDrawOnce){
      pausePressedDrawOnce = true; //we want to draw 1 frame for our massive zoom-out pause screen.
      player1ZoomOut = true;
      player2ZoomOut = true;
    }
    if(!isPaused){
      player1ZoomOut = false;
      player2ZoomOut = false;
    }
    return;
  } 
  if(key == 'w' || key == 'W') player1.thrustUp = true;
  if(key == 's' || key == 'S') player1.thrustDown = true;
  if(key == 'a' || key == 'A') player1.thrustRight = true;
  if(key == 'd' || key == 'D') player1.thrustLeft = true;
  if(keyCode == UP) player2.thrustUp = true;
  if(keyCode == DOWN) player2.thrustDown = true;
  if(keyCode == LEFT) player2.thrustRight = true;
  if(keyCode == RIGHT) player2.thrustLeft = true;
  if(key == 'Z' || key == 'z') player1ZoomOut = true;
  if(key == 'X' || key == 'x') player1ZoomOut = false;
  if(key == 'C' || key == 'c') player2ZoomOut = true;
  if(key == 'V' || key == 'v') player2ZoomOut = false;
  if(key == 'E' || key == 'e') missionManager.attemptAction(player1);
  if(key == '1') missionManager.attemptAction(player2);
  if(keyCode == ENTER || keyCode == RETURN) currentSlide = min(++currentSlide, 3);
  //if(key == 'K' || key == 'k') aiList.get(floor(random(0, aiList.size()))).kill();
}

void keyReleased() {
  if(key == 'w' || key == 'W') player1.thrustUp = false;
  if(key == 's' || key == 'S') player1.thrustDown = false;
  if(key == 'a' || key == 'A') player1.thrustRight = false;
  if(key == 'd' || key == 'D') player1.thrustLeft = false;
  if(keyCode == UP) player2.thrustUp = false;
  if(keyCode == DOWN) player2.thrustDown = false;
  if(keyCode == LEFT) player2.thrustRight = false;
  if(keyCode == RIGHT) player2.thrustLeft = false;
}

void drawGrid() { //temporary, can be removed once we have an actual map.
  int STRIDE = 32;
  for (int c = 0; c < width/STRIDE; c++) {
    for (int r = 0; r < height/STRIDE; r++) {
      offScreenBuffer.fill(255);
      offScreenBuffer.text("(" + c + ", " + r + ")", c * STRIDE, r * STRIDE);
    }
  }
}

void drawArrows(PVector playerPosition) {
  // PVector arrowDirection = PVector.sub(map.star.getPosition(), playerPosition);
  // drawArrow(playerPosition, arrowDirection, map.star.colour);
  for (Planet planet : map.planets) {
    PVector arrowDirection = PVector.sub(planet.getPosition(), playerPosition);
    drawArrow(playerPosition, arrowDirection, planet.colour);
  }
}

void drawArrow(PVector playerPosition, PVector direction, color colour) {
  float arrowLength = 10; // Length of the arrow from its start point
  float arrowHeadSize = 5; // Size of the arrow head sides
  float offsetRadius = 30; // Distance from player position to start the arrow

  // Normalize the direction vector, multiply by the offset to find the base of the arrow
  PVector normalizedDirection = direction.copy().normalize();
  PVector basePosition = PVector.add(playerPosition, normalizedDirection.copy().mult(offsetRadius));
  PVector endPosition = PVector.add(basePosition, normalizedDirection.copy().mult(arrowLength));

  offScreenBuffer.pushMatrix();
  offScreenBuffer.translate(basePosition.x, basePosition.y);
  float angle = atan2(direction.y, direction.x);
  offScreenBuffer.rotate(angle);

  // Draw the arrow shaft (optional, if you want a line leading to the head)
  offScreenBuffer.stroke(colour); // Red for visibility
  offScreenBuffer.strokeWeight(2);

  // Draw the arrowhead
  offScreenBuffer.line(arrowLength, 0, arrowHeadSize, -arrowHeadSize);
  offScreenBuffer.line(arrowLength, 0, arrowHeadSize, arrowHeadSize);
  offScreenBuffer.popMatrix();
}

//Method for updating physics of game-world. Currently updates gravity of players.
void physicsAndLogicUpdate() {  
  map.integrate();
  forceRegistry.updateForces();

  player1.updateVelocity();
  player2.updateVelocity();
  for (Planet planet : map.planets) {
    if (CollisionUtil.checkCollision(player1, planet)) {
      CollisionUtil.handleCollision(player1, planet);
      player1.updateVelocity();
    }
    if (CollisionUtil.checkCollision(player2, planet)) {
      CollisionUtil.handleCollision(player2, planet);
      player2.updateVelocity();
    }
  }
  player1.integrate();
  player2.integrate();

  for(FriendlyAI friend : aiList){
    friend.integrate();
  }
  for(EnemyAI enemy : enemyAIList){
    enemy.checkPlayer1IsInRange(player1);
    //enemy.checkPlayer2IsInRange(player2);
    enemy.integrate();
  }

  ArrayList<Meteor> newMeteors = new ArrayList<>();
  Meteor meteor1 = hazards.generate(player1, player2, 1);
  Meteor meteor2 = hazards.generate(player1, player2, 2);
  if (meteor1 != null) newMeteors.add(meteor1);
  if (meteor2 != null) newMeteors.add(meteor2);
  for (Meteor newMeteor : newMeteors) { // Updates the force registry only if new hazards are generated.
    println("Meteor generated");
    ArrayList<Meteor> meteors = hazards.getMeteors();
    for (Meteor meteor : meteors) {
      if (!meteor.equals(newMeteor)) {
        forceRegistry.add(newMeteor, new Gravity(meteor));
        forceRegistry.add(meteor, new Gravity(newMeteor));
      }
    }
  }

  ArrayList<Meteor> deletedHazards = hazards.deleteHazard(player1, player2);
  if (deletedHazards.size() != 0) println("Deleting Hazards...");
  for (Meteor meteor : deletedHazards) {
    println("Removing meteor from force registry");
    forceRegistry.remove(meteor);
  }
  hazards.integrate(player1, player2, aiList);

  stars.generate(player1, player2, 1);
  stars.generate(player1, player2, 2);
  stars.deleteStar(player1, player2);
  friendlyAILogicUpdate();
}

void applyGravityToPlayer(Player player){
  // in here would be gravity calculations that would be the same for both players e.g. gravity by planets.
}

void drawUpdate(){
    if(player1ZoomOut){
      camera1.setZoom(!isPaused ? ZOOM_OUT_VALUE : ZOOM_OUT_VALUE*0.8); //debug feature: zoom out to better see solar system. Press Z to activate, and X to deactivate.
    } else {
      camera1.setZoom(3 / min((1+0.03*player1.getVelocity().mag()), MAX_ZOOM_OUT)); //zoom out effect to give feeling to player of FTL travel.
    }
    player1Screen = playerScreenDraw(player1, camera1); //write player 1's screen to buffer, outputs to an image.
    if(player2ZoomOut){
      camera2.setZoom(!isPaused ? ZOOM_OUT_VALUE : ZOOM_OUT_VALUE*0.8); //debug feature: zoom out to better see solar system. Press C to activate, and V to deactivate.
    } else {
      camera2.setZoom(3 / min((1+0.03*player2.getVelocity().mag()), MAX_ZOOM_OUT)); //zoom out effect to give feeling to player of FTL travel.
    }
    player2Screen = playerScreenDraw(player2, camera2); //write player 1's screen to buffer, outputs to an image.
    //This draws to the screen.
    translate(0, heightUIOffset);
    imageMode(CORNER);
    player1Screen.loadPixels();
    for (int i = 0; i < width*height; i++) {
      if(i % width == 0){
        i += width/2; //right-half of screen
      }
      player1Screen.pixels[i] = player2Screen.pixels[i - width/2]; //left-half is player 1's screen, right-half is player 2's.
    }
    player1Screen.updatePixels();
    image(player1Screen, 0, 0);
    imageMode(CENTER);
    noStroke();
    translate(0, -heightUIOffset);
    fill(255);
    stroke(0);
    rect(width*0.495, 0, width*0.01, height);  
}



void draw() {
  if(justStarted){
    if(currentSlide == MAX_SLIDES){
      justStarted = false;
      return;
    }
    PImage splashScreen = loadImage("./data/CONTROLS"+currentSlide+".PNG");
    splashScreen.resize(width,height);
    image(splashScreen, 0, 0);
    return;
  }
  if(ui.getTimer().outOfTime()){
    if(score >= scoreNeeded){
      //SUCCESS. New wave.
      wave++;
      newWaveTarget();
      ui.setNewWaveTimer(2,0); //reset timer.
      newWave = true;
      hazards.updateChanceOfMeteors();
      enemyAIList.add(new EnemyAI(new PVector(0,0)));
    } else {
      //GAME OVER.
      wave = 1;
      gameOver = true;
    }
  }
  if(restartAnimationFlag){
    if(restartAnimationHalfWayFlag){
      drawUpdate();
    }
    if(!justStartedTransition && restartAnimationHalfWayFlag) ui.draw();
    restartAnimation();
    fill(255);
    stroke(0);
    if(!justStartedTransition) rect(width*0.495, heightUIOffset, width*0.01, height);  
    return;
  }
  if((!isPaused && !gameOver) || pausePressedDrawOnce) {
    physicsAndLogicUpdate(); //Update physics & positions once. Then display twice, once from player 1's perspective, second from player 2's.
    drawUpdate();
    updateMission();
    pausePressedDrawOnce = false;
  }
  player1.updateRespawnTimer(); //update timer is logic but is an exception. because we must compare the timer every frame, we cannot wait to compare it only after the player unpauses.
  player2.updateRespawnTimer();
  for(EnemyAI ai : enemyAIList){
    ai.updateProjectilesAndTimers(player1, player2, hazards.getMeteors());
  }
  ui.draw();
  //end of draw to screen.
}

void updateMission() {
  missionManager.updateMissions();
  if(missionManager.checkForNewMission()) {
    boolean missionType = (random(0,1) > 0.5);
    ArrayList<Planet> randomPlanets = new ArrayList<Planet>();
    int numPlanets = (int) random(1, 5);
    ArrayList<Planet> destinationPlanets = new ArrayList<Planet>();
    
    if(!missionType) {
      for(int i = 0; i < numPlanets; i++) {
        randomPlanets.add(map.planets.get((int)random(0,map.planets.size())));
      }
      for(int i = 0; i < numPlanets; i++) {
        destinationPlanets.add(map.planets.get((int)random(0,map.planets.size())));
        while(destinationPlanets.get(i) == randomPlanets.get(i)) {
          destinationPlanets.set(i, map.planets.get((int) random(0, map.planets.size())));
        }
      }
      
    } 
    else {
      for(int i = 0; i < numPlanets; i++) {
        randomPlanets.add(map.planets.get((int)random(1,map.planets.size())));
      }
      destinationPlanets.add(map.planets.get(0));
    }
    
    
    if(missionType) {
      missionManager.addMission(new CargoMission(randomPlanets, destinationPlanets));
    }
    else {
      missionManager.addMission(new EscortMission(randomPlanets, destinationPlanets));
    }
  }
}

//Draws every element in the world, from the current player's perspective. No physics calculations done here.
PImage playerScreenDraw(Player player, Camera cameraForPlayer) {
  //fill(255);
  offScreenBuffer.beginDraw();
  offScreenBuffer.background(0);
  offScreenBuffer.noSmooth();
  offScreenBuffer.textSize(8);

  offScreenBuffer.imageMode(CENTER);
  offScreenBuffer.textMode(CENTER);

  cameraForPlayer.begin(player.getPosition());
  
  if((cameraForPlayer.getWhichPlayerFollowing() == 1 && !player1ZoomOut) || (cameraForPlayer.getWhichPlayerFollowing() == 2 && !player2ZoomOut)){
    stars.draw();
  }
  map.draw();
  
  player1.draw();
  player2.draw();
  if((cameraForPlayer.getWhichPlayerFollowing() == 1 && !player1ZoomOut) || (cameraForPlayer.getWhichPlayerFollowing() == 2 && !player2ZoomOut)){
    for(FriendlyAI friend : aiList){
      friend.draw();
    }
    for(EnemyAI enemy : enemyAIList){
      enemy.draw();
    }
    
    hazards.draw();
    
    player.drawImpulseIndicator();
    drawArrows(player.getPosition());
    player.drawHealthBar();
  }
  
  
  cameraForPlayer.end();
  offScreenBuffer.endDraw();
  return offScreenBuffer.get(); //returns this player's half of the screen as an image.
}

private void friendlyAILogicUpdate(){
  for(int i = 0; i < aiList.size(); i++){
    //if(aiList.get(i).getHealth() <= 0){
    //  aiList.remove(i);
    //  i--; //despawn dead AI.
    //  continue;
    //}
    if(!aiList.get(i).hasATarget()){
      boolean result = lineOfSight(aiList.get(i), player1);
      if(!result){ //if no line of sight to player 1, check for player 2
        lineOfSight(aiList.get(i), player2);
      }
    }
  }
}

static public boolean lineOfSight(FriendlyAI ai, Player player){
  PVector lineToPlayer = player.getPosition().copy().sub(ai.getPosition()).normalize();
  while(lineToPlayer.mag() < ai.getVisibilityRadius()){
    float oldMag = lineToPlayer.mag();
    lineToPlayer.normalize().mult(oldMag + ai.getRadius()*0.5); //incrementally raise ray of sight until we hit our target.
    for(Planet planet : map.planets){
      if(lineToPlayer.dist(planet.getPosition()) < planet.getDiameter()/2){
        return false; //planet in the way of line of sight.
      }
      if(lineToPlayer.dist(player.getPosition()) < player.getRadius()*2){
        ai.setTarget(player);
        return true; //found player
      }
    }
  }
  return false; //if here then line drawn was beyond visibility radius, failed.
}

static public float scoreMultiplier(float baseScore){ //multiplier increases by 1 every 2 waves.
  return floor((wave+1)/2) * baseScore;
}

private void newWaveTarget(){ //multiplier increases by 1000 every wave.
  ui.updateOldScoreTarget(scoreNeeded);
  scoreNeeded += 1000;
}

public void resetFromGameOver(){ //MIGHT NEED TO BE EDITED - some temp code included.
  gameOver = false;
  score = 0;
  scoreNeeded = FIRST_SCORE_NEEDED;
  ui.updateOldScoreTarget(0);
  wave = 1;
  ui.setNewWaveTimer(2, 0); 
  map = new Map();
  camera1 = new Camera(650, 0, 3.0f, heightUIOffset, 1);
  camera2 = new Camera(0, 650, 3.0f, heightUIOffset, 2);
  player1 = new Player(new PVector(650,0), 1);
  player2 = new Player(new PVector(0,650), 2);
  missionManager = new MissionManager();
  int numPlanets = (int) random(3, 7);
  map.generate(numPlanets);
  forceRegistry = new ForceRegistry();
  for (Planet planet : map.planets) {
    Gravity planetGravity = new Gravity(planet);
    forceRegistry.add(player1, planetGravity);
    forceRegistry.add(player2, planetGravity);
  }
  
  // temp first mission
  ArrayList<Planet> randomPlanets = new ArrayList<Planet>();
  ArrayList<Planet> randomPlanets2 = new ArrayList<Planet>();
  randomPlanets.add(map.planets.get(1));
  randomPlanets2.add(map.planets.get(0));
  missionManager.addMission(new CargoMission(randomPlanets, randomPlanets2));
  stars.clear();
  stars.generate(player1, player2, 1);
  hazards.clear();
  enemyAIList.clear();
  enemyAIList.add(new EnemyAI(new PVector(650,10)));
}

private void restartAnimation(){
  //(1-(abs(restartAnimationTimer.getMaxTime()/2 - restartAnimationTimer.getCurrTime()))/restartAnimationTimer.getMaxTime()/2))*restartAnimationTimer.getMaxTime()/2
  noStroke();
  fill(0);
  circle(width*0.25, height*0.5, lerp(height*1.7,0, abs((restartAnimationTimer.getMaxTime()/2) - restartAnimationTimer.getCurrTime()) / (restartAnimationTimer.getMaxTime()/2)  ));
  circle(width*0.75, height*0.5, lerp(height*1.7,0, abs((restartAnimationTimer.getMaxTime()/2) - restartAnimationTimer.getCurrTime()) / (restartAnimationTimer.getMaxTime()/2)  ));
  if(restartAnimationTimer.getCurrTime() <= restartAnimationTimer.getMaxTime()/2 && !restartAnimationHalfWayFlag){
    restartAnimationHalfWayFlag = true;
    justStartedTransition = false;
    resetFromGameOver();
  }
  if(restartAnimationTimer.outOfTime()){
    restartAnimationTimer = new Timer(RESTART_LENGTH, new PVector(0,0), 35);
    restartAnimationFlag = false;
    restartAnimationHalfWayFlag = false;
    return;
  }
  restartAnimationTimer.updateTimer();
}
