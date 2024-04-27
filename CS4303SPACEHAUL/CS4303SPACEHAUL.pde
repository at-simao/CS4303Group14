//DEBUG VARIABLES
boolean player1ZoomOut = false;
boolean player2ZoomOut = false;
final float ZOOM_OUT_VALUE = 0.3;
//

Player player1;
Player player2;

ArrayList<FriendlyAI> escortAI = new ArrayList<FriendlyAI>(); //arraylist storing all currently active escort-mission friendly ai.

Camera camera1;
Camera camera2;
final float MAX_ZOOM_OUT = 3;

static Map map;

PImage player1Screen = null;
PImage player2Screen = null;

Hazards hazards = new Hazards(); //Hazards class keeps track of all meteors currently rendered and existing. Spawn as player gets near (procedurally), despawn as player moves away.


static public PGraphics offScreenBuffer; //to refer to the buffer outside of this class, use CS4303SPACEHAUL.offScreenBuffer, use this when performing any draw methods (e.g. CS4303SPACEHAUL.offScreenBuffer.line(...))
//This is used to render to an offscreen image, which we later draw when displaying the split-screen.

void setup() {
  offScreenBuffer = createGraphics(width, height);
  frameRate(120);
  fullScreen();
  noSmooth();
  
  // set up two cameras, one for each player.
  camera1 = new Camera(0, 0, 3.0f);
  camera2 = new Camera(0, 0, 3.0f);
  player1 = new Player(new PVector(0,0), 1);
  player2 = new Player(new PVector(0,0), 2);
  //TO BE REMOVED
  escortAI.add(new FriendlyAI(new PVector(0,800))); //NOTE: Placed here for feature testing. In actual game should not spawn immediently, only near escort mission planet. Then when player gets near, the ai follows player.
  escortAI.get(0).setTarget(player1);
  //TO BE REMOVED
  map = new Map();
  int numPlanets = (int) random(3, 7);
  map.generate(numPlanets);
}
 
void keyPressed() {
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
  PVector arrowDirection = PVector.sub(map.star.getPosition(), playerPosition);
  drawArrow(playerPosition, arrowDirection, map.star.colour);
  for (Planet planet : map.planets) {
    arrowDirection = PVector.sub(planet.getPosition(), playerPosition);
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
  // player1.gravitationalPull(calculateGravityByBody(player1.position, player2.position)); 
  applyGravityToPlayer(player1);
  // player2.gravitationalPull(calculateGravityByBody(player2.position, player1.position));
  applyGravityToPlayer(player2);
  player1.integrate();
  player2.integrate();
  for(FriendlyAI friend : escortAI){
    friend.integrate();
  }
  map.integrate();
  hazards.generate(player1, player2, 1);
  hazards.generate(player1, player2, 2);
  hazards.deleteHazard(player1, player2);
  hazards.integrate(player1, player2, escortAI);
}

void applyGravityToPlayer(Player player){
  // in here would be gravity calculations that would be the same for both players e.g. gravity by planets.
}



void draw() {
  physicsAndLogicUpdate(); //Update physics & positions once. Then display twice, once from player 1's perspective, second from player 2's.
  if(player1ZoomOut){
    camera1.setZoom(ZOOM_OUT_VALUE); //debug feature: zoom out to better see solar system. Press Z to activate, and X to deactivate.
  } else {
    camera1.setZoom(3 / min((1+0.03*player1.getVelocity().mag()), MAX_ZOOM_OUT)); //zoom out effect to give feeling to player of FTL travel.
  }
  player1Screen = playerScreenDraw(player1, camera1); //write player 1's screen to buffer, outputs to an image.
  if(player2ZoomOut){
    camera2.setZoom(ZOOM_OUT_VALUE); //debug feature: zoom out to better see solar system. Press C to activate, and V to deactivate.
  } else {
    camera2.setZoom(3 / min((1+0.03*player2.getVelocity().mag()), MAX_ZOOM_OUT)); //zoom out effect to give feeling to player of FTL travel.
  }
  player2Screen = playerScreenDraw(player2, camera2); //write player 1's screen to buffer, outputs to an image.
  //This draws to the screen.
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
  rect(width*0.495, 0, width*0.01, height);
  //end of draw to screen.
}

//Draws every element in the world, from the current player's perspective. No physics calculations done here.
PImage playerScreenDraw(Player player, Camera cameraForPlayer) {
  //fill(255);
  offScreenBuffer.beginDraw();
  offScreenBuffer.background(#CECECE);
  offScreenBuffer.noSmooth();
  offScreenBuffer.textSize(8);

  offScreenBuffer.imageMode(CENTER);
  offScreenBuffer.textMode(CENTER);

  cameraForPlayer.begin(player.getPosition());

  drawGrid();
  map.draw();
  
  player1.draw();
  player2.draw();
  for(FriendlyAI friend : escortAI){
    friend.draw();
  }
  
  hazards.draw();
  
  player.drawImpulseIndicator();
  drawArrows(player.getPosition());
  player.drawHealthBar();
  
  cameraForPlayer.end();
  offScreenBuffer.endDraw();
  return offScreenBuffer.get(); //returns this player's half of the screen as an image.
}
