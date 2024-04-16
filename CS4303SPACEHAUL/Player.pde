class Player extends Body {
  // private final float MAX_VELOCITY = 2f;
  
  private float orientation = 0.0;
  
  private final float THRUST_INCREMENT = 0.05;
  private final float ORIENTATION_INCREMENT = 0.1;
  
  private final float radius = 7;

  public boolean movingForward = false; 
  public boolean turningRight = false;
  public boolean turningLeft = false;
  public boolean reversing = false; //these correspond to W, A, S, D / UP LEFT RIGHT DOWN keys.
  
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
    
    //update orientation (pressing A or D / LEFT or RIGHT keys)
    updateOrientation();
    //update thrust (pressing W or S / UP or DOWN)
    updateThrust();
    
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
    if(turningRight){
      orientation -= ORIENTATION_INCREMENT;
      if(orientation > TWO_PI){
       orientation -= TWO_PI; 
      }
    } else if (turningLeft){
      orientation += ORIENTATION_INCREMENT;
      if(orientation < -TWO_PI){
       orientation += TWO_PI; 
      }
    }
  }
  
  private void updateThrust(){
    if(movingForward){
      velocity.y += sin(orientation)*THRUST_INCREMENT; //vertical component of unit circle
      velocity.x += cos(orientation)*THRUST_INCREMENT; //horizontal component
      //effect is vector added to velocity with magnitude THRUST_INCREMENT, pointing in direction of orientation.
    } else if (reversing){
      velocity.y -= sin(orientation)*THRUST_INCREMENT;
      velocity.x -= cos(orientation)*THRUST_INCREMENT;
    }
    //we do not reset velocity due to the lack of drag force in space.
  }
  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.rotate(orientation + HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, radius, 0, -radius*2, radius, radius);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    if(movingForward){ //visual indicator that you are accelerating
      CS4303SPACEHAUL.offScreenBuffer.circle(0, radius*1.25, 4); 
    } else if(reversing){
      CS4303SPACEHAUL.offScreenBuffer.circle(0, -radius*2.25, 4); 
    } 
    CS4303SPACEHAUL.offScreenBuffer.rotate(-(orientation + HALF_PI));
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
}
