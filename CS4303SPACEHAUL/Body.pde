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
  
  // update position and velocity
  // Takes gravity as a parameter for this demonstration
  void gravitationalPull(PVector gravity) {
    // If infinite mass, we don't integrate
    if (invMass <= 0f) return ;
    
    PVector acceleration = gravity.copy() ;
    acceleration.mult(invMass) ;
    
    // update velocity
    velocity.add(acceleration) ;
  }
}
