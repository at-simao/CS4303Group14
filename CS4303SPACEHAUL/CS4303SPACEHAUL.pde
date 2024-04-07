Player player1;
Player player2;

Camera camera1;
Camera camera2;

PImage player1Screen = null;
PImage player2Screen = null;


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
    
}
 
void keyPressed() {
  // wizard controls
  if(key == 'w') player1.movingForward = true;
  if(key == 's') player1.reversing = true;
  if(key == 'a') player1.turningRight = true;
  if(key == 'd') player1.turningLeft = true;
  if(keyCode == UP) player2.movingForward = true;
  if(keyCode == DOWN) player2.reversing = true;
  if(keyCode == LEFT) player2.turningRight = true;
  if(keyCode == RIGHT) player2.turningLeft = true;
}

void keyReleased() {
  // wizard controls
  if(key == 'w') player1.movingForward = false;
  if(key == 's') player1.reversing = false;
  if(key == 'a') player1.turningRight = false;
  if(key == 'd') player1.turningLeft = false;
  if(keyCode == UP) player2.movingForward = false;
  if(keyCode == DOWN) player2.reversing = false;
  if(keyCode == LEFT) player2.turningRight = false;
  if(keyCode == RIGHT) player2.turningLeft = false;
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

//Method for updating physics of game-world. Currently updates gravity of players.
void physicsAndLogicUpdate() {  
  player1.gravitationalPull(calculateGravityByBody(player1.position, player2.position)); 
  applyGravityToPlayer(player1);
  player2.gravitationalPull(calculateGravityByBody(player2.position, player1.position));
  applyGravityToPlayer(player2);
  player1.integrate();
  player2.integrate();
}

void applyGravityToPlayer(Player player){
  // in here would be gravity calculations that would be the same for both players e.g. gravity by planets.
}

//Method for determining strength of gravitational pull from one body to another.
PVector calculateGravityByBody(PVector body1Pos, PVector body2Pos){
  PVector gravity = new PVector(body2Pos.x - body1Pos.x, body2Pos.y - body1Pos.y);
  float distance = gravity.mag();
  if(distance == 0) {
    gravity.mult(0); //prevent divide by 0 error
  } else{
    gravity.mult(1/distance);
  }
  return gravity.copy();
}

void draw() {
  physicsAndLogicUpdate(); //Update physics & positions once. Then display twice, once from player 1's perspective, second from player 2's.
  player1Screen = playerScreenDraw(player1.position, camera1); //write player 1's screen to buffer, outputs to an image.
  player2Screen = playerScreenDraw(player2.position, camera2); //write player 1's screen to buffer, outputs to an image.
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
PImage playerScreenDraw(PVector playerPosition, Camera cameraForPlayer) {
  //fill(255);
  offScreenBuffer.beginDraw();
  offScreenBuffer.background(#CECECE);
  offScreenBuffer.noSmooth();
  offScreenBuffer.textSize(8);

  offScreenBuffer.imageMode(CENTER);
  offScreenBuffer.textMode(CENTER);

  cameraForPlayer.begin(playerPosition);

  drawGrid();
  
  player1.draw();
  player2.draw();
  
  cameraForPlayer.end();
  offScreenBuffer.endDraw();
  return offScreenBuffer.get(); //returns this player's half of the screen as an image.
}
