class Body{ //from: https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/L5/GravitySketch/Particle.pde
   
  // Vectors to hold pos, vel
  public PVector position, velocity ;
    
  // Store inverse mass to allow simulation of infinite mass
  private float invMass ;
  
  Body (PVector pos, PVector vel, float invM) {
    position = new PVector(pos.x, pos.y) ;
    velocity = new PVector(vel.x, vel.y) ;
    invMass = invM ;    
  }
  
  //Method for determining strength of gravitational pull from one body to another.
  PVector calculateGravityByBody(PVector body1Pos, PVector body2Pos){
    PVector gravity = new PVector(body2Pos.x - body1Pos.x, body2Pos.y - body1Pos.y);
    float distance = gravity.mag();
    if(distance == 0) {
      gravity.mult(0); //prevent divide by 0 error
    } else{
      gravity.mult(1/pow(distance, 2.25));
    }
    return gravity.copy();
  }
  
  // update velocity based on gravitational pull.
  void gravitationalPull(Body otherBody) {
    if(position.x == otherBody.getPosition().x && position.y == otherBody.getPosition().y){
      return; //if both objects are on top of each other, gravity is infinitely large, so do not calculate.
    }
    PVector gravity = calculateGravityByBody(getPosition(), otherBody.getPosition()); //body1 == this body, body2 == otherBody.
    // If infinite mass, we don't integrate
    if (invMass <= 0f) return;
    
    PVector acceleration = gravity.copy() ;
    acceleration.mult(invMass);
    
    // update velocity
    velocity.add(acceleration);
  }
  
  public PVector getVelocity(){
    return velocity;
  }
  
  public void setVelocity(PVector velocity){
    this.velocity = velocity;
  }
  
  public PVector getPosition(){
    return position;
  }
  
  public float getInvMass(){
    return invMass;
  }
}
