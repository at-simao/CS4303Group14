class Player extends Body {
  // private final float MAX_VELOCITY = 2f;
  
  private float health = 100;
  private final float MAX_HEALTH = 100;
  
  private float orientation = 0.0;
  
  private final float THRUST_INCREMENT = 0.08;
  private final float ORIENTATION_INCREMENT = 0.1;
  private final float SLOW_DOWN = 0.97; //drag applied when player attempts to slow down: this is done when the press thurstLeft and thrustRight at the same time.
  
  private final float HYPERSPEED_MIN = 8;
  private int drawUpTo = 0;
  
  private final float radius = 7;
  
  private int AIs = 0;
  public boolean thrustUp = false; 
  public boolean thrustRight = false;
  public boolean thrustLeft = false;
  public boolean thrustDown = false; //these correspond to W, A, S, D / UP LEFT RIGHT DOWN keys.
  
  private color colour;
  
  private PVector[] trailing = new PVector[10];
  private Timer respawnTimer = null;
  private boolean hasCargo = false;
  private Planet cargo;
  
  private FriendlyAI aiBehindPlayer = null;
  
  public Player(PVector start, int whichPlayer) {
    super(start, new PVector(0,0), 0.1);
    if(whichPlayer == 1){
      colour = color(255,0,0);
    } else {
      colour = color(0,70,200);
    }
    for(int i = 0; i < trailing.length; i++){
      trailing[i] = new PVector(start.x, start.y, orientation); //overloading PVector semantics to store x,y,orientation as 3D vector.
    }
  }

  public void updateVelocity() {
    PVector resultingAcceleration = forceAccumulator.get();
    resultingAcceleration.mult(invMass);
    velocity.add(resultingAcceleration);

    updateThrust();

    forceAccumulator.x = 0;
    forceAccumulator.y = 0;
  }
  
  public void updateRespawnTimer(){
    if(health <= 0 && respawnTimer == null){
      //DESPAWN PLAYER WHEN HEALTH IS 0, RESET.
      respawnTimer = new Timer(15000, position, radius*2.5, color(100), color(180));
      velocity.setMag(0);
      return;
    }
    if(respawnTimer != null){
      respawnTimer.updateTimer();
      health = MAX_HEALTH*((respawnTimer.getMaxTime() - respawnTimer.getCurrTime())/respawnTimer.getMaxTime());
      return;
    }
  }
  
  public void integrate() {
    if(respawnTimer != null){
      return; //no movement allowed until timer is spent.
    }
    //shift trailing by 1 to the right
    PVector temp = trailing[1];
    trailing[1] = trailing[0];
    for(int i = trailing.length-1; i > 0; i--){
      trailing[i] = trailing[i-1];
    }
    trailing[0] = new PVector(position.x, position.y, orientation);
    
    // updateOrientation(); //defunct currently
    // update thrust (pressing W,A,S,D / UP,LEFT,DOWN,RIGHT)
    
    if(velocity.mag() != 0){ //if 0, no need to update orientation, keep facing same direction from before standing-still.
      float targetOrientation = atan2(velocity.x, velocity.y); //we want character to face movement
      
      if (orientation > PI) orientation -= 2*PI ;
      else if (orientation < -PI) orientation += 2*PI ;
      
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
  }
  
  public void setCargo(Planet newCargo) {
    hasCargo = true;    
    this.cargo = newCargo;
    if(newCargo == null) hasCargo = false;
  }

  public Planet getCargo() {
     return this.cargo;
  }
  
  public boolean hasCargo() {
    return this.hasCargo;
  }
  
  private void updateOrientation(){
    //defunct currently, may be used later if we reverse change in player movement.
  }
  
  private void updateThrust(){
    PVector temp = new PVector(0,0);
    if(thrustLeft && thrustRight){
      velocity.mult(SLOW_DOWN);
      return;
    } else if (thrustRight){
      temp.x = -1; //horizontal component
    } else if (thrustLeft){
      temp.x = 1; //horizontal component
    }
    if(thrustUp){
      temp.y = -1; //horizontal component
    } else if (thrustDown){
      temp.y = 1; //horizontal component
    }
    temp.normalize().mult(THRUST_INCREMENT);
    velocity.add(temp);
    
    //we do not reset velocity due to the lack of drag force in space. Only slow down if player presses thurstLeft and thrustRight at the same time.
  }
  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    if(respawnTimer != null){
      drawUpTo = 0;
      if(respawnTimer.outOfTime()){
        respawnTimer = null;
        health = MAX_HEALTH;
        return;
      }
      respawnTimer.draw();
      return;
    }
    if(velocity.mag() > HYPERSPEED_MIN){
      drawUpTo++;
      drawUpTo = min(drawUpTo, trailing.length*3);
    } else {
      drawUpTo-=2;
      drawUpTo = max(drawUpTo, 0);
    }
    for(int i = 0; i < floor(drawUpTo/3); i++){
      CS4303SPACEHAUL.offScreenBuffer.noStroke();
      CS4303SPACEHAUL.offScreenBuffer.fill(255, 255, 255, floor(float(200*(trailing.length-i))/trailing.length));
      CS4303SPACEHAUL.offScreenBuffer.translate(trailing[i].x, trailing[i].y);
      CS4303SPACEHAUL.offScreenBuffer.rotate(-trailing[i].z+HALF_PI); //.z == orientation
      CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
      CS4303SPACEHAUL.offScreenBuffer.rotate(trailing[i].z-HALF_PI); //.z == orientation
      CS4303SPACEHAUL.offScreenBuffer.translate(-trailing[i].x, -trailing[i].y);
    }
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    //draw player sprite
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
        // Check if player has cargo and draw outline
    if (hasCargo) {
        CS4303SPACEHAUL.offScreenBuffer.stroke(cargo.getColour()); // Green outline
        CS4303SPACEHAUL.offScreenBuffer.strokeWeight(1.5);   // Set the weight of the outline
    } else {
        CS4303SPACEHAUL.offScreenBuffer.noStroke(); // No outline if no cargo
    }
    
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation+HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);    
    CS4303SPACEHAUL.offScreenBuffer.rotate((orientation-HALF_PI));
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
  
  public void drawHealthBar(){
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(0);
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.rect(-radius*1.5, radius*2.5, radius*3, radius/2);
    CS4303SPACEHAUL.offScreenBuffer.fill(0,180,0);
    CS4303SPACEHAUL.offScreenBuffer.rect(-radius*1.5, radius*2.5, ((radius*3)*health)/MAX_HEALTH, radius/2);
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
  
  public void drawImpulseIndicator(){ //draws circle in direction of impulse/where player is accelerating.
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    int upOrDown = 0;
    int leftOrRight = 0;
    if(!(thrustLeft || thrustRight || thrustUp || thrustDown)) {
      return;// no acceleration
    }
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
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.circle(placementOfExhaust.x*radius*2.25, placementOfExhaust.y*radius*2.25, 4); 
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);

  }
  
  public void changeHealthBy(float increment){
    health += increment;
    health = min(health, MAX_HEALTH);
    health = max(health, 0);
  }
  
  public float getHealth(){
    return health;
  }
  
  public float getRadius(){
    return radius;
  }
  
  public void setAIFollowing(FriendlyAI ai){
    aiBehindPlayer = ai;
  }
  
  public FriendlyAI getAIBehindPlayer(){
    return aiBehindPlayer;
  }
  
  public int getAIs() {
    return AIs;
  }
  public void increaseAIs() {
    AIs++;
  }
  public void decreaseAIs() {
    AIs--;
  }
}
