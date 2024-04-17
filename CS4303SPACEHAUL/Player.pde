class Player extends Body {
  // private final float MAX_VELOCITY = 2f;
  
  private float orientation = 0.0;
  
  private final float THRUST_INCREMENT = 0.08;
  private final float ORIENTATION_INCREMENT = 0.1;
  private final float SLOW_DOWN = 0.97; //drag applied when player attempts to slow down: this is done when the press thurstLeft and thrustRight at the same time.
  
  private final float radius = 7;
  

  public boolean thrustUp = false; 
  public boolean thrustRight = false;
  public boolean thrustLeft = false;
  public boolean thrustDown = false; //these correspond to W, A, S, D / UP LEFT RIGHT DOWN keys.
  
  private color colour;
  
  public Player(PVector start, int whichPlayer) {
    super(start, new PVector(0,0), 0.01);
    if(whichPlayer == 1){
      colour = color(255,0,0);
    } else {
      colour = color(0,0,255);
    }
  }
  
  public void integrate() {
    
    updateOrientation(); //defunct currently
    //update thrust (pressing W,A,S,D / UP,LEFT,DOWN,RIGHT)
    updateThrust();
    
    if(velocity.mag() != 0){ //if 0, no need to update orientation, keep facing same direction from before standing-still.
      float targetOrientation = atan2(velocity.x, velocity.y); //we want character to face movement
      
      if (orientation > PI) orientation -= 2*PI ;
      else if (orientation < -PI) orientation += 2*PI ;
      
      //move a bit towards velocity:
      // turn vel into orientation
      
      // Will take a frame extra at the PI boundary
      float orIncrement = PI/16;
      if (abs(targetOrientation - orientation) <= orIncrement) {
        orientation = targetOrientation ;
      } else {
         // if it's less than me, then how much if up to PI less, decrease otherwise increase
      if (targetOrientation < orientation) {
        if (orientation - targetOrientation <= PI) orientation -= orIncrement  ;
          else orientation += orIncrement ;
        }
        else {
         if (targetOrientation - orientation <= PI) orientation += orIncrement ;
         else orientation -= orIncrement ; 
        }
      }
      //END OF COPIED CODE
    }
    
    
    //// update position
    this.position.y += velocity.y;
    this.position.x += velocity.x;

    // // NOT FINAL: Capping velocity for testing
    // if (abs(velocity.x) > MAX_VELOCITY) {
    //   velocity.x = (velocity.x / abs(velocity.x)) * MAX_VELOCITY;
    // }
    // if (abs(velocity.y) > MAX_VELOCITY) {
    //   velocity.y = (velocity.y / abs(velocity.y)) * MAX_VELOCITY;
    // }

    println(position);
  }
  
  private void updateOrientation(){
    //defunct currently, may be used later if we reverse change in player movement.
  }
  
  private void updateThrust(){
    if(thrustLeft && thrustRight){
      velocity.mult(SLOW_DOWN);
      return;
    } else if (thrustRight){
      velocity.y += sin(PI)*THRUST_INCREMENT; //vertical component of unit circle
      velocity.x += cos(PI)*THRUST_INCREMENT; //horizontal component
    } else if (thrustLeft){
      velocity.y += sin(0)*THRUST_INCREMENT; //vertical component of unit circle
      velocity.x += cos(0)*THRUST_INCREMENT; //horizontal component
    }
    if(thrustUp){
      velocity.y -= sin(HALF_PI)*THRUST_INCREMENT; //vertical component of unit circle
      velocity.x -= cos(HALF_PI)*THRUST_INCREMENT; //horizontal component
      //effect is vector added to velocity with magnitude THRUST_INCREMENT, pointing in direction of orientation.
    } else if (thrustDown){
      velocity.y += sin(HALF_PI)*THRUST_INCREMENT;
      velocity.x += cos(HALF_PI)*THRUST_INCREMENT;
    }
    
    //we do not reset velocity due to the lack of drag force in space. Only slow down if player presses thurstLeft and thrustRight at the same time.
  }
  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    drawImpulseIndicator();
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation+HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);    
    CS4303SPACEHAUL.offScreenBuffer.rotate((orientation-HALF_PI));
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
  
  private void drawImpulseIndicator(){ //draws circle in direction of impulse/where player is accelerating.
    int upOrDown = 0;
    int leftOrRight = 0;
    if(thrustLeft && thrustRight){
      return; //no need to draw, SLOW_DOWN is in effect.
    }if(thrustRight){
      leftOrRight = -1;
    } else if(thrustLeft) {
      leftOrRight = 1;
    }
    if(thrustUp){
      upOrDown = -1;
    } else if(thrustDown) {
      upOrDown = 1;
    }
    PVector placementOfExhaust = new PVector(leftOrRight, upOrDown);
    placementOfExhaust.normalize(); //normalise so impulse indicator is always barely touching front of player.
    CS4303SPACEHAUL.offScreenBuffer.circle(placementOfExhaust.x*radius*2.25, placementOfExhaust.y*radius*2.25, 4); 

  }
}
