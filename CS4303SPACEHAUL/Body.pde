class Body { //from: https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/L5/GravitySketch/Particle.pde
   
  // Vectors to hold pos, vel
  public PVector position, velocity;
  // Store inverse mass to allow simulation of infinite mass
  protected float invMass;
  public PVector forceAccumulator;

  public Body (PVector pos, PVector vel) {
    this.position = new PVector(pos.x, pos.y);
    this.velocity = new PVector(vel.x, vel.y);
    this.forceAccumulator = new PVector(0, 0);
  }
  
  public Body (PVector pos, PVector vel, float invM) {
    this.position = new PVector(pos.x, pos.y);
    this.velocity = new PVector(vel.x, vel.y);
    this.invMass = invM;
    this.forceAccumulator = new PVector(0, 0);
  }

  public void addForce(PVector force) {
    forceAccumulator.add(force) ;
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

  public float getMass() {
    return 1 / invMass;
  }
  
  public float getInvMass(){
    return invMass;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    Body body = (Body) obj;
    return Float.compare(body.invMass, invMass) == 0 &&
          position.equals(body.position);
  }

  @Override
  public int hashCode() {
    int result = position != null ? position.hashCode() : 0;
    result = 31 * result + (invMass != 0 ? Float.floatToIntBits(invMass) : 0);
    return result;
  }
}
